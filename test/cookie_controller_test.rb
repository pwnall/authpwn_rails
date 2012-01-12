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
  
  def bouncer
    bounce_user
  end
end

class CookieControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
  end

  test "no user_id in session" do
    get :show
    assert_response :success
    assert_nil assigns(:current_user)
    assert_equal 'No user', response.body
  end
  
  test "valid user_id in session" do
    set_session_current_user @user
    get :show
    assert_response :success
    assert_equal @user, assigns(:current_user)
    assert_equal "User: #{ActiveRecord::Fixtures.identify(:john)}",
                 response.body
  end
  
  test "invalid user_pid in session" do
    get :show, {}, :current_user_pid => 'random@user.com'
    assert_response :success
    assert_nil assigns(:current_user)
  end
  
  test "valid user_id bounced" do
    set_session_current_user @user
    get :bouncer
    assert_response :forbidden
    assert_template 'session/forbidden'
    assert_select 'a[href="/session"][data-method="delete"]', 'Log out'
  end

  test "valid user_id bounced in json" do
    set_session_current_user @user
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
end
