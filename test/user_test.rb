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
    assert_equal exuids.length, exuids.uniq.length,
                 'UIDs are not random enough'
  end

  test 'to_param' do
    assert_equal '56789', users(:john).to_param
  end

  test 'with_param' do
    assert_equal users(:john), User.with_param(users(:john).to_param).first
    assert_equal users(:jane), User.with_param(users(:jane).to_param).first!
    assert_equal nil, User.with_param('bogus id').first
    assert_raise ActiveRecord::RecordNotFound do
      User.with_param(nil).first!
    end
  end

  test 'find_by_param' do
    assert_equal users(:john), User.find_by_param(users(:john).to_param)
    assert_equal users(:jane), User.find_by_param(users(:jane).to_param)
    assert_equal nil, User.find_by_param('bogus id')
    assert_equal nil, User.find_by_param(nil)
  end

  test 'authenticate_signin' do
    assert_equal users(:jane),
        User.authenticate_signin('jane@gmail.com', 'pa55w0rd')
    assert_equal :invalid,
        User.authenticate_signin('jane@gmail.com', 'password'),
        "John's password on Jane's account"
    assert_equal :blocked,
        User.authenticate_signin('john@gmail.com', 'password')
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
