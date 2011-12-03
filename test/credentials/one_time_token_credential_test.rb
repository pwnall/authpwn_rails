require File.expand_path('../../test_helper', __FILE__)

class OneTimeTokenCredentialTest < ActiveSupport::TestCase  
  def setup
    @credential = Credentials::OneTimeToken.new(
        :code => 'AyCMIixa5C7BBqU-XFI7l7IaUFJ4zQZPmcK6oNb3FLo')
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
    @credential.code = credentials(:john_token).code
    assert !@credential.valid?
  end

  test 'user presence' do
    @credential.user = nil
    assert !@credential.valid?
  end
  
  test 'spend destroys the token' do
    credential = credentials(:john_token)
    assert_equal Credentials::OneTimeToken, credential.class, 'bad setup'
    
    assert_difference 'Credential.count', -1 do
      credential.spend
    end
    assert credential.frozen?, 'not destroyed'
  end
  
  test 'authenticate spends the token' do
    john = 'YZ-Fo8HX6_NyU6lVZXYi6cMDLV5eAgt35UTF5l8bD6A'
    bogus = 'AyCMIixa5C7BBqU-XFI7l7IaUFJ4zQZPmcK6oNb3FLo'
    assert_difference 'Credential.count', -1, 'token spent' do
      assert_equal users(:john), Credentials::Token.authenticate(john)
    end
    assert_no_difference 'Credential.count', 'token mistakenly spent' do
      assert_equal :invalid, Credentials::Token.authenticate(bogus)
    end
  end
  
  test 'authenticate calls User#auth_bounce_reason' do
    john = 'YZ-Fo8HX6_NyU6lVZXYi6cMDLV5eAgt35UTF5l8bD6A'
    jane = '6TXe1vv7BgOw0BkJ1hzUKO6G08fLk4sVfJ3wPDZHS-c'
    bogus = 'AyCMIixa5C7BBqU-XFI7l7IaUFJ4zQZPmcK6oNb3FLo'

    with_blocked_credential credentials(:john_token), :reason do
      assert_no_difference 'Credential.count', 'no token spent' do
        assert_equal :reason, Credentials::Token.authenticate(john)
      end
    end
  end
  
  test 'instance authenticate spends the token' do
    assert_difference 'Credential.count', -1, 'token spent' do
      assert_equal users(:john), credentials(:john_token).authenticate
    end
  end
  
  test 'instance authenticate calls User#auth_bounce_reason' do
    with_blocked_credential credentials(:john_token), :reason do
      assert_no_difference 'Credential.count', 'token mistakenly spent' do
        assert_equal :reason, credentials(:john_token).authenticate
      end
    end
  end
  
  test 'random_for' do
    token = Credentials::OneTimeToken.random_for users(:john)
    assert token.valid?, 'valid token'
    assert_equal users(:john), token.user
    assert_equal Credentials::OneTimeToken, token.class
    assert !token.new_record?, 'saved token'
    assert_operator users(:john).credentials, :include?, token
  end
end
