require 'action_controller'
require 'active_record'

# :nodoc: namespace
module AuthpwnRails

# :nodoc: namespace
module FacebookExtensions


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
end  # module AuthpwnRails::FacebookExtensions::ControllerClassMethods


# Included in controllers that call authenticates_using_facebook.
module ControllerInstanceMethods
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
end  # module AuthpwnRails::FacebookExtensions::ControllerInstanceMethods

ActionController::Base.send :include, ControllerMixin


# Mixed into ActiveRecord::Base
module ModelMixin
  def self.included(base)
    base.send :extend, ModelClassMethods
  end
end


# Methods here become ActiveRecord::Base class methods.
module ModelClassMethods
  # Extends the model with all that it needs to be PwnAuth's user model.
  def pwnauth_facebook_token_model
    # The user whose token this is.
    belongs_to :user, :inverse_of => :facebook_token
    validates :user, :presence => true
    
    # A unique ID on the Facebook site for the user owning this token.
    validates :external_uid, :length => 1..32, :presence => true
  
    # The OAuth2 access token.
    validates :access_token, :length => 1..128, :presence => true

    extend ModelMetaclassMethods
    include ModelInstanceMethods
  end
end  # module AuthpwnRails::UserModel::ModelClassMethods


# Included in the metaclass of models that call pwnauth_facebook_token_model.
module ModelMetaclassMethods
  # Finds or creates the model containing a token.
  #
  # If a model for the same user exists, the model is updated with the given
  # token. Otherwise, a new model will be created, together with a user.
  def for(access_token)
    uid = uid_from_token access_token
    token = self.where(:external_uid => uid.to_str).first
    if token
      token.access_token = access_token
    else
      token = FacebookToken.new :external_uid => uid,
                                :access_token => access_token
      token.user = User.create_with_facebook_token token
    end
    token.save!
    token
  end
  
  # Extracts the Facebook user ID from a OAuth2 token.
  #
  # This is a hack. It works based on the current format, but might break at any
  # time. Hopefully, we'll eventually have an official way of pulling the UID
  # out of an OAuth2 token.
  def uid_from_token(access_token)
    access_token.split('|')[1].split('-').last
  end
end  # module AuthpwnRails::UserModel::ModelMetaclassMethods


# Included in models that call pwnauth_user_model.
module ModelInstanceMethods
  # FBGraph client loaded with this access token.
  def facebook_client
    @client ||= FBGraphRails.fbclient(access_token)    
  end  
end  # module AuthpwnRails::UserModel::ModelInstanceMethods

ActiveRecord::Base.send :include, ModelMixin

end  # namespace AuthpwnRails::FacebookExtensions

end  # namespace AuthpwnRails
