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
end

# Included in controllers that call authenticates_using_session.
module SessionControllerInstanceMethods
  # GET /session/new
  def new
    @user = User.new
    redirect_to session_url if current_user
  end

  # GET /session
  def show
    @user = current_user || User.new
    if @user.new_record?
      welcome
      render :action => :welcome
    else      
      home
      render :action => :home
    end
  end
  
  # POST /session
  def create
    @user = User.new params[:user]
    self.current_user =
        User.find_by_email_and_password @user.email, @user.password
        
    respond_to do |format|
      if current_user
        format.html { redirect_to session_url }
      else
        format.html do
          redirect_to new_session_url, :notice => 'Invalid e-mail or password'
        end
      end
    end
  end

  # DELETE /session
  def destroy
    self.current_user = nil
    redirect_to session_url
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
