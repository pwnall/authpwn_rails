require File.expand_path('../test_helper', __FILE__)

require 'authpwn_rails/generators/templates/session_controller.rb'

# Run the tests in the generator, to make sure they pass.
require 'authpwn_rails/generators/templates/session_controller_test.rb'

# Tests the methods injected by authpwn_session_controller.
class SessionControllerApiTest < ActionController::TestCase
  tests SessionController
  
  setup do
    @user = users(:john)
  end
  
  test "show renders welcome without a user" do
    get :show
    assert_template :welcome
    assert_nil assigns(:current_user)
    assert_equal User.count, assigns(:user_count),
                 'welcome controller method not called'
  end
  
  test "show renders home with a user" do
    set_session_current_user @user
    get :show
    assert_template :home
    assert_equal @user, assigns(:current_user)
    assert_equal @user, assigns(:user), 'home controller method not called'
  end
  
  test "new redirects homes with a user" do
    set_session_current_user @user
    get :new
    assert_redirected_to session_url
  end     

  test "new renders login form without a user" do
    get :new
    assert_template :new
    assert_nil assigns(:current_user), 'current_user should not be set'
    assert assigns(:user).new_record?, 'user instance variable should be fresh'
  
    assert_select 'form' do
      assert_select 'input#user_email'
      assert_select 'input#user_password'
      assert_select 'input[type=submit]'
    end
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
