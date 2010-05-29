require File.expand_path('../test_helper', __FILE__)
require 'action_controller'

# Mock controller used for testing session handling.
class FacebookController < ActionController::Base
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
    @first_user = User.mock_user
    @first_user.token = 'facebook:token'
    @new_token = 'facebook:new_token'
  end

  test "no facebook token" do
    get :show
    assert_response :success
    assert_nil assigns(:current_user)
  end
  
  test "facebook token for existing user" do
    set_session_current_facebook_token @first_user.token
    get :show, {}
    assert_response :success
    assert_equal @first_user, assigns(:current_user)
  end
  
  test "new facebook token" do    
    set_session_current_facebook_token @new_token
    get :show, {}
    assert_response :success
    assert !(@first_user == assigns(:current_user))
    assert_equal @new_token, assigns(:current_user).token
  end
end
