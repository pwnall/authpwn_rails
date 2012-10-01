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

  # True for controllers belonging to the authentication implementation.
  #
  # Controllers that return true here are responsible for performing their own
  # authorization.
  def auth_controller?
    false
  end
end

# :nodoc: namespace
module Authpwn

# Included in controllers that call authenticates_using_session.
module ControllerInstanceMethods
  include Authpwn::CurrentUser

  # Sets up the session so that it will authenticate the given user.
  def set_session_current_user(user)
    # Try to reuse existing sessions.
    if session[:authpwn_suid]
      token = Tokens::SessionUid.with_code session[:authpwn_suid]
      if token
        if token.user == user
          token.touch
          return user
        else
          token.destroy
        end
      end
    end
    if user
      session[:authpwn_suid] = Tokens::SessionUid.random_for(user,
          request.remote_ip, request.user_agent).suid
    else
      session.delete :authpwn_suid
    end
    self.current_user = user
  end

  # Filter that implements authenticates_using_session.
  #
  # If your ApplicationController contains authenticates_using_session, you
  # can opt out in individual controllers using skip_before_filter.
  #
  #     skip_before_filter :authenticate_using_session
  def authenticate_using_session
    return if current_user
    session_uid = session[:authpwn_suid]
    user = session_uid && Tokens::SessionUid.authenticate(session_uid)
    self.current_user = user if user && !user.instance_of?(Symbol)
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
