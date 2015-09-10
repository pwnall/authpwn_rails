require File.expand_path('../test_helper', __FILE__)

# Mock controller used for testing session handling.
class CookieController < ApplicationController
  authenticates_using_session except: :update

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

  def show
    if current_user
      render text: "User: #{current_user.id}"
    else
      render text: "No user"
    end
  end

  def update
    if params[:exuid].blank?
      set_session_current_user nil
    else
      set_session_current_user User.with_param(params[:exuid]).first
    end
    render text: ''
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
    assert_equal 'nil', cookies['_authpwn_test_cuid']
    assert_equal 'No user', response.body
  end

  test "valid suid in session" do
    request.session[:authpwn_suid] = @token.suid
    get :show
    assert_response :success
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']
    john_id =  ActiveRecord::FixtureSet.identify :john
    assert_equal "User: #{john_id}", response.body
  end

  test "valid suid in session does not refresh very recent session" do
    request.session[:authpwn_suid] = @token.suid
    @token.updated_at = Time.now - 5.minutes
    @token.save!
    get :show
    assert_response :success
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']
    assert_operator @token.reload.updated_at, :<=, Time.now - 5.minutes
  end

  test "valid suid in session refreshes recent session" do
    request.session[:authpwn_suid] = @token.suid
    @token.updated_at = Time.now - 5.minutes
    @token.save!
    get :show
    assert_response :success
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']
    assert_operator @token.reload.updated_at, :<=, Time.now - 5.minutes
  end

  test "valid suid in session is discarded if the session is old" do
    request.session[:authpwn_suid] = @token.suid
    @token.updated_at = Time.now - 3.months
    @token.save!
    get :show
    assert_response :success
    assert_equal 'nil', cookies['_authpwn_test_cuid']
    assert_nil Tokens::Base.with_code(@token.suid).first,
               'session token not destroyed'
  end

  test "invalid suid in session" do
    request.session[:authpwn_suid] = @token.suid
    @token.destroy
    get :show
    assert_response :success
    assert_equal 'nil', cookies['_authpwn_test_cuid']
  end

  test "set_session_current_user creates new token by default" do
    assert_difference 'Credential.count', 1 do
      put :update, params: { exuid: @user.exuid }
    end
    assert_response :success
    assert_not_equal @token.suid, request.session[:authpwn_suid]

    get :show
    assert_response :success
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']
  end

  test "set_session_current_user reuses existing token when suitable" do
    request.session[:authpwn_suid] = @token.suid
    assert_no_difference 'Credential.count', 'existing token not reused' do
      put :update, params: { exuid: @user.exuid }
    end
    assert_response :success
    assert_equal @token.suid, request.session[:authpwn_suid]

    get :show
    assert_response :success
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']
  end

  test "set_session_current_user refreshes old token" do
    @token.updated_at = Time.now - 1.day
    request.session[:authpwn_suid] = @token.suid
    assert_no_difference 'Credential.count', 'existing token not reused' do
      put :update, params: { exuid: @user.exuid }
    end
    assert_response :success
    assert_operator @token.reload.updated_at, :>=, Time.now - 1.hour,
        'Old token not refreshed'

    get :show
    assert_response :success
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']
  end

  test "set_session_current_user creates new token if old token is invalid" do
    @token.destroy
    request.session[:authpwn_suid] = @token.suid
    assert_difference 'Credential.count', 1, 'session token not created' do
      put :update, params: { exuid: @user.exuid }
    end
    assert_response :success
    assert_not_equal @token.suid, request.session[:authpwn_suid]

    get :show
    assert_response :success
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']
  end

  test "set_session_current_user switches users correctly" do
    old_token = credentials(:jane_session_token)
    request.session[:authpwn_suid] = old_token.suid
    assert_no_difference 'Credential.count',
        "old user's token not destroyed or no new token created" do
      put :update, params: { exuid: @user.exuid }
    end
    assert_response :success
    assert_nil Tokens::Base.with_code(old_token.suid).first,
               "old user's token not destroyed"
    assert_not_equal @token.suid, request.session[:authpwn_suid]

    get :show
    assert_response :success
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']
  end

  test "set_session_current_user reuses token when switching users" do
    @token.destroy
    request.session[:authpwn_suid] = credentials(:jane_session_token).suid
    assert_no_difference 'Credential.count',
        "old user's token not destroyed or new user's token not created" do
      put :update, params: { exuid: @user.exuid }
    end
    assert_response :success

    get :show
    assert_response :success
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']
  end

  test "set_session_current_user logs off a user correctly" do
    request.session[:authpwn_suid] = @token.suid
    assert_difference 'Credential.count', -1, 'token not destroyed' do
      put :update, params: { exuid: '' }
    end
    assert_response :success
    assert_nil request.session[:authpwn_suid]
    assert_equal 'nil', cookies['_authpwn_test_cuid']

    get :show
    assert_response :success
    assert_equal 'nil', cookies['_authpwn_test_cuid']
  end

  test "set_session_current_user behaves when no user is logged off" do
    assert_no_difference 'Credential.count' do
      put :update, params: { exuid: '' }
    end
    assert_response :success
    assert_nil request.session[:authpwn_suid]
    assert_equal 'nil', cookies['_authpwn_test_cuid']
  end

  test "valid user_id bounced" do
    request.session[:authpwn_suid] = @token.suid
    get :bouncer
    assert_response :forbidden
    assert_select 'p.forbidden-logged-in-user'
    assert_select 'a[href="/session"][data-method="delete"]', 'sign out'
  end

  test "valid user_id bounced in json" do
    request.session[:authpwn_suid] = @token.suid
    get :bouncer, format: 'json'
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_match(/not allowed/i, data['error'])
  end

  test "no user_id bounced" do
    get :bouncer
    assert_response :forbidden
    assert_equal bouncer_cookie_url, flash[:auth_redirect_url]
    assert_select 'script[type="text/javascript"]',
        %r/.*window.location.*#{new_session_path}.*/
  end

  test "no user_id bounced in json" do
    get :bouncer, format: 'json'
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_match(/sign in/i, data['error'])
  end

  test "auth_controller? is false" do
    assert_equal false, @controller.auth_controller?
  end
end
