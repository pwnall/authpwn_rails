require 'action_controller'

# :nodoc: adds authenticates_using_session
class ActionController::Base
  # Keeps track of the currently authenticated user via the session. 
  #
  # Assumes the existence of a User model. A bare ActiveModel model will do the
  # trick. Model instances must implement id, and the model class must implement
  # find_by_id.
  def self.authenticates_using_session(options = {})
    include Authpwn::ControllerInstanceMethods
    before_filter :authenticate_using_session, options   
  end  
end

# :nodoc: namespace
module Authpwn

# Included in controllers that call authenticates_using_session.
module ControllerInstanceMethods
  attr_reader :current_user
  
  def current_user=(user)
    @current_user = user
    if user
      session[:current_user_pid] = user.to_param
    else
      session.delete :current_user_pid
    end
  end  

  def authenticate_using_session
    return true if current_user
    user_param = session[:current_user_pid]
    user = user_param && User.find_by_param(user_param)
    self.current_user = user if user
  end
  private :authenticate_using_session
  
  # Inform the user that their request is forbidden.
  #
  # If a user is logged on, this renders the session/forbidden view with a HTTP
  # 403 code.
  # 
  # If no user is logged in, the user is redirected to session/new, and the
  # current request's URL is saved in flash[:auth_redirect_url].
  def bounce_user(redirect_url = request.url)
    # NOTE: this is tested in CookieControllerTest
    respond_to do |format|
      format.html do
        @redirect_url = redirect_url
        if current_user
          render 'session/forbidden', :status => :forbidden
        else
          flash[:auth_redirect_url] = redirect_url
          render 'session/forbidden', :status => :forbidden
        end
      end
      format.json do
        message = current_user ? "You're not allowed to access that" :
                                 'Please sign in'
        render :json => { :error => message }
      end
    end
  end
end  # module Authpwn::ControllerInstanceMethods

end  # namespace Authpwn
