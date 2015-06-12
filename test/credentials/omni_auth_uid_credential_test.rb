require_relative '../test_helper'

class OmniAuthUidCredentialTest < ActiveSupport::TestCase
  def setup
    @credential = Credentials::OmniAuthUid.new
    @credential.provider = 'developer'
    @credential.uid = 'dvdjohn@mit.edu'
    @credential.user = users(:bill)
  end

  test 'setup' do
    assert @credential.valid?
  end

  test 'provider required' do
    @credential.provider = ''
    assert !@credential.valid?
  end

  test 'uid required' do
    @credential.uid = ''
    assert !@credential.valid?
  end

  test 'blocked set to true' do
    @credential.blocked = true
    assert_equal '0', @credential.key, 'key'
    assert_equal true, @credential.blocked?, 'blocked?'
  end

  test 'blocked set to false' do
    @credential.blocked = false
    assert_equal '1', @credential.key, 'key'
    assert_equal false, @credential.blocked?, 'blocked?'
  end

  test 'user required' do
    @credential.user = nil
    assert !@credential.valid?
  end

  test 'uid length' do
    @credential.uid = 'abcde' * 25 + '@mit.edu'
    assert !@credential.valid?, 'Overly long uid'
    assert @credential.errors[:name].any? { |m| /too long/i =~ m },
           'Validation errors include length error'
  end

  test 'provider+uid uniqueness' do
    @credential.uid = credentials(:john_omniauth_developer).uid
    assert !@credential.valid?
    assert @credential.errors[:name].any? { |m| m == 'has already been taken' }
  end

  test 'name_from_omniauth' do
    assert_equal 'developer,dvdjohn@mit.edu',
        Credentials::OmniAuthUid.name_from_omniauth('provider' => 'developer',
        'uid' => 'dvdjohn@mit.edu')
    assert_equal 'twitter,dvdjohn',
        Credentials::OmniAuthUid.name_from_omniauth('provider' => 'twitter',
        'uid' => 'dvdjohn')
    assert_equal ',dvdjohn',
        Credentials::OmniAuthUid.name_from_omniauth('uid' => 'dvdjohn')
    assert_equal 'twitter,',
        Credentials::OmniAuthUid.name_from_omniauth('provider' => 'twitter')
  end

  test 'authenticate with existing credential' do
    assert_equal users(:jane), Credentials::OmniAuthUid.authenticate(
        'provider' => 'developer', 'uid' => 'jane@gmail.com')
  end

  test 'authenticate with blocked existing credential' do
    omniauth_hash = { 'provider' => 'developer', 'uid' => 'john@gmail.com' }
    assert_equal :blocked, Credentials::OmniAuthUid.authenticate(omniauth_hash)

    john_omniauth_developer = credentials(:john_omniauth_developer)
    john_omniauth_developer.blocked = false
    john_omniauth_developer.save!
    assert_equal users(:john),
                 Credentials::OmniAuthUid.authenticate(omniauth_hash)
  end

  test 'authenticate calls User#related_to_omniauth' do
    jane = users(:jane)
    credentials(:jane_omniauth_developer).destroy

    omniauth_hash = { 'provider' => 'developer', 'uid' => 'jane@gmail.com' }
    User.expects(:related_to_omniauth).with(omniauth_hash).returns jane
    User.expects(:create_from_omniauth).never

    assert_nil Credentials::OmniAuthUid.with(omniauth_hash)
    assert_difference -> { Credentials::OmniAuthUid.count } do
      assert_equal jane, Credentials::OmniAuthUid.authenticate(omniauth_hash)
    end
    assert_not_nil Credentials::OmniAuthUid.with(omniauth_hash)
    assert_equal jane, Credentials::OmniAuthUid.with(omniauth_hash).user
  end

  test 'authenticate calls User#create_from_omniauth' do
    user = User.create!
    omniauth_hash = { 'provider' => 'developer', 'uid' => 'new_user@gmail.com',
                      'email' => 'new_user@gmail.com' }
    User.expects(:related_to_omniauth).with(omniauth_hash).returns nil
    User.expects(:create_from_omniauth).with(omniauth_hash).returns user

    assert_nil Credentials::OmniAuthUid.with(omniauth_hash)
    assert_difference -> { Credentials::OmniAuthUid.count } do
      assert_equal user, Credentials::OmniAuthUid.authenticate(omniauth_hash)
    end
    assert_not_nil Credentials::OmniAuthUid.with(omniauth_hash)
    assert_equal user, Credentials::OmniAuthUid.with(omniauth_hash).user
  end

  test 'authenticate fails if User#create_from_omniauth returns nil' do
    omniauth_hash = { 'provider' => 'developer', 'uid' => 'new_user@gmail.com',
                      'email' => 'new_user@gmail.com' }
    User.expects(:related_to_omniauth).with(omniauth_hash).returns nil
    User.expects(:create_from_omniauth).with(omniauth_hash).returns nil

    assert_nil Credentials::OmniAuthUid.with(omniauth_hash)
    assert_no_difference -> { Credentials::OmniAuthUid.count } do
      assert_equal :invalid,
                   Credentials::OmniAuthUid.authenticate(omniauth_hash)
    end
  end

  test 'authenticate calls User#auth_bounce_reason' do
    with_blocked_credential credentials(:jane_omniauth_developer), :reason do
      assert_equal :reason, Credentials::OmniAuthUid.authenticate(
          'provider' => 'developer', 'uid' => 'jane@gmail.com')

      john_omniauth = credentials(:john_omniauth_developer)
      john_omniauth.blocked = false
      john_omniauth.save!
      assert_equal users(:john), Credentials::OmniAuthUid.authenticate(
          'provider' => 'developer', 'uid' => 'john@gmail.com')
    end
  end
end
