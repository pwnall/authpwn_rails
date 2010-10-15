require File.expand_path('../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase  
  def setup
    @user = User.new :password => 'awesome',
                     :password_confirmation => 'awesome',
                     :email => 'dvdjohn@mit.edu'
  end
  
  test 'password_salt not required' do
    @user.password_salt = nil
    assert @user.valid?
  end
  
  test 'password_salt length' do
    @user.password_salt = '12345' * 4
    assert !@user.valid?, 'Long salt'
    @user.password_salt = ''
    assert !@user.valid?, 'Empty salt'
  end
  
  test 'password_hash not required' do
    @user.password_hash = nil
    assert @user.valid?
  end
  
  test 'password_hash length' do
    @user.password_hash = '12345' * 13
    assert !@user.valid?, 'Long hash'
    @user.password_hash = ''
    assert !@user.valid?, 'Empty hash'
  end
  
  test 'email presence' do
    @user.email = nil
    assert !@user.valid?
  end
  
  test 'email length' do
    @user.email = 'abcde' * 12 + '@mit.edu'
    assert !@user.valid?, 'Overly long user name'
  end
  
  test 'email format' do
    ['cos tan@gmail.com', 'costan@x@mit.edu'].each do |email|
      @user.email = email
      assert !@user.valid?, "Bad email format - #{email}"
    end    
  end
  
  test 'email uniqueness' do
    @user.email = users(:john).email
    assert !@user.valid?
  end
  
  test 'password not required' do
    @user.reset_password
    assert @user.valid?
  end
  
  test 'password confirmation' do
    @user.password_confirmation = 'not awesome'
    assert !@user.valid?
  end
  
  test 'to_param' do
    assert_equal 'dvdjohn@mit.edu', @user.to_param
  end
  
  test 'password_matches?' do
    assert_equal true, @user.password_matches?('awesome')
    assert_equal false, @user.password_matches?('not awesome'), 'Bogus password'
    assert_equal false, @user.password_matches?('password'),
                 "Another user's password" 
  end
    
  test 'find_by_param' do
    assert_equal users(:john), User.find_by_param(users(:john).to_param)
    assert_equal users(:jane), User.find_by_param(users(:jane).to_param)
    assert_equal nil, User.find_by_param('bogus email')
    assert_equal nil, User.find_by_param(nil)
  end
  
  test 'find_by_email_and_password' do
    assert_equal users(:john),
        User.find_by_email_and_password('john@gmail.com', 'password')
    assert_equal nil,
        User.find_by_email_and_password('john@gmail.com', 'pa55w0rd'),
        "Jane's password on John's account"
    assert_equal users(:jane),
        User.find_by_email_and_password('jane@gmail.com', 'pa55w0rd')
    assert_equal nil,
        User.find_by_email_and_password('jane@gmail.com', 'password'),
        "John's password on Jane's account"
    assert_equal nil,
        User.find_by_email_and_password('john@gmail.com', 'awesome'),
        'Bogus password'
  end
    
  test 'facebook_token' do
    assert_nil @user.facebook_token
    
    user = users(:john)
    assert_equal facebook_tokens(:john), user.facebook_token
  end
  
  
  test 'for_facebook_token' do
    assert_equal users(:john),
        User.for_facebook_token(users(:john). facebook_token.access_token)
  end
end
