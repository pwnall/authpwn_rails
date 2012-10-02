require File.expand_path('../test_helper', __FILE__)

class InitializerTest < ActiveSupport::TestCase
  test 'password set correctly' do
    assert_equal 1.year, Credentials::Password.expires_after
  end

  test 'e-mail tokens set correctly' do
    assert_equal 3.days, Tokens::EmailVerification.expires_after
    assert_equal 3.days, Tokens::PasswordReset.expires_after
  end

  test 'cookie sessions set correctly' do
    assert_equal 14.days, Tokens::SessionUid.expires_after
    assert_equal 1.hour, Tokens::SessionUid.updates_after
  end
end

