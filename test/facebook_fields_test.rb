require File.expand_path('../test_helper', __FILE__)

class UserWithFb < User
  include Authpwn::UserExtensions::FacebookFields
end

class FacebookFieldsTest < ActiveSupport::TestCase
  def setup
    @user = UserWithFb.new
    
    @john = UserWithFb.find_by_id(users(:john).id)
    @jane = UserWithFb.find_by_id(users(:jane).id)
    @bill = UserWithFb.find_by_id(users(:bill).id)
  end
  
  test 'setup' do
    assert @user.valid?
  end
  
  test 'facebook_credential' do
    assert_equal credentials(:john_facebook), @john.facebook_credential
    assert_equal credentials(:jane_facebook), @jane.facebook_credential
    assert_nil @bill.facebook_credential
  end

  test 'facebook_uid' do
    assert_equal credentials(:john_facebook).facebook_uid, @john.facebook_uid
    assert_equal credentials(:jane_facebook).facebook_uid, @jane.facebook_uid
    assert_nil @bill.facebook_uid
  end

  test 'facebook_access_token' do
    assert_equal credentials(:john_facebook).access_token,
                 @john.facebook_access_token
    assert_equal credentials(:jane_facebook).access_token,
                 @jane.facebook_access_token
    assert_nil @bill.facebook_access_token
  end

  test 'facebook_client' do
    assert_equal credentials(:john_facebook).access_token,
                 @john.facebook_client.access_token
    assert_nil @bill.facebook_client
  end

  test 'with_facebook_uid' do
    assert_equal users(:john), UserWithFb.with_facebook_uid(
        credentials(:john_facebook).facebook_uid)
    assert_equal users(:jane), UserWithFb.with_facebook_uid(
        credentials(:jane_facebook).facebook_uid)
    assert_nil UserWithFb.with_facebook_uid('0000000')
  end

  test 'for_facebook_token' do
    flexmock(Credentials::Facebook).should_receive(:uid_from_token).
        with(credentials(:john_facebook).key).
        and_return(credentials(:john_facebook).facebook_uid)
    assert_equal users(:john),
        UserWithFb.for_facebook_token(credentials(:john_facebook).access_token)
  end
end
