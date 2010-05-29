require 'action_controller'

# :nodoc: namespace
module MiniAuthRails

# :nodoc: namespace
module FacebookToken

# Mixed into ActiveController::Base
module ControllerMixin
  def self.included(base)
    base.send :extend, ControllerClassMethods
  end
end

# Methods here become ActiveController::Base class methods.
module ControllerClassMethods  
  # Authenticates users via Facebook OAuth2, using fbgraph_rails.
  #
  # The User model class must implement for_facebook_token. The controller
  # should obtain the Facebook token, using probes_facebook_access_token or
  # requires_facebook_access_token.
  def authenticates_using_facebook(options = {})
    include ControllerInstanceMethods
    before_filter :authenticate_using_facebook_access_token, options
  end
end

# Included in controllers that call authenticates_using_facebook.
module ControllerInstanceMethods
  def authenticate_using_facebook_access_token
    return true if current_user
    if access_token = current_facebook_access_token
      self.current_user = User.for_facebook_token access_token
    end
  end
  private :authenticate_using_facebook_access_token
end

ActionController::Base.send :include, ControllerMixin

end  # namespace MiniAuthRails::FacebookToken

end  # namespace MiniAuthRails
