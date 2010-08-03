require File.expand_path('../test_helper', __FILE__)

require File.expand_path('../../app/controllers/session_controller', __FILE__)

class SessionControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
  end
  
  test "show renders welcome without a user" do
    get :show
    assert_template :welcome
    assert_nil assigns(:current_user)
  end
  
  test "show renders home with a user" do
    set_session_current_user @user
    get :show
    assert_template :home
    assert_equal @user, assigns(:current_user)
  end
  
  test "create logs in with good account details" do
    post :create, :user => { :email => @user.email, :password => 'password' }
    assert_redirected_to session_url
    assert_equal @user, assigns(:current_user), 'instance variable'
    assert_equal @user, session_current_user, 'session'
  end
  
  test "create does not log in with bad password" do
    post :create, :user => { :email => @user.email, :password => 'fail' }
    assert_redirected_to session_url
    assert_nil assigns(:current_user), 'instance variable'
    assert_nil session_current_user, 'session'
  end

  test "create does not log in with bad e-mail" do
    post :create, :user => { :email => 'nobody@gmail.com', :password => 'no' }
    assert_redirected_to session_url
    assert_nil assigns(:current_user), 'instance variable'
    assert_nil session_current_user, 'session'
  end

  test "logout" do
    set_session_current_user @user
    delete :destroy
    
    assert_redirected_to session_url
    assert_nil assigns(:current_user)
  end  
end
