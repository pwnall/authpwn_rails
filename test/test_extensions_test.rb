require File.expand_path('../test_helper', __FILE__)

class TestExtensionsTest < ActionController::TestCase
  def setup
    @user = users(:john)
    @token = credentials(:john_session_token)
  end

  test 'session_current_user for no user' do
    assert_nil session_current_user
  end

  test 'session_current_user with valid suid' do
    request.session[:authpwn_suid] = @token.suid
    assert_equal @user, session_current_user
  end

  test 'set_session_current_user reuses existing token' do
    assert_no_difference 'Credential.count' do
      set_session_current_user @user
    end
    assert_equal @token.suid, request.session[:authpwn_suid]
  end

  test 'set_session_current_user creates token if necessary' do
    @token.destroy
    assert_difference 'Credential.count', 1 do
      set_session_current_user @user
    end
    assert_equal @user, session_current_user
  end

  test 'set_session_current_user to nil' do
    request.session[:authpwn_suid] = @token.suid
    assert_no_difference 'Credential.count' do
      set_session_current_user nil
    end
    assert_nil request.session[:authpwn_suid]
  end
end

