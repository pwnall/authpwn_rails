require File.expand_path('../test_helper', __FILE__)
require 'action_controller'

# Mock controller used for testing session handling.
class SessionController < ActionController::Base
  authenticates_using_session
    
  def show
    if current_user
      render :text => "User: #{current_user.id}"
    else
      render :text => "No user"
    end
  end
end

class SessionControllerTest < ActionController::TestCase
  setup do
    @first_user = User.mock_user
  end

  test "no user_id in session" do
    get :show
    assert_response :success
    assert_nil assigns(:current_user)
    assert_equal 'No user', response.body
  end
  
  test "valid user_id in session" do
    set_session_current_user @first_user
    get :show, {}
    assert_response :success
    assert_equal @first_user, assigns(:current_user)
    assert_equal 'User: 1', response.body
  end
  
  test "invalid user_id in session" do
    get :show, {}, :current_user_id => 999
    assert_response :success
    assert_nil assigns(:current_user)
  end
end
