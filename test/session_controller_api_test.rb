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
  
  test "new renders redirect_url when present in flash" do
    url = 'http://authpwn.redirect.url'    
    get :new, {}, {}, { :auth_redirect_url => url }
    assert_template :new
    assert_equal url, assigns(:redirect_url), 'redirect_url should be set'
    assert_select 'form' do
      assert_select "input[name=redirect_url][value=#{url}]"
    end
  end
  
  test "create logs in with good account details" do
    post :create, :user => { :email => @user.email, :password => 'password' }
    assert_redirected_to session_url
    assert_equal @user, assigns(:current_user), 'instance variable'
    assert_equal @user, session_current_user, 'session'
  end

  test "create by json logs in with good account details" do
    post :create, :user => { :email => @user.email, :password => 'password' },
                  :format => 'json'
    data = ActiveSupport::JSON.decode response.body
    assert_equal @user.email, data['user']['email']
    assert_equal @user, assigns(:current_user), 'instance variable'
    assert_equal @user, session_current_user, 'session'
  end
  
  test "create redirects properly with good account details" do
    url = 'http://authpwn.redirect.url'
    post :create, :user => { :email => @user.email, :password => 'password' },
                  :redirect_url => url
    assert_redirected_to url
  end
  
  test "create does not log in with bad password" do
    post :create, :user => { :email => @user.email, :password => 'fail' }
    assert_redirected_to new_session_url
    assert_nil assigns(:current_user), 'instance variable'
    assert_nil session_current_user, 'session'
    assert_not_nil flash[:notice]
  end

  test "create by json does not log in with bad password" do
    post :create, :user => { :email => @user.email, :password => 'fail' },
                  :format => 'json'
    data = ActiveSupport::JSON.decode response.body
    assert_match(/invalid/i , data['error'])
    assert_nil assigns(:current_user), 'instance variable'
    assert_nil session_current_user, 'session'
  end
  
  test "create maintains redirect_url for bad logins" do
    url = 'http://authpwn.redirect.url'
    post :create, :user => { :email => @user.email, :password => 'fail' },
                  :redirect_url => url
    assert_redirected_to new_session_url
    assert_not_nil flash[:notice]
    assert_equal url, flash[:auth_redirect_url]
  end

  test "create does not log in with bad e-mail" do
    post :create, :user => { :email => 'nobody@gmail.com', :password => 'no' }
    assert_redirected_to new_session_url
    assert_nil assigns(:current_user), 'instance variable'
    assert_nil session_current_user, 'session'
    assert_not_nil flash[:notice]
  end

  test "logout" do
    set_session_current_user @user
    delete :destroy
    
    assert_redirected_to session_url
    assert_nil assigns(:current_user)
  end
  
  test "logout by json" do
    set_session_current_user @user
    delete :destroy, :format => 'json'
    
    assert_response :ok
    assert_nil assigns(:current_user)
  end
end
