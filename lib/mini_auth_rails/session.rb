require 'action_controller'

# :nodoc: namespace
module MiniAuthRails

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
end

# Included in controllers that call authenticates_using_session.
module ControllerInstanceMethods
  attr_reader :current_user
  
  def current_user=(user)
    @current_user = user
    session[:current_user_id] = user.id
  end  

  def authenticate_using_session
    return true if current_user
    user_id = session[:current_user_id]
    user = user_id && User.find_by_id(user_id)
    self.current_user = user if user
  end
  private :authenticate_using_session  
end

ActionController::Base.send :include, ControllerMixin

# :nodoc: add session modification
class ActionController::TestCase
  # Sets the authenticated user in the test session.
  def set_session_current_user(user)
    request.session[:current_user_id] = user ? user.id : nil
  end
end

end  # namespace MiniAuthRails::Session

end  # namespace MiniAuthRails
