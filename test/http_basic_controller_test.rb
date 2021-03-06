require_relative 'test_helper'

# Mock controller used for testing session handling.
class HttpBasicController < ApplicationController
  authenticates_using_http_basic

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
      render plain: "User: #{current_user.id}"
    else
      render plain: "No user"
    end
  end

  def bouncer
    bounce_to_http_basic
  end
end

class HttpBasicControllerTest < ActionController::TestCase
  setup do
    @user = users(:jane)
  end

  test "no user_id in session cookie or header" do
    get :show
    assert_response :success
    assert_equal 'nil', cookies['_authpwn_test_cuid']
    assert_equal 'No user', response.body
  end

  test "valid user_id in session cookie" do
    set_session_current_user @user
    get :show
    assert_response :success
    assert_equal 'nil', cookies['_authpwn_test_cuid']
    assert_equal 'No user', response.body
  end

  test "valid user credentials in header" do
    set_http_basic_user @user, 'pa55w0rd'
    get :show
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']

    jane_id = ActiveRecord::FixtureSet.identify :jane
    assert_equal "User: #{jane_id}", response.body
  end

  test "invalid user credentials in header" do
    set_http_basic_user @user, 'fail'
    get :show
    assert_equal 'nil', cookies['_authpwn_test_cuid']
    assert_equal 'No user', response.body
  end

  test "uses User.authenticate_signin" do
    signin = Session.new email: 'jane@gmail.com', password: 'fail'
    Session.expects(:new).at_least_once.with(
        email: 'jane@gmail.com', password: 'fail').returns signin
    User.expects(:authenticate_signin).at_least_once.with(signin).returns @user
    set_http_basic_user @user, 'fail'
    get :show
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']

    jane_id = ActiveRecord::FixtureSet.identify :jane
    assert_equal "User: #{jane_id}", response.body
  end

  test "reset user credentials in header" do
    set_http_basic_user @user, 'pa55w0rd'
    set_http_basic_user nil
    get :show
    assert_equal 'nil', cookies['_authpwn_test_cuid']
    assert_equal 'No user', response.body
  end

  test "mocked user credentials in header" do
    set_http_basic_user @user
    get :show
    assert_equal @user.id.to_s, cookies['_authpwn_test_cuid']

    jane_id = ActiveRecord::FixtureSet.identify :jane
    assert_equal "User: #{jane_id}", response.body
  end

  test "invalid authpwn_suid in session" do
    get :show, params: {}, session: { authpwn_suid: 'random@user.com' }
    assert_response :success
    assert_equal 'nil', cookies['_authpwn_test_cuid']
  end

  test "valid user bounced to http authentication" do
    set_http_basic_user @user
    get :bouncer
    assert_response :forbidden
    assert_select 'p.forbidden-logged-in-user'
    assert_select 'a[href="/session"][data-method="delete"]', 'sign out'
    # Make sure no layout was rendered.
    assert_select 'title', 0
    assert_select 'h1', 0
  end

  test "valid user bounced in json" do
    set_http_basic_user @user
    get :bouncer, format: 'json'
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_match(/not allowed/i, data['error'])
  end

  test "no user_id bounced to http authentication" do
    get :bouncer
    assert_response :unauthorized
    assert_equal 'Basic realm="Application"',
                 response.headers['WWW-Authenticate']
  end

  test "no user_id bounced in json" do
    get :bouncer, format: 'json'
    assert_response :unauthorized
    assert_equal 'Basic realm="Application"',
                 response.headers['WWW-Authenticate']
  end
end

