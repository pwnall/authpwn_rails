require_relative '../test_helper'

class OneTimeTokenCredentialTest < ActiveSupport::TestCase
  setup do
    @credential = Tokens::OneTime.new
    @credential.code = 'fitobg6hzsk7odiiw3ca45ltghget4tlbbapxikgdsugfa36llwq'
    @credential.user = users(:bill)
  end

  test 'setup' do
    assert @credential.valid?
  end

  test 'code required' do
    @credential.code = nil
    assert !@credential.valid?
  end

  test 'code uniqueness' do
    @credential.code = credentials(:jane_token).code
    assert !@credential.valid?
  end

  test 'user required' do
    @credential.user = nil
    assert !@credential.valid?
  end

  test 'spend destroys the token' do
    credential = credentials(:jane_token)
    assert_equal Tokens::OneTime, credential.class, 'bad setup'

    assert_difference -> { Credential.count }, -1 do
      credential.spend
    end
    assert credential.frozen?, 'not destroyed'
  end

  test 'authenticate spends the token' do
    jane = 'skygyoxxmnerxwe4zbi3p5yjtg7zpjl2peyfcwh5wnc37fyfc4xa'
    bogus = 'AyCMIixa5C7BBqU-XFI7l7IaUFJ4zQZPmcK6oNb3FLo'
    assert_difference -> { Credential.count }, -1, 'token spent' do
      assert_equal users(:jane), Tokens::Base.authenticate(jane)
    end
    assert_no_difference -> { Credential.count }, 'token mistakenly spent' do
      assert_equal :invalid, Tokens::Base.authenticate(bogus)
    end
  end

  test 'authenticate calls User#auth_bounce_reason' do
    jane = 'skygyoxxmnerxwe4zbi3p5yjtg7zpjl2peyfcwh5wnc37fyfc4xa'

    with_blocked_credential credentials(:jane_token), :reason do
      assert_no_difference -> { Credential.count }, 'no token spent' do
        assert_equal :reason, Tokens::Base.authenticate(jane)
      end
    end
  end

  test 'instance authenticate spends the token' do
    assert_difference -> { Credential.count }, -1, 'token spent' do
      assert_equal users(:jane), credentials(:jane_token).authenticate
    end
  end

  test 'instance authenticate calls User#auth_bounce_reason' do
    with_blocked_credential credentials(:jane_token), :reason do
      assert_no_difference -> { Credential.count }, 'token mistakenly spent' do
        assert_equal :reason, credentials(:jane_token).authenticate
      end
    end
  end

  test 'random_for' do
    token = Tokens::OneTime.random_for users(:jane)
    assert token.valid?, 'valid token'
    assert_equal users(:jane), token.user
    assert_equal Tokens::OneTime, token.class
    assert !token.new_record?, 'saved token'
    assert_operator users(:jane).credentials, :include?, token
  end
end
