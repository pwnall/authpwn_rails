require 'action_controller'

# :nodoc: namespace
module AuthpwnRails

# :nodoc: namespace
module Session

# Mixed into ActiveController::Base
module ControllerMixin
  def self.included(base)
    base.send :extend, ControllerClassMethods
  end
end

# Methods here become ActiveController::Base class methods.
module ControllerClassMethods  
  # Keeps track of the currently authenticated user via the session. 
  #
  # Assumes the existence of a User model. A bare ActiveModel model will do the
  # trick. Model instances must implement id, and the model class must implement
  # find_by_id.
  def authenticates_using_session(options = {})
    include ControllerInstanceMethods
    before_filter :authenticate_using_session, options   
  end
  
  # Turns the current controller into the session processing controller.
  #
  # Right now, this should be called from SessionController. The controller name
  # is hardwired in other parts of the implementation.
  def authpwn_session_controller
    include SessionControllerInstanceMethods
    authenticates_using_session
  end
end

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
end

# Included in controllers that call authenticates_using_session.
module SessionControllerInstanceMethods
  # GET /session/new
  def new
    @user = User.new
    @redirect_url = flash[:auth_redirect_url]
    redirect_to session_url if current_user
  end

  # GET /session
  def show
    @user = current_user || User.new
    if @user.new_record?
      welcome
      unless performed?
        respond_to do |format|
          format.html { render :action => :welcome }
          format.json { render :json => {} }
        end
      end
    else      
      home
      unless performed?
        respond_to do |format|
          format.html { render :action => :home }
          format.json do
            render :json => { :user => @user.serializable_hash,
                              :csrf => form_authenticity_token }
          end
        end
      end
    end
  end
  
  # POST /session
  def create
    @user = User.new params[:user]
    @redirect_url = params[:redirect_url] || session_url
    self.current_user =
        User.find_by_email_and_password @user.email, @user.password
        
    respond_to do |format|
      if current_user
        format.html { redirect_to @redirect_url }
        format.json do
          render :json => { :user => current_user.serializable_hash,
                            :csrf => form_authenticity_token }
        end
      else
        notice = 'Invalid e-mail or password'
        format.html do
          redirect_to new_session_url, :flash => {
            :notice => notice, :auth_redirect_url => @redirect_url }
        end
        format.json { render :json => { :error => notice} }
      end
    end
  end

  # DELETE /session
  def destroy
    self.current_user = nil
    respond_to do |format|
      format.html { redirect_to session_url }
      format.json { head :ok }
    end
  end

  # Hook for setting up the home view.
  def home
  end
  private :home
  
  # Hook for setting up the welcome view.
  def welcome
  end
  private :welcome
end  # module Authpwn::Session::SessionControllerInstanceMethods

ActionController::Base.send :include, ControllerMixin


# :nodoc: add session modification
class ActionController::TestCase
  # Sets the authenticated user in the test session.
  def set_session_current_user(user)
    request.session[:current_user_pid] = user ? user.to_param : nil
  end
  
  # The authenticated user in the test session.
  def session_current_user
    return nil unless user_param = request.session[:current_user_pid]
    User.find_by_param user_param
  end
end

end  # namespace AuthpwnRails::Session

end  # namespace AuthpwnRails
