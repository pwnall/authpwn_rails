require File.expand_path('../test_helper', __FILE__)

class PasswordCredentialTest < ActiveSupport::TestCase  
  def setup
    @credential = Credentials::Password.new :password => 'awesome',
        :password_confirmation => 'awesome', :user => users(:bill)
  end
  
  test 'setup' do
    assert @credential.valid?
  end
    
  test 'key not required' do
    @credential.key = nil
    assert @credential.valid?
  end
  
  test 'user presence' do
    @credential.user = nil
    assert !@credential.valid?
  end
  
  test 'user uniqueness' do
    @credential.user = users(:john)
    assert !@credential.valid?
  end
  
  test 'password confirmation' do
    @credential.password_confirmation = 'not awesome'
    assert !@credential.valid?
  end
  
  test 'password required' do
    @credential.password = @credential.password_confirmation = nil
    assert !@credential.valid?
  end
  
  test 'authenticate' do
    assert_equal true, @credential.authenticate('awesome')
    assert_equal false, @credential.authenticate('not awesome'),
                 'Bogus password'
    assert_equal false, @credential.authenticate('password'),
                 "Another user's password" 
  end
    
  test 'authenticate_email' do
    assert_equal users(:john),
        Credentials::Password.authenticate_email('john@gmail.com', 'password')
    assert_equal nil,
        Credentials::Password.authenticate_email('john@gmail.com', 'pa55w0rd'),
        "Jane's password on John's account"
    assert_equal users(:jane),
        Credentials::Password.authenticate_email('jane@gmail.com', 'pa55w0rd')
    assert_equal nil,
        Credentials::Password.authenticate_email('jane@gmail.com', 'password'),
        "John's password on Jane's account"
    assert_equal nil,
        Credentials::Password.authenticate_email('john@gmail.com', 'awesome'),
        'Bogus password'
  end
end
