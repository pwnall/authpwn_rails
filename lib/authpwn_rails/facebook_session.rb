require 'action_controller'

# :nodoc: add authenticates_using_facebook
class ActionController::Base  
  # Authenticates users via Facebook OAuth2, using fbgraph_rails.
  #
  # The User model class must implement for_facebook_token. The controller
  # should obtain the Facebook token, using probes_facebook_access_token or
  # requires_facebook_access_token.
  def self.authenticates_using_facebook(options = {})
    include AuthpwnRails::FacebookControllerInstanceMethods
    before_filter :authenticate_using_facebook_access_token, options
  end
end  # module AuthpwnRails::FacebookExtensions::ControllerClassMethods

# :nodoc: namespace
module AuthpwnRails

# Included in controllers that call authenticates_using_facebook.
module FacebookControllerInstanceMethods
  def authenticate_using_facebook_access_token
    return true if current_user
    if access_token = current_facebook_access_token
      self.current_user = User.for_facebook_token access_token
      # NOTE: nixing the token from the session so the user won't be logged on
      #       immediately after logging off
      self.current_facebook_access_token = nil
    end
  end
  private :authenticate_using_facebook_access_token
end  # module AuthpwnRails::FacebookControllerInstanceMethods

end  # namespace AuthpwnRails
