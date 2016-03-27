require_relative '../test_helper'

class ApiTokenTest < ActiveSupport::TestCase
  def setup
    @credential = Tokens::Api.new
    @credential.code = 'fitobg6hzsk7odiiw3ca45ltghget4tlbbapxikgdsugfa36llwq'
    @credential.user = users(:bill)
  end

  test 'setup' do
    assert @credential.valid?
  end

  test 'code required' do
    @credential.code = nil
    assert !@credential.valid?
  end

  test 'code uniqueness' do
    @credential.code = credentials(:jane_token).code
    assert !@credential.valid?
  end

  test 'user required' do
    @credential.user = nil
    assert !@credential.valid?
  end

  test 'user uniqueness' do
    @credential.user = credentials(:john_api_token).user
    assert !@credential.valid?
  end

  test 'spend does nothing' do
    credential = credentials(:john_api_token)
    assert_equal Tokens::Api, credential.class, 'bad setup'

    assert_no_difference 'Credential.count' do
      credential.spend
    end
  end

  test 'expired?' do
    @credential.updated_at = Time.current - 1.year
    assert_equal false, @credential.expired?
  end

  test 'spend does not update old token' do
    old_updated_at = @credential.updated_at = Time.current - 1.year
    @credential.spend
    assert_equal old_updated_at, @credential.updated_at
  end

  test 'random_for' do
    user = users(:jane)
    credential = nil
    assert_difference 'Credential.count', 1 do
      credential = Tokens::Api.random_for user
    end
    saved_credential = Tokens::Base.with_code(credential.code).first
    assert saved_credential, 'token was not saved'
    assert_equal saved_credential, credential, 'wrong token returned'
    assert_equal user, saved_credential.user
  end
end
