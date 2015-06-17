require File.expand_path('../../test_helper', __FILE__)

class UserWithPassword < User
  include Authpwn::UserExtensions::PasswordField
end

class PasswordFieldTest < ActiveSupport::TestCase
  def setup
    @user = UserWithPassword.new password: 'awesome',
                                 password_confirmation: 'awesome'

    @john = UserWithPassword.find_by_id users(:john).id
    @jane = UserWithPassword.find_by_id users(:jane).id
    @bill = UserWithPassword.find_by_id users(:bill).id
  end

  test 'setup' do
    assert @user.valid?
  end

  test 'password can be missing for non-password logins' do
    user = UserWithPassword.new
    assert user.valid?
  end

  test 'password cannot be empty' do
    @user.password = @user.password_confirmation = ''
    assert !@user.valid?
  end

  test 'password assumed ok for existing records' do
    @john.save!
    assert @john.valid?
  end

  test 'password confirmation' do
    @user.password_confirmation = 'not awesome'
    assert !@user.valid?
  end

  test 'password_credential' do
    assert_equal credentials(:john_password), @john.password_credential
    assert_equal credentials(:jane_password), @jane.password_credential
    assert_nil @bill.password_credential
  end
end
