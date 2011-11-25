require File.expand_path('../test_helper', __FILE__)

class UserWithEmail < User
  include Authpwn::UserExtensions::EmailField
end

class EmailFieldTest < ActiveSupport::TestCase
  def setup
    @user = UserWithEmail.new :email => 'blah@gmail.com'
    
    @john = UserWithEmail.find_by_id(users(:john).id)
    @jane = UserWithEmail.find_by_id(users(:jane).id)
    @bill = UserWithEmail.find_by_id(users(:bill).id)
  end
  
  test 'setup' do
    @user.save!
    assert @user.valid?
  end

  test 'email presence' do
    @user.email = nil
    assert !@user.valid?
  end
  
  test 'email_credential' do
    assert_equal credentials(:john_email), @john.email_credential
    assert_equal credentials(:jane_email), @jane.email_credential
    assert_nil @bill.email_credential
  end

  test 'email length' do
    @user.email = 'abcde' * 25 + '@mit.edu'
    assert !@user.valid?, 'Overly long email'
  end
  
  test 'email format' do
    ['cos tan@gmail.com', 'costan@x@mit.edu'].each do |email|
      @user.email = email
      assert !@user.valid?, "Bad email format - #{email}"
    end    
  end

  test 'email' do
    assert_equal credentials(:john_email).email, @john.email
    assert_equal credentials(:jane_email).email, @jane.email
    assert_nil @bill.email
  end

  test 'with_email' do
    assert_equal users(:john),
                 UserWithEmail.with_email(credentials(:john_email).email)
    assert_equal users(:jane),
                 UserWithEmail.with_email(credentials(:jane_email).email) 
    assert_nil UserWithEmail.with_email('nosuch@email.com')
  end
end
