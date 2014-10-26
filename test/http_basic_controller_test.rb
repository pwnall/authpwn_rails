require File.expand_path('../test_helper', __FILE__)

# Mock controller used for testing session handling.
class HttpBasicController < ApplicationController
  authenticates_using_http_basic

  def show
    if current_user
      render text: "User: #{current_user.id}"
    else
      render text: "No user"
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
    assert_nil assigns(:current_user)
    assert_equal 'No user', response.body
  end

  test "valid user_id in session cookie" do
    set_session_current_user @user
    get :show
    assert_response :success
    assert_nil assigns(:current_user)
    assert_equal 'No user', response.body
  end

  test "valid user credentials in header" do
    set_http_basic_user @user, 'pa55w0rd'
    get :show
    assert_equal @user, assigns(:current_user)

    jane_id = ActiveRecord::FixtureSet.identify :jane
    assert_equal "User: #{jane_id}", response.body
  end

  test "invalid user credentials in header" do
    set_http_basic_user @user, 'fail'
    get :show
    assert_nil assigns(:current_user)
    assert_equal 'No user', response.body
  end

  test "uses User.authenticate_signin" do
    signin = Session.new email: 'jane@gmail.com', password: 'fail'
    Session.expects(:new).at_least_once.with(
        email: 'jane@gmail.com', password: 'fail').returns signin
    User.expects(:authenticate_signin).at_least_once.with(signin).returns @user
    set_http_basic_user @user, 'fail'
    get :show
    assert_equal @user, assigns(:current_user)

    jane_id = ActiveRecord::FixtureSet.identify :jane
    assert_equal "User: #{jane_id}", response.body
  end


  test "reset user credentials in header" do
    set_http_basic_user @user, 'pa55w0rd'
    set_http_basic_user nil
    get :show
    assert_nil assigns(:current_user)
    assert_equal 'No user', response.body
  end

  test "mocked user credentials in header" do
    set_http_basic_user @user
    get :show
    assert_equal @user, assigns(:current_user)

    jane_id = ActiveRecord::FixtureSet.identify :jane
    assert_equal "User: #{jane_id}", response.body
  end

  test "invalid user_pid in session" do
    get :show, {}, current_user_pid: 'random@user.com'
    assert_response :success
    assert_nil assigns(:current_user)
  end

  test "valid user bounced to http authentication" do
    set_http_basic_user @user
    get :bouncer
    assert_response :forbidden
    assert_template 'session/forbidden'
    assert_select 'a[href="/session"][data-method="delete"]', 'sign out'
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

