require_relative 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
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
    assert_equal exuids.length, exuids.uniq.length,
                 'UIDs are not random enough'
  end

  test 'to_param' do
    assert_equal 'john000exuid', users(:john).to_param
  end

  test 'with_param' do
    assert_equal users(:john), User.with_param(users(:john).to_param).first
    assert_equal users(:jane), User.with_param(users(:jane).to_param).first!
    assert_equal nil, User.with_param('bogus id').first
    assert_raise ActiveRecord::RecordNotFound do
      User.with_param(nil).first!
    end
  end

  test 'authenticate_signin with valid data' do
    signin = Session.new email: 'jane@gmail.com', password: 'pa55w0rd'
    assert_equal users(:jane), User.authenticate_signin(signin)
  end

  test 'authenticate_signin with wrong password' do
    signin = Session.new email: 'jane@gmail.com', password: 'password'
    assert_equal :invalid, User.authenticate_signin(signin),
        "John's password on Jane's account"
  end

  test 'authenticate_signin on blocked e-mail' do
    signin = Session.new email: 'john@gmail.com', password: 'pa55w0rd'
    assert_equal :blocked, User.authenticate_signin(signin)
  end

  test 'related_to_omniauth without e-mail' do
    assert_equal nil, User.related_to_omniauth('provider' => 'developer',
                                               'uid' => 'john@gmail.com')
    assert_equal nil, User.related_to_omniauth('provider' => 'developer',
                                               'uid' => 'john@gmail.com',
                                               'info' => {})
  end

  test 'related_to_omniauth with existing e-mail' do
    Credentials::OmniAuthUid.destroy_all
    assert_equal users(:john), User.related_to_omniauth(
        'provider' => 'developer', 'uid' => 'john_gmail_com_uid',
        'info' => { 'email' => 'john@gmail.com' })
  end

  test 'related_to_omniauth with non-existing e-mail' do
    assert_equal nil, User.related_to_omniauth('provider' => 'developer',
        'uid' => 'new_user@gmail.com',
        'info' => { 'email' => 'new_user@gmail.com' })
  end

  test 'create_from_omniauth without e-mail' do
    assert_equal nil, User.create_from_omniauth('provider' => 'developer',
                                                'uid' => 'newuser@gmail.com')
    assert_equal nil, User.create_from_omniauth('provider' => 'developer',
                                                'uid' => 'newuser@gmail.com',
                                                'info' => {})
  end

  test 'create_from_omniauth with e-mail' do
    omniauth_hash = { 'provider' => 'developer',
        'uid' => 'newuser_gmail_com_uid',
        'info' => { 'email' => 'newuser@gmail.com' } }
    user = User.create_from_omniauth omniauth_hash
    assert_not_nil user
    email_credential = Credentials::Email.where(user: user).first
    assert_not_nil email_credential
    assert_equal 'newuser@gmail.com', email_credential.email
    assert_equal true, email_credential.valid?
  end

  test 'autosaves credentials' do
    user = users(:john)
    email_credential = user.credentials.
        find { |c| c.instance_of?(Credentials::Email) }
    email_credential.verified = true
    assert email_credential.changed?, 'Broken test assumption'
    user.save!

    assert !email_credential.changed?, 'Credential not auto-saved'
  end
end
