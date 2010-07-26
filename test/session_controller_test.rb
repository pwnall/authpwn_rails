require File.expand_path('../test_helper', __FILE__)

require File.expand_path('../../app/controllers/session_controller', __FILE__)

class SessionControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
  end

  test "logout" do
    set_session_current_user @user
    delete :destroy
    
    assert_redirected_to root_url
    assert_nil assigns(:current_user)
  end  
end
