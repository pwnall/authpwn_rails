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

class UserWithFb2 < User
  include Authpwn::UserExtensions::FacebookFields
end

class FacebookControllerTest < ActionController::TestCase
  setup do
    @old_user_class = ::User
    ::User = UserWithFb2
    
    @user = users(:john)
    @new_token = 'facebook:new_token|boom'
  end
  
  teardown do
    ::User = @old_user_class
  end

  test "no facebook token" do
    get :show
    assert_response :success
    assert_nil assigns(:current_user)
  end
  
  test "facebook token for existing user" do
    flexmock(Credentials::Facebook).should_receive(:uid_from_token).
        with(credentials(:john_facebook).key).
        and_return(credentials(:john_facebook).facebook_uid)
    set_session_current_facebook_token credentials(:john_facebook).key
    get :show, {}
    assert_response :success
    assert_equal @user, assigns(:current_user)
  end
  
  test "new facebook token" do    
    set_session_current_facebook_token @new_token
    flexmock(Credentials::Facebook).should_receive(:uid_from_token).
        with(@new_token).and_return('12345678')
    get :show, {}
    assert_response :success
    assert_not_equal @user, assigns(:current_user)
  end
end
