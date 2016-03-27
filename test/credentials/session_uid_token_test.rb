require_relative '../test_helper'

class SessionUidTokenTest < ActiveSupport::TestCase
  def setup
    @credential = Tokens::SessionUid.new
    @credential.code = 'fitobg6hzsk7odiiw3ca45ltghget4tlbbapxikgdsugfa36llwq'
    @credential.browser_ip = '18.70.0.160'
    @credential.browser_ua =
        'Mozilla/5.0 (X11; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1'
    @credential.user = users(:jane)
    @_expires_after = Tokens::SessionUid.expires_after
  end

  def teardown
    Tokens::SessionUid.expires_after = @_expires_after
  end

  test 'setup' do
    assert @credential.valid?
  end

  test 'code required' do
    @credential.code = nil
    assert !@credential.valid?
  end

  test 'code uniqueness' do
    @credential.code = credentials(:john_token).code
    assert !@credential.valid?
  end

  test 'browser_ip required' do
    @credential.browser_ip = nil
    assert !@credential.valid?
  end

  test 'browser_ua required' do
    @credential.browser_ua = nil
    assert !@credential.valid?
  end

  test 'user required' do
    @credential.user = nil
    assert !@credential.valid?
  end

  test 'expired?' do
    Tokens::SessionUid.expires_after = 14.days
    @credential.updated_at = Time.current - 1.day
    assert_equal false, @credential.expired?
    @credential.updated_at = Time.current - 1.month
    assert_equal true, @credential.expired?

    Tokens::SessionUid.expires_after = nil
    assert_equal false, @credential.expired?
  end

  test 'spend updates old token' do
    @credential.updated_at = Time.current - 1.day
    @credential.save!
    @credential.spend
    assert_operator @credential.updated_at, :>=, Time.current - 1.minute
  end

  test 'spend does not update reasonably new token' do
    # NOTE: Some databases don't support sub-second precision. In Rails 5, the
    #       time values reflect this, and would cause the test to fail if we
    #       don't round Time.current down to the nearest second.
    old_updated_at = @credential.updated_at =
        (Time.current - 5.minutes).change(usec: 0)
    @credential.spend
    assert_equal old_updated_at, @credential.updated_at
  end

  test 'remove_expired gets rid of old tokens' do
    old_token = credentials(:john_session_token)
    old_token.updated_at = Time.current - 1.year
    old_token.save!
    fresh_token = credentials(:jane_session_token)
    fresh_token.updated_at = Time.current - 1.minute
    fresh_token.save!

    assert_difference 'Credential.count', -1 do
      Tokens::SessionUid.remove_expired
    end
    assert_nil Tokens::Base.with_code(old_token.code).first
    assert_equal fresh_token,
                 Tokens::Base.with_code(fresh_token.code).first
  end

  test 'random_for' do
    user = users(:john)
    credential = nil
    assert_difference 'Credential.count', 1 do
      credential = Tokens::SessionUid.random_for user, '1.2.3.4', 'Test/UA'
    end
    saved_credential = Tokens::Base.with_code(credential.code).first
    assert saved_credential, 'token was not saved'
    assert_equal saved_credential, credential, 'wrong token returned'
    assert_equal user, saved_credential.user
    assert_equal '1.2.3.4', saved_credential.browser_ip
    assert_equal 'Test/UA', saved_credential.browser_ua
  end
end
