require File.expand_path('../test_helper', __FILE__)

# Mock controller used for testing session handling.
class CookieController < ApplicationController
  authenticates_using_session

  def show
    if current_user
      render :text => "User: #{current_user.id}"
    else
      render :text => "No user"
    end
  end

  def update
    set_session_current_user params[:ex_uid]
  end

  def bouncer
    bounce_user
  end
end

class CookieControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
    @token = credentials(:john_session_token)
  end

  test "no suid in session" do
    get :show
    assert_response :success
    assert_nil assigns(:current_user)
    assert_equal 'No user', response.body
  end

  test "valid suid in session" do
    request.session[:authpwn_suid] = @token.suid
    get :show
    assert_response :success
    assert_equal @user, assigns(:current_user)
    assert_equal "User: #{ActiveRecord::Fixtures.identify(:john)}",
                 response.body
  end

  test "valid suid in session does not refresh very recent session" do
    request.session[:authpwn_suid] = @token.suid
    @token.updated_at = Time.now - 5.minutes
    @token.save!
    get :show
    assert_response :success
    assert_equal @user, assigns(:current_user)
    assert_operator @token.reload.updated_at, :<=, Time.now - 5.minutes
  end

  test "valid suid in session refreshes recent session" do
    request.session[:authpwn_suid] = @token.suid
    @token.updated_at = Time.now - 5.minutes
    @token.save!
    get :show
    assert_response :success
    assert_equal @user, assigns(:current_user)
    assert_operator @token.reload.updated_at, :<=, Time.now - 5.minutes
  end

  test "valid suid in session is discarded if the session is old" do
    request.session[:authpwn_suid] = @token.suid
    @token.updated_at = Time.now - 5.minutes
    @token.save!
    get :show
    assert_response :success
    assert_nil assigns(:current_user), 'current_user set'
    assert_nil Credential.with_code(@token.suid), 'session token not destroyed'
  end

  test "invalid suid in session" do
    request.session[:authpwn_suid] = @token.suid
    @token.destroy
    get :show
    assert_response :success
    assert_nil assigns(:current_user)
  end

  test "valid user_id bounced" do
    request.session[:authpwn_suid] = @token.suid
    get :bouncer
    assert_response :forbidden
    assert_template 'session/forbidden'
    assert_select 'a[href="/session"][data-method="delete"]', 'Log out'
  end

  test "valid user_id bounced in json" do
    request.session[:authpwn_suid] = @token.suid
    get :bouncer, :format => 'json'
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_match(/not allowed/i, data['error'])
  end

  test "no user_id bounced" do
    get :bouncer
    assert_response :forbidden
    assert_template 'session/forbidden'
    assert_equal bouncer_cookie_url, flash[:auth_redirect_url]

    assert_select 'script', %r/.*window.location.*#{new_session_path}.*/
  end

  test "no user_id bounced in json" do
    get :bouncer, :format => 'json'
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_match(/sign in/i, data['error'])
  end

  test "auth_controller? is false" do
    assert_equal false, @controller.auth_controller?
  end
end
