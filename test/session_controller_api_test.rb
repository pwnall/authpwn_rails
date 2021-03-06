require_relative 'test_helper'

class BareSessionController < ApplicationController
  include Authpwn::SessionController
  self.append_view_path File.expand_path('../fixtures', __FILE__)

  # NOTE: As of Rails 5, tests can't use assigns to reach into the controllers'
  #       instance variables. current_user is a part of authpwn's API, so we
  #       must test it.
  before_action :export_current_user_to_cookie
  def export_current_user_to_cookie
    cookies['_authpwn_test_cuid'] = if current_user
      current_user.id.to_s
    else
      'nil'
    end
  end
end

# Tests the methods injected by authpwn_session_controller.
class SessionControllerApiTest < ActionController::TestCase
  tests BareSessionController

  setup do
    @user = users(:jane)
    @email_credential = credentials(:jane_email)
    @password_credential = credentials(:jane_password)
    @token_credential = credentials(:jane_token)
    @omniauth_credential = credentials(:jane_omniauth_developer)
    @_auto_purge_sessions = BareSessionController.auto_purge_sessions
  end

  teardown do
    BareSessionController.auto_purge_sessions = @_auto_purge_sessions
  end

  test "show renders welcome without a user" do
    @controller.expects(:welcome).once.returns nil
    get :show
    assert_select 'p.welcome-page'
    assert_equal 'nil', cookies['_authpwn_test_cuid']
  end

  test "show json renders empty object without a user" do
    @controller.expects(:welcome).once.returns nil
    get :show, format: 'json'
    assert_response :ok
    assert_equal({}, ActiveSupport::JSON.decode(response.body))
  end

  test "show renders home with a user" do
    @controller.expects(:home).once.returns nil
    set_session_current_user @user
    get :show
    assert_select 'span.user-exuid', @user.exuid.to_s
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']
  end

  test "show json renders user when logged in" do
    set_session_current_user @user
    @controller.expects(:home).once.returns nil
    get :show, format: 'json'
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal @user.exuid, data['user']['exuid']

    assert @controller.send(:valid_authenticity_token?, session, data['csrf'])
  end

  test "new redirects to session#show when a user is logged in" do
    set_session_current_user @user
    get :new
    assert_redirected_to session_url
  end

  test "new renders login form without a user" do
    get :new
    assert_select 'form[action="/session"]'
    assert_equal 'nil', cookies['_authpwn_test_cuid']
  end

  test "new renders redirect_url when present in flash" do
    url = 'http://authpwn.redirect.url'
    get :new, flash: { auth_redirect_url: url }
    assert_select 'form[action="/session"]' do
      assert_select "input[name=\"redirect_url\"][value=\"#{url}\"]"
    end
  end

  test "create logs in with good account details" do
    post :create, params: { session: { email: @email_credential.email,
                                       password: 'pa55w0rd' } }
    assert_equal @user, session_current_user, 'session'
    assert_nil flash[:alert], 'no alert'
    assert_nil flash[:auth_redirect_url], 'no redirect URL in flash'
    assert_redirected_to session_url
  end

  test "create logs in with good raw account details" do
    post :create, params: { email: @email_credential.email,
                            password: 'pa55w0rd' }
    assert_equal @user, session_current_user, 'session'
    assert_nil flash[:alert], 'no alert'
    assert_nil flash[:auth_redirect_url], 'no redirect URL in flash'
    assert_redirected_to session_url
  end

  test "create logs in with good account details and no User-Agent" do
    request.headers['User-Agent'] = nil

    post :create, params: { session: { email: @email_credential.email,
                                       password: 'pa55w0rd' } }
    assert_equal @user, session_current_user, 'session'
    assert_nil flash[:alert], 'no alert'
    assert_nil flash[:auth_redirect_url], 'no redirect URL in flash'
    assert_redirected_to session_url
  end

  test "create purges sessions when logging in" do
    BareSessionController.auto_purge_sessions = true
    old_token = credentials(:jane_session_token)
    old_token.updated_at = Time.current - 1.year
    old_token.save!
    post :create, params: { session: { email: @email_credential.email,
                                       password: 'pa55w0rd' } }
    assert_equal @user, session_current_user, 'session'
    assert_nil Tokens::Base.with_code(old_token.code).first,
               'old session not purged'
  end

  test "create does not purge sessions if auto_purge_sessions is false" do
    BareSessionController.auto_purge_sessions = false
    old_token = credentials(:jane_session_token)
    old_token.updated_at = Time.current - 1.year
    old_token.save!
    post :create, params: { session: { email: @email_credential.email,
                                       password: 'pa55w0rd' } }
    assert_equal @user, session_current_user, 'session'
    assert_equal old_token, Tokens::Base.with_code(old_token.code).first,
               'old session purged'
  end

  test "create by json logs in with good account details" do
    post :create, format: 'json', params: { email: @email_credential.email,
                                            password: 'pa55w0rd' }

    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal @user.exuid, data['user']['exuid']
    assert_equal @user, session_current_user, 'session'

    assert @controller.send(:valid_authenticity_token?, session, data['csrf'])
  end

  test "create by json purges sessions when logging in" do
    BareSessionController.auto_purge_sessions = true
    old_token = credentials(:jane_session_token)
    old_token.updated_at = Time.current - 1.year
    old_token.save!
    post :create, format: 'json', params: { email: @email_credential.email,
                                            password: 'pa55w0rd' }

    assert_response :ok
    assert_equal @user, session_current_user, 'session'
    assert_nil Tokens::Base.with_code(old_token.code).first,
               'old session not purged'
  end

  test "create redirects properly with good account details" do
    url = 'http://authpwn.redirect.url'
    post :create, params: { redirect_url: url, session: {
        email: @email_credential.email, password: 'pa55w0rd' } }
    assert_redirected_to url
    assert_nil flash[:alert], 'no alert'
    assert_nil flash[:auth_redirect_url], 'no redirect URL in flash'
  end

  test "create does not log in with bad password" do
    post :create, params: { session: { email: @email_credential.email,
                                       password: 'fail' } }
    assert_redirected_to new_session_url
    assert_nil session_current_user, 'session'
    assert_match(/Invalid/, flash[:alert])
    assert_nil flash[:auth_redirect_url], 'no redirect URL in flash'
  end

  test "create does not log in with expired password" do
    @password_credential.updated_at = Time.current - 2.years
    @password_credential.save!
    post :create, params: { session: { email: @email_credential.email,
                                       password: 'pa55w0rd' } }
    assert_redirected_to new_session_url
    assert_nil session_current_user, 'session'
    assert_match(/expired/, flash[:alert])
    assert_nil flash[:auth_redirect_url], 'no redirect URL in flash'
  end

  test "create does not purge sessions if not logged in" do
    BareSessionController.auto_purge_sessions = true
    old_token = credentials(:jane_session_token)
    old_token.updated_at = Time.current - 1.year
    old_token.save!
    post :create, params: { session: { email: @email_credential.email,
                                       password: 'fail' } }
    assert_nil session_current_user, 'session'
    assert_equal old_token, Tokens::Base.with_code(old_token.code).first,
               'old session purged'
  end

  test "create does not log in blocked accounts" do
    with_blocked_credential @email_credential do
      post :create, params: { session: { email: @email_credential.email,
                                         password: 'pa55w0rd' } }
    end
    assert_redirected_to new_session_url
    assert_nil session_current_user, 'session'
    assert_match(/ blocked/, flash[:alert])
    assert_nil flash[:auth_redirect_url], 'no redirect URL in flash'
  end

  test "create uses User.authenticate_signin" do
    signin = Session.new email: 'em@ail.com', password: 'fail'
    Session.expects(:new).at_least_once.with(
        email: 'em@ail.com', password: 'fail').returns signin
    User.expects(:authenticate_signin).at_least_once.with(signin).
         returns @email_credential.user
    post :create, params: { email: 'em@ail.com', password: 'fail' }
    assert_equal @user, session_current_user, 'session'
    assert_redirected_to session_url
  end

  test "create by json does not log in with bad password" do
    post :create, format: 'json', params: {
        email: @email_credential.email, password: 'fail' }

    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal 'invalid', data['error']
    assert_match(/invalid/i , data['text'])
    assert_nil session_current_user, 'session'
  end

  test "create by json does not log in with expired password" do
    @password_credential.updated_at = Time.current - 2.years
    @password_credential.save!
    post :create, format: 'json', params: {
        email: @email_credential.email, password: 'pa55w0rd' }

    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal 'expired', data['error']
    assert_match(/expired/i , data['text'])
    assert_nil session_current_user, 'session'
  end

  test "create by json does not log in blocked accounts" do
    with_blocked_credential @email_credential do
      post :create, format: 'json', params: {
          email: @email_credential.email, password: 'pa55w0rd' }
    end
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal 'blocked', data['error']
    assert_match(/blocked/i , data['text'])
    assert_nil session_current_user, 'session'
  end

  test "create maintains redirect_url for bad logins" do
    url = 'http://authpwn.redirect.url'
    post :create, params: { redirect_url: url, session: {
        email: @email_credential.email, password: 'fail' } }
    assert_redirected_to new_session_url
    assert_match(/Invalid /, flash[:alert])
    assert_equal url, flash[:auth_redirect_url]
  end

  test "create does not log in with bad e-mail" do
    post :create, params: { email: 'nobody@gmail.com', password: 'no' }
    assert_redirected_to new_session_url
    assert_nil session_current_user, 'session'
    assert_match(/Invalid /, flash[:alert])
    assert_nil flash[:auth_redirect_url], 'no redirect URL in flash'
  end

  test "token logs in with good token" do
    @controller.expects(:home_with_token).once.with(@token_credential).
                returns(nil)
    get :token, params: { code: @token_credential.code }
    assert_redirected_to session_url
    assert_equal @user, session_current_user, 'session'
    assert_nil Tokens::Base.with_code(@token_credential.code).first,
               'one-time credential is spent'
  end

  test "token logs in with good token and no user-agent" do
    request.headers['User-Agent'] = nil

    @controller.expects(:home_with_token).once.with(@token_credential).
                returns(nil)
    get :token, params: { code: @token_credential.code }
    assert_redirected_to session_url
    assert_equal @user, session_current_user, 'session'
    assert_nil Tokens::Base.with_code(@token_credential.code).first,
               'one-time credential is spent'
  end

  test "token by json logs in with good token" do
    @controller.expects(:home_with_token).once.with(@token_credential).
                returns(nil)
    get :token, format: 'json', params: { code: @token_credential.code }
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal @user.exuid, data['user']['exuid']
    assert_equal @user, session_current_user, 'session'
    assert_nil Tokens::Base.with_code(@token_credential.code).first,
               'one-time credential is spent'

    assert @controller.send(:valid_authenticity_token?, session, data['csrf'])
  end

  test "token does not log in with random token" do
    assert_no_difference -> { Credential.count }, 'no credential is spent' do
      get :token, params: { code: 'no-such-token' }
    end
    assert_redirected_to new_session_url
    assert_nil session_current_user, 'session'
    assert_match(/Invalid/, flash[:alert])
  end

  test "token does not log in blocked accounts" do
    with_blocked_credential @token_credential do
      assert_no_difference -> { Credential.count }, 'no credential is spent' do
        get :token, params: { code: @token_credential.code }
      end
    end
    assert_redirected_to new_session_url
    assert_nil session_current_user, 'session'
    assert_match(/ blocked/, flash[:alert])
  end

  test "token by json does not log in with random token" do
    assert_no_difference -> { Credential.count }, 'no credential is spent' do
      get :token, format: 'json', params: { code: 'no-such-token' }
    end
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal 'invalid', data['error']
    assert_match(/invalid/i , data['text'])
    assert_nil session_current_user, 'session'
  end

  test "token by json does not log in blocked accounts" do
    with_blocked_credential @token_credential do
      assert_no_difference -> { Credential.count }, 'no credential is spent' do
        get :token, format: 'json', params: { code: @token_credential.code }
      end
    end
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal 'blocked', data['error']
    assert_match(/blocked/i , data['text'])
    assert_nil session_current_user, 'session'
  end

  test "logout" do
    set_session_current_user @user
    delete :destroy

    assert_redirected_to session_url
  end

  test "logout by json" do
    set_session_current_user @user
    delete :destroy, format: 'json'

    assert_response :no_content
  end

  test "api_token request" do
    user = users(:john)
    set_session_current_user user
    get :api_token
    assert_response :ok
    assert_select 'span[class="api-token"]', credentials(:john_api_token).code
  end

  test "api_token request from user without token" do
    set_session_current_user @user
    assert_difference -> { Tokens::Api.count }, 1 do
      get :api_token
    end
    assert_response :ok
    token = @user.credentials.where(type: 'Tokens::Api').first
    assert_select 'span[class="api-token"]', token.code
  end

  test "api_token request without logged in user" do
    get :api_token
    assert_response :forbidden
  end

  test "api_token JSON request" do
    user = users(:john)
    set_session_current_user user
    get :api_token, format: 'json'

    data = ActiveSupport::JSON.decode response.body
    assert_equal credentials(:john_api_token).code, data['api_token']
  end

  test "api_token JSON request from user without token" do
    set_session_current_user @user
    assert_difference -> { Tokens::Api.count }, 1 do
      get :api_token, format: 'json'
    end
    token = @user.credentials.where(type: 'Tokens::Api').first

    data = ActiveSupport::JSON.decode response.body
    assert_equal token.code, data['api_token']
  end

  test "api_token JSON request without logged in user" do
    get :api_token, format: 'json'
    assert_response :ok

    data = ActiveSupport::JSON.decode response.body
    assert_equal 'Please sign in', data['error']
  end

  test "api_token destroy request" do
    user = users(:john)
    set_session_current_user user
    assert_difference -> { Tokens::Api.count }, -1 do
      delete :destroy_api_token
    end
    assert_nil user.credentials.where(type: 'Tokens::Api').first
    assert_redirected_to api_token_session_url
    assert_match(/token.*revoked/, flash[:notice])
  end

  test "api_token destroy request from user without token" do
    set_session_current_user @user
    assert_no_difference -> { Tokens::Api.count } do
      delete :destroy_api_token
    end
    assert_nil @user.credentials.where(type: 'Tokens::Api').first
    assert_redirected_to api_token_session_url
    assert_match(/no.*token.*to.*revoke/, flash[:alert])
  end

  test "api_token destroy request without logged in user" do
    delete :destroy_api_token
    assert_response :forbidden
  end

  test "api_token destroy JSON request" do
    user = users(:john)
    set_session_current_user user
    assert_difference -> { Tokens::Api.count }, -1 do
      delete :destroy_api_token, format: 'json'
    end

    assert_nil user.credentials.where(type: 'Tokens::Api').first
    assert_equal({}, ActiveSupport::JSON.decode(response.body))
    assert_response :ok
  end

  test "api_token destroy JSON request from user without token" do
    set_session_current_user @user
    assert_no_difference -> { Tokens::Api.count } do
      delete :destroy_api_token, format: 'json'
    end

    assert_nil @user.credentials.where(type: 'Tokens::Api').first
    assert_response :not_found
  end

  test "api_token destroy JSON request without logged in user" do
    delete :destroy_api_token, format: 'json'
    assert_response :ok

    data = ActiveSupport::JSON.decode response.body
    assert_equal 'Please sign in', data['error']
  end

  test "password_change bounces without logged in user" do
    get :password_change
    assert_response :forbidden
    # Make sure no layout was rendered.
    assert_select 'title', 0
    assert_select 'h1', 0
  end

  test "password_change renders correct form" do
    set_session_current_user @user
    get :password_change
    assert_response :ok
    assert_select 'form[action="/session/change_password"][method="post"]' do
      assert_select 'input[name="credential[old_password]"]'
    end
  end

  test "change_password bounces without logged in user" do
    post :change_password, params: { credential: { old_password: 'pa55w0rd',
        password: 'hacks', password_confirmation: 'hacks' } }
    assert_response :forbidden
    # Make sure no layout was rendered.
    assert_select 'title', 0
    assert_select 'h1', 0
  end

  test "change_password works with correct input" do
    set_session_current_user @user
    post :change_password, params: { credential: { old_password: 'pa55w0rd',
        password: 'hacks', password_confirmation: 'hacks'} }
    assert_redirected_to session_url
    assert_equal @user, User.authenticate_signin(Session.new(email:
        @email_credential.email, password: 'hacks')), 'password not changed'
  end

  test "change_password works with correct input and extra form input" do
    set_session_current_user @user
    post :change_password, params: { credential: { old_password: 'pa55w0rd',
        password: 'hacks', password_confirmation: 'hacks' }, utf8: "\u2713",
        commit: 'Change Password' }
    assert_redirected_to session_url
    assert_equal @user, User.authenticate_signin(Session.new(email:
        @email_credential.email, password: 'hacks')), 'password not changed'
  end

  test "change_password rejects bad old password" do
    set_session_current_user @user
    post :change_password, params: { credential: { old_password: '_pa55w0rd',
        password: 'hacks', password_confirmation: 'hacks' } }
    assert_response :ok
    assert_select 'form[action="/session/change_password"][method="post"]' do
      assert_select 'input[name="credential[old_password]"]'
    end
    assert_equal @user, User.authenticate_signin(Session.new(email:
        @email_credential.email, password: 'pa55w0rd')),
        'password wrongly changed'
  end

  test "change_password rejects un-confirmed password" do
    set_session_current_user @user
    post :change_password, params: { credential: { old_password: 'pa55w0rd',
        password: 'hacks', password_confirmation: 'hacks_' } }
    assert_response :ok
    assert_select 'form[action="/session/change_password"][method="post"]' do
      assert_select 'input[name="credential[old_password]"]'
    end
    assert_equal @user, User.authenticate_signin(Session.new(email:
        @email_credential.email, password: 'pa55w0rd')),
        'password wrongly changed'
  end

  test "change_password works for password recovery" do
    set_session_current_user @user
    @password_credential.destroy
    post :change_password, params: { credential: { password: 'hacks',
        password_confirmation: 'hacks' } }
    assert_redirected_to session_url
    assert_equal @user, User.authenticate_signin(Session.new(email:
        @email_credential.email, password: 'hacks')), 'password not changed'
  end

  test "change_password rejects un-confirmed password on recovery" do
    set_session_current_user @user
    @password_credential.destroy
    assert_no_difference -> { Credential.count } do
      post :change_password, params: { credential: { password: 'hacks',
          password_confirmation: 'hacks_' } }
    end
    assert_response :ok
    assert_select 'form[action="/session/change_password"][method="post"]' do
      assert_select 'input[name="credential[old_password]"]', count: 0
    end
  end

  test "change_password by json bounces without logged in user" do
    post :change_password, format: 'json', params: {
        credential: { old_password: 'pa55w0rd', password: 'hacks',
                      password_confirmation: 'hacks' } }
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal 'Please sign in', data['error']
  end

  test "change_password by json works with correct input" do
    set_session_current_user @user
    post :change_password, format: 'json', params: {
        credential: { old_password: 'pa55w0rd', password: 'hacks',
                      password_confirmation: 'hacks' } }
    assert_response :no_content
    assert_equal @user, User.authenticate_signin(Session.new(email:
        @email_credential.email, password: 'hacks')), 'password not changed'
  end

  test "change_password by json rejects bad old password" do
    set_session_current_user @user
    post :change_password, format: 'json', params: {
        credential: { old_password: '_pa55w0rd', password: 'hacks',
                      password_confirmation: 'hacks' } }
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal 'invalid', data['error']
    assert_equal @user, User.authenticate_signin(Session.new(email:
        @email_credential.email, password: 'pa55w0rd')),
        'password wrongly changed'
  end

  test "change_password by json rejects un-confirmed password" do
    set_session_current_user @user
    post :change_password, format: 'json', params: {
         credential: { old_password: 'pa55w0rd', password: 'hacks',
                       password_confirmation: 'hacks_' } }
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal 'invalid', data['error']
    assert_equal @user, User.authenticate_signin(Session.new(email:
        @email_credential.email, password: 'pa55w0rd')),
        'password wrongly changed'
  end

  test "change_password by json works for password recovery" do
    set_session_current_user @user
    @password_credential.destroy
    post :change_password, format: 'json', params: {
         credential: { password: 'hacks', password_confirmation: 'hacks' } }
    assert_response :no_content
    assert_equal @user, User.authenticate_signin(Session.new(email:
        @email_credential.email, password: 'hacks')), 'password not changed'
  end

  test "change_password by json rejects un-confirmed password on recovery" do
    set_session_current_user @user
    @password_credential.destroy
    assert_no_difference -> { Credential.count } do
      post :change_password, format: 'json', params: {
           credential: { password: 'hacks', password_confirmation: 'hacks_' } }
    end
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal 'invalid', data['error']
  end

  test "reset_password for good e-mail" do
    ActionMailer::Base.deliveries = []
    request.host = 'mail.test.host:1234'

    assert_difference -> { Credential.count }, 1 do
      post :reset_password, params: {
          session: { email: @email_credential.email } }
    end

    token = Credential.last
    assert_operator token, :kind_of?, Tokens::PasswordReset
    assert_equal @user, token.user, 'password reset token user'

    assert !ActionMailer::Base.deliveries.empty?, 'email generated'
    email = ActionMailer::Base.deliveries.last
    assert_equal '"mail.test.host staff" <admin@mail.test.host>',
                 email['from'].to_s
    assert_equal [@email_credential.email], email.to
    assert_match 'http://mail.test.host:1234/', email.encoded
    assert_match token.code, email.encoded

    assert_redirected_to new_session_url
  end

  test "reset_password for good e-mail by json" do
    ActionMailer::Base.deliveries = []

    assert_difference -> { Credential.count }, 1 do
      post :reset_password, format: 'json', params: {
          session: { email: @email_credential.email } }

    end

    token = Credential.last
    assert_operator token, :kind_of?, Tokens::PasswordReset
    assert_equal @user, token.user, 'password reset token user'

    assert !ActionMailer::Base.deliveries.empty?, 'email generated'

    assert_response :ok
    assert_equal '{}', response.body
  end

  test "reset_password for invalid e-mail" do
    ActionMailer::Base.deliveries = []

    assert_no_difference -> { Credential.count } do
      post :reset_password, params: { session: { email: 'no@such.email' } }
    end
    assert ActionMailer::Base.deliveries.empty?, 'no email generated'

    assert_redirected_to new_session_url
  end

  test "reset_password for invalid e-mail by json" do
    ActionMailer::Base.deliveries = []

    assert_no_difference -> { Credential.count } do
      post :reset_password, format: 'json', params: {
          session: { email: 'no@such.email' } }
    end
    assert ActionMailer::Base.deliveries.empty?, 'no email generated'

    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_equal 'not_found', data['error']
  end

  test "create delegation to reset_password" do
    ActionMailer::Base.deliveries = []

    assert_difference -> { Credential.count }, 1 do
      post :create, params: { session: { email: @email_credential.email,
          password: '' }, reset_password: 'requested' }
    end

    token = Credential.last
    assert_operator token, :kind_of?, Tokens::PasswordReset
    assert_equal @user, token.user, 'password reset token user'
  end

  test "OmniAuth failure" do
    get :omniauth_failure

    assert_redirected_to new_session_url
    assert_match(/failed/, flash[:alert])
  end

  test "omniauth logs in with good account details" do
    ActionController::Base.allow_forgery_protection = true
    begin
      request.env['omniauth.auth'] =
          { 'provider' => @omniauth_credential.provider,
            'uid' => @omniauth_credential.uid }
      post :omniauth, params: { provider: @omniauth_credential.provider }
      assert_equal @user, session_current_user, 'session'
      assert_nil flash[:alert], 'no alert'
      assert_nil flash[:auth_redirect_url], 'no redirect URL in flash'
      assert_redirected_to session_url
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end

  test "omniauth logs in with good account details and no User-Agent" do
    ActionController::Base.allow_forgery_protection = true
    begin
      request.headers['User-Agent'] = nil

      request.env['omniauth.auth'] =
          { 'provider' => @omniauth_credential.provider,
            'uid' => @omniauth_credential.uid }
      post :omniauth, params: { provider: @omniauth_credential.provider }
      assert_equal @user, session_current_user, 'session'
      assert_nil flash[:alert], 'no alert'
      assert_nil flash[:auth_redirect_url], 'no redirect URL in flash'
      assert_redirected_to session_url
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end

  test "omniauth purges sessions when logging in" do
    ActionController::Base.allow_forgery_protection = true
    begin
      BareSessionController.auto_purge_sessions = true
      old_token = credentials(:jane_session_token)
      old_token.updated_at = Time.current - 1.year
      old_token.save!
      request.env['omniauth.auth'] =
          { 'provider' => @omniauth_credential.provider,
            'uid' => @omniauth_credential.uid }
      post :omniauth, params: { provider: @omniauth_credential.provider }
      assert_equal @user, session_current_user, 'session'
      assert_nil Tokens::Base.with_code(old_token.code).first,
                 'old session not purged'
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end

  test "omniauth does not purge sessions if auto_purge_sessions is false" do
    ActionController::Base.allow_forgery_protection = true
    begin
      BareSessionController.auto_purge_sessions = false
      old_token = credentials(:jane_session_token)
      old_token.updated_at = Time.current - 1.year
      old_token.save!
      request.env['omniauth.auth'] =
          { 'provider' => @omniauth_credential.provider,
            'uid' => @omniauth_credential.uid }
      post :omniauth, params: { provider: @omniauth_credential.provider }
      assert_equal @user, session_current_user, 'session'
      assert_equal old_token, Tokens::Base.with_code(old_token.code).first,
                 'old session purged'
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end

  test "omniauth does not purge sessions if not logged in" do
    ActionController::Base.allow_forgery_protection = true
    begin
      BareSessionController.auto_purge_sessions = true
      old_token = credentials(:jane_session_token)
      old_token.updated_at = Time.current - 1.year
      old_token.save!
      request.env['omniauth.auth'] =
          { 'provider' => @omniauth_credential.provider, 'uid' => 'fail' }
      post :omniauth, params: { provider: @omniauth_credential.provider }
      assert_nil session_current_user, 'session'
      assert_equal old_token, Tokens::Base.with_code(old_token.code).first,
                 'old session purged'
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end

  test "omniauth does not log in blocked accounts" do
    ActionController::Base.allow_forgery_protection = true
    begin
      request.env['omniauth.auth'] =
          { 'provider' => @omniauth_credential.provider,
            'uid' => @omniauth_credential.uid }
      with_blocked_credential @omniauth_credential do
        post :omniauth, params: { provider: @omniauth_credential.provider }
      end
      assert_redirected_to new_session_url
      assert_nil session_current_user, 'session'
      assert_match(/ blocked/, flash[:alert])
      assert_nil flash[:auth_redirect_url], 'no redirect URL in flash'
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end

  test "omniauth uses Credentials::OmniAuthUid.authenticate" do
    ActionController::Base.allow_forgery_protection = true
    begin
      omniauth_hash = { 'provider' => 'fail', 'uid' => 'fail' }
      request.env['omniauth.auth'] = omniauth_hash
      Credentials::OmniAuthUid.expects(:authenticate).at_least_once.
          with(omniauth_hash).returns @omniauth_credential.user
      post :omniauth, params: { provider: @omniauth_credential.provider }
      assert_equal @user, session_current_user, 'session'
      assert_redirected_to session_url
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end

  test "auth_controller? is true" do
    assert_equal true, @controller.auth_controller?
  end
end
