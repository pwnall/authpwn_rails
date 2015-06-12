require_relative '../test_helper'

class TokenCredentialTest < ActiveSupport::TestCase
  def setup
    @credential = Tokens::Base.new
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

  test 'spend does nothing' do
    credential = credentials(:john_token)
    assert_equal Tokens::Base, credential.class, 'bad setup'

    assert_no_difference -> { Credential.count } do
      credential.spend
    end
  end

  test 'random_for' do
    token = Tokens::Base.random_for users(:jane)
    assert token.valid?, 'valid token'
    assert_equal users(:jane), token.user
    assert_equal Tokens::Base, token.class
    assert !token.new_record?, 'saved token'
    assert_operator users(:jane).credentials, :include?, token
  end

  test 'random_for randomness' do
    codes = []
    1000.times do
      token = Tokens::Base.random_for users(:jane)
      codes << token.code
    end
    assert_equal codes.length, codes.uniq.length,
        'Token codes are not random enough'
  end

  test 'with_code' do
    john = 'ue5tqbx3u4z7jxxglickknirxroy7c3bgig4e2yccbmwqvf3r2vq'
    john_email = 'qid3ipai5be3bcilygdztwvtlpiyrfzxks2solmetndb4vzuvkca'
    jane = 'skygyoxxmnerxwe4zbi3p5yjtg7zpjl2peyfcwh5wnc37fyfc4xa'
    bogus = '3bl3iypby25bqooia7hpskihlrzjkt7opz5vgdp7i3mkaopdjcza'
    assert_equal credentials(:john_token),
                 Tokens::Base.with_code(john).first
    assert_equal credentials(:jane_token),
                 Tokens::Base.with_code(jane).first!
    assert_equal credentials(:john_email_token),
                 Tokens::Base.with_code(john_email).first
    assert_nil Tokens::Base.with_code(bogus).first
    assert_raise ActiveRecord::RecordNotFound do
      Tokens::Base.with_code('john@gmail.com').first!
    end
    assert_raise ActiveRecord::RecordNotFound do
      Tokens::Base.with_code(credentials(:jane_email).name).first!
    end
  end

  test 'with_param' do
    assert_equal credentials(:john_token), Tokens::Base.
        with_param(credentials(:john_token).to_param).first
    assert_equal credentials(:jane_token), Tokens::Base.
        with_param(credentials(:jane_token).to_param).first!
    assert_nil Tokens::Base.with_param('bogus token').first
    assert_raise ActiveRecord::RecordNotFound do
      Tokens::Base.with_param(nil).first!
    end
  end

  test 'class authenticate' do
    john = 'ue5tqbx3u4z7jxxglickknirxroy7c3bgig4e2yccbmwqvf3r2vq'
    john_email = 'qid3ipai5be3bcilygdztwvtlpiyrfzxks2solmetndb4vzuvkca'
    jane = 'skygyoxxmnerxwe4zbi3p5yjtg7zpjl2peyfcwh5wnc37fyfc4xa'
    bogus = '3bl3iypby25bqooia7hpskihlrzjkt7opz5vgdp7i3mkaopdjcza'

    assert_equal users(:john), Tokens::Base.authenticate(john)
    assert_equal users(:john), Tokens::Base.authenticate(john_email)
    assert_equal users(:jane), Tokens::Base.authenticate(jane)
    assert_equal :invalid, Tokens::Base.authenticate(bogus)
  end

  test 'class authenticate with non-base class' do
    john = 'ue5tqbx3u4z7jxxglickknirxroy7c3bgig4e2yccbmwqvf3r2vq'
    john_email = 'qid3ipai5be3bcilygdztwvtlpiyrfzxks2solmetndb4vzuvkca'
    bogus = '3bl3iypby25bqooia7hpskihlrzjkt7opz5vgdp7i3mkaopdjcza'

    assert_equal :invalid, Tokens::EmailVerification.authenticate(john)
    assert_equal users(:john),
        Tokens::EmailVerification.authenticate(john_email)
    assert_equal :invalid, Tokens::EmailVerification.authenticate(bogus)
  end

  test 'class authenticate on expired tokens' do
    john = 'ue5tqbx3u4z7jxxglickknirxroy7c3bgig4e2yccbmwqvf3r2vq'
    jane = 'skygyoxxmnerxwe4zbi3p5yjtg7zpjl2peyfcwh5wnc37fyfc4xa'

    Tokens::Base.all.each do |token|
      token.updated_at = Time.current - 1.year
      token.class.stubs(:expires_after).returns 1.week
      token.save!
    end
    assert_difference -> { Credential.count }, -1,
                      'authenticate deletes expired credential' do
      assert_equal :invalid, Tokens::Base.authenticate(john),
                   'expired token'
    end
    assert_difference -> { Credential.count }, -1,
                      'authenticate deletes expired credential' do
      assert_equal :invalid, Tokens::Base.authenticate(jane),
                   'expired token'
    end
  end

  test 'class authenticate calls User#auth_bounce_reason' do
    john = 'ue5tqbx3u4z7jxxglickknirxroy7c3bgig4e2yccbmwqvf3r2vq'
    jane = 'skygyoxxmnerxwe4zbi3p5yjtg7zpjl2peyfcwh5wnc37fyfc4xa'
    bogus = '3bl3iypby25bqooia7hpskihlrzjkt7opz5vgdp7i3mkaopdjcza'

    with_blocked_credential credentials(:john_token), :reason do
      assert_equal :reason, Tokens::Base.authenticate(john)
      assert_equal users(:jane), Tokens::Base.authenticate(jane)
      assert_equal :invalid, Tokens::Base.authenticate(bogus)
    end
  end

  test 'instance authenticate' do
    assert_equal users(:john), credentials(:john_token).authenticate
    assert_equal users(:jane), credentials(:jane_token).authenticate
  end

  test 'instance authenticate with expired tokens' do
    token = Tokens::Base.with_code(credentials(:jane_token).code).first
    token.updated_at = Time.current - 1.year
    token.save!
    token.class.stubs(:expires_after).returns 1.week
    assert_equal :invalid, token.authenticate,
                 'expired token'
    assert_nil Tokens::Base.with_code(credentials(:jane_token).code).first,
               'expired token not destroyed'
  end

  test 'instance authenticate calls User#auth_bounce_reason' do
    with_blocked_credential credentials(:john_token), :reason do
      assert_equal :reason, credentials(:john_token).authenticate
      assert_equal users(:jane), credentials(:jane_token).authenticate
    end
  end
end
