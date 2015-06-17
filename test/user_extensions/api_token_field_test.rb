require File.expand_path('../../test_helper', __FILE__)

class UserWithApiToken < User
  include Authpwn::UserExtensions::ApiTokenField
end

class ApiTokenFieldTest < ActiveSupport::TestCase
  def setup
    @john = UserWithApiToken.find_by_id users(:john).id
    @jane = UserWithApiToken.find_by_id users(:jane).id
    @bill = UserWithApiToken.find_by_id users(:bill).id
  end

  test 'api_token_credential' do
    assert_equal credentials(:john_api_token), @john.api_token_credential
    assert_equal nil, @jane.api_token_credential
    assert_equal nil, @bill.api_token_credential
  end

  test 'api_token with existing credential' do
    assert_equal credentials(:john_api_token).code, @john.api_token
    assert_equal nil, @jane.api_token_credential
    assert_equal nil, @bill.api_token_credential
  end

  test 'api_token without existing credential' do
    assert_equal nil, @jane.api_token_credential
    token_code = @jane.api_token
    assert_not_equal nil, @jane.api_token_credential
    assert_equal @jane.api_token_credential.code, token_code
    assert_not_equal credentials(:john_api_token).code, token_code
    assert_equal nil, @bill.api_token_credential
  end
end
