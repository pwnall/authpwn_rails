require_relative 'test_helper'

# Mock controller used for testing session handling.
class HttpTokenController < ApplicationController
  authenticates_using_http_token

  def show
    if current_user
      render text: "User: #{current_user.id}"
    else
      render text: "No user"
    end
  end

  def bouncer
    bounce_to_http_token
  end
end

class HttpTokenControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
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
    set_http_token_user @user
    get :show
    assert_equal @user, assigns(:current_user)
    assert_equal nil, session_current_user,
        'Token authentication should not update the session'

    john_id = ActiveRecord::FixtureSet.identify :john
    assert_equal "User: #{john_id}", response.body
  end

  test "invalid token in header" do
    set_http_token_user @user
    Tokens::Api.where(user_id: @user.id).destroy_all
    get :show
    assert_nil assigns(:current_user)
    assert_equal 'No user', response.body
  end

  test "uses Tokens::Api.authenticate" do
    Tokens::Api.expects(:authenticate).at_least_once.with('ap1c0d3').
        returns @user
    set_http_token_user @user, 'ap1c0d3'
    get :show
    assert_equal @user, assigns(:current_user)
    assert_equal nil, session_current_user,
        'Token authentication should not update the session'

    john_id = ActiveRecord::FixtureSet.identify :john
    assert_equal "User: #{john_id}", response.body
  end

  test "reset user credentials in header" do
    set_http_token_user @user
    set_http_token_user nil
    get :show
    assert_nil assigns(:current_user)
    assert_equal 'No user', response.body
  end

  test "newly created API token in header" do
    user = users(:jane)
    set_http_token_user user
    get :show
    assert_equal user, assigns(:current_user)
    assert_equal nil, session_current_user,
        'Token authentication should not update the session'

    jane_id = ActiveRecord::FixtureSet.identify :jane
    assert_equal "User: #{jane_id}", response.body
  end

  test "invalid authpwn_suid in session" do
    get :show, {}, authpwn_suid: 'random@user.com'
    assert_response :success
    assert_nil assigns(:current_user)
  end

  test "valid user bounced to http authentication" do
    set_http_token_user @user
    get :bouncer
    assert_response :forbidden
    assert_template 'session/forbidden'
    assert_select 'a[href="/session"][data-method="delete"]', 'sign out'
    # Make sure no layout was rendered.
    assert_select 'title', 0
    assert_select 'h1', 0
  end

  test "valid user bounced in json" do
    set_http_token_user @user
    get :bouncer, format: 'json'
    assert_response :ok
    data = ActiveSupport::JSON.decode response.body
    assert_match(/not allowed/i, data['error'])
  end

  test "no user_id bounced to http authentication" do
    get :bouncer
    assert_response :unauthorized
    assert_equal 'Token realm="Application"',
                 response.headers['WWW-Authenticate']
  end

  test "no user_id bounced in json" do
    get :bouncer, format: 'json'
    assert_response :unauthorized
    assert_equal 'Token realm="Application"',
                 response.headers['WWW-Authenticate']
  end
end

