require File.expand_path('../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase  
  def setup
    @user = User.new
  end
  
  test 'setup' do
    assert @user.valid?
  end
  
  test 'exuid generation' do
    assert @user.valid?
    assert @user.exuid
  end
  
  test 'exuid uniqueness' do
    @user.exuid = users(:john).exuid
    assert !@user.valid?
  end
  
  test 'exuid presence' do
    @user.exuid = ''
    assert !@user.valid?
  end
  
  test 'exuid randomness' do
    exuids = []
    1000.times do
      @user.exuid = nil
      @user.set_default_exuid
      exuids << @user.exuid
      @user.save!  # Catch range errors.
    end
    assert_equal exuids.length, exuids.uniq.length, 'UIDs are not random enough'
  end
    
  test 'to_param' do
    assert_equal '56789', users(:john).to_param
  end
  
  test 'find_by_param' do
    assert_equal users(:john), User.find_by_param(users(:john).to_param)
    assert_equal users(:jane), User.find_by_param(users(:jane).to_param)
    assert_equal nil, User.find_by_param('bogus id')
    assert_equal nil, User.find_by_param(nil)
  end
  
  test 'nested attributes' do
    @user = User.new :credentials_attributes => { 0 =>
        {:name => 'test@email.com', :type => 'Credentials::Password'}}
    assert_equal 1, @user.credentials.length
    assert_equal 'test@email.com', @user.credentials.first.name
  end

  test 'authenticate_email' do
    assert_equal users(:john),
        User.authenticate_signin('john@gmail.com', 'password')
    assert_equal :invalid,
        User.authenticate_signin('john@gmail.com', 'pa55w0rd'),
        "Jane's password on John's account"
  end
end
