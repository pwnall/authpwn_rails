require_relative '../test_helper'

class UserWithEmail < User
  include Authpwn::UserExtensions::EmailField
end

class EmailFieldTest < ActiveSupport::TestCase
  setup do
    @user = UserWithEmail.new email: 'blah@gmail.com'

    @john = UserWithEmail.find_by_id users(:john).id
    @jane = UserWithEmail.find_by_id users(:jane).id
    @bill = UserWithEmail.find_by_id users(:bill).id
  end

  test 'setup' do
    assert @user.valid?
  end

  test 'freshly constructed user' do
    user = UserWithEmail.new
    assert !user.valid?
    assert_not_nil user.errors[:email], 'No validation errors on e-mail'
    assert user.errors[:email].any? { |m| /blank/i =~ m },
           'E-mail validation errors include length error'
  end

  test 'email presence' do
    @user.email = nil
    assert !@user.valid?
    assert_not_nil @user.errors[:email], 'No validation errors on e-mail'
    assert @user.errors[:email].any? { |m| /blank/i =~ m },
           'E-mail validation errors include presence error'
  end

  test 'email_credential' do
    assert_equal credentials(:john_email), @john.email_credential
    assert_equal credentials(:jane_email), @jane.email_credential
    assert_nil @bill.email_credential
  end

  test 'email length' do
    @user.email = 'abcde' * 25 + '@mit.edu'
    assert !@user.valid?, 'Overly long email'
    assert_not_nil @user.errors[:email], 'No validation errors on e-mail'
    assert @user.errors[:email].any? { |m| /too long/i =~ m },
           'E-mail validation errors include length error'
  end

  test 'email format' do
    ['cos tan@gmail.com', 'costan@x@mit.edu'].each do |email|
      @user.email = email
      assert !@user.valid?, "Bad email format - #{email}"
      assert_not_nil @user.errors[:email], 'No validation errors on e-mail'
      assert @user.errors[:email].any? { |m| /invalid/i =~ m },
             'E-mail validation errors include format error'
    end
  end

  test 'email uniqueness' do
    @user.email = @john.email
    assert !@user.valid?, 'Using existent e-mail'
    assert_not_nil @user.errors[:email], 'No validation errors on e-mail'
    assert @user.errors[:email].any? { |m| /already used by another/i =~ m },
           'E-mail validation errors include uniqueness error'
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
