require File.expand_path('../test_helper', __FILE__)

# Mock controller used for testing session handling.
class FacebookController < ApplicationController
  authenticates_using_session
  probes_facebook_access_token
  authenticates_using_facebook
  
  def show
    if current_user
      render :text => "User: #{current_user.id}"
    else
      render :text => "No user"
    end
  end
end

class FacebookControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
    @new_token = 'facebook:new_token|boom'
  end

  test "no facebook token" do
    get :show
    assert_response :success
    assert_nil assigns(:current_user)
  end
  
  test "facebook token for existing user" do
    set_session_current_facebook_token facebook_tokens(:john).access_token
    get :show, {}
    assert_response :success
    assert_equal @user, assigns(:current_user)
  end
  
  test "new facebook token" do    
    set_session_current_facebook_token @new_token
    get :show, {}
    assert_response :success
    assert !(@user == assigns(:current_user))
  end
end
