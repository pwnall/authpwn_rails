require File.expand_path('../../test_helper', __FILE__)

class TokenCredentialTest < ActiveSupport::TestCase  
  def setup
    @credential = Credentials::Token.new(
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
  
  test 'spend does nothing' do
    credential = credentials(:jane_token)
    assert_equal Credentials::Token, credential.class, 'bad setup'
    
    assert_no_difference 'Credential.count' do
      credential.spend
    end
  end
  
  test 'random_for' do
    token = Credentials::Token.random_for users(:john)
    assert token.valid?, 'valid token'
    assert_equal users(:john), token.user
    assert_equal Credentials::Token, token.class
    assert !token.new_record?, 'saved token'
    assert_operator users(:john).credentials, :include?, token
  end
  
  test 'with_code' do
    john = 'YZ-Fo8HX6_NyU6lVZXYi6cMDLV5eAgt35UTF5l8bD6A'
    john2 = 'bDSU4tzfjuob79e3R0ykLcOGTBBYvuBWWJ9V06tQrCE'
    jane = '6TXe1vv7BgOw0BkJ1hzUKO6G08fLk4sVfJ3wPDZHS-c'
    bogus = 'AyCMIixa5C7BBqU-XFI7l7IaUFJ4zQZPmcK6oNb3FLo'
    assert_equal credentials(:john_token), Credentials::Token.with_code(john)
    assert_equal credentials(:jane_token), Credentials::Token.with_code(jane)
    assert_equal credentials(:john_email_token),
                 Credentials::Token.with_code(john2)
    assert_nil Credentials::Token.with_code(bogus)
    assert_nil Credentials::Token.with_code('john@gmail.com')
    assert_nil Credentials::Token.with_code(credentials(:jane_email).name)
  end
  
  test 'find_by_param' do
    assert_equal credentials(:john_token), Credentials::Token.
        find_by_param(credentials(:john_token).to_param)
    assert_equal credentials(:jane_token), Credentials::Token.
        find_by_param(credentials(:jane_token).to_param)
    assert_equal nil, Credentials::Token.find_by_param('bogus token')
    assert_equal nil, Credentials::Token.find_by_param(nil)
  end
  
  test 'class authenticate' do
    john = 'YZ-Fo8HX6_NyU6lVZXYi6cMDLV5eAgt35UTF5l8bD6A'
    jane = '6TXe1vv7BgOw0BkJ1hzUKO6G08fLk4sVfJ3wPDZHS-c'
    bogus = 'AyCMIixa5C7BBqU-XFI7l7IaUFJ4zQZPmcK6oNb3FLo'
    assert_equal users(:john), Credentials::Token.authenticate(john)
    assert_equal users(:jane), Credentials::Token.authenticate(jane)
    assert_equal :invalid, Credentials::Token.authenticate(bogus)
  end
  
  test 'class authenticate calls User#auth_bounce_reason' do
    john = 'YZ-Fo8HX6_NyU6lVZXYi6cMDLV5eAgt35UTF5l8bD6A'
    jane = '6TXe1vv7BgOw0BkJ1hzUKO6G08fLk4sVfJ3wPDZHS-c'
    bogus = 'AyCMIixa5C7BBqU-XFI7l7IaUFJ4zQZPmcK6oNb3FLo'

    with_blocked_credential credentials(:john_token), :reason do
      assert_equal :reason, Credentials::Token.authenticate(john)
      assert_equal users(:jane), Credentials::Token.authenticate(jane)
      assert_equal :invalid, Credentials::Token.authenticate(bogus)
    end
  end

  test 'instance authenticate' do
    assert_equal users(:john), credentials(:john_token).authenticate
    assert_equal users(:jane), credentials(:jane_token).authenticate
  end
  
  test 'instance authenticate calls User#auth_bounce_reason' do
    with_blocked_credential credentials(:john_token), :reason do
      assert_equal :reason, credentials(:john_token).authenticate
      assert_equal users(:jane), credentials(:jane_token).authenticate
    end
  end
end
