require 'active_model'
require 'active_support'

# :nodoc: namespace
module Authpwn

# :nodoc: namespace
module UserExtensions
  
# Augments the User model with Facebook-related virtual attributes.
module FacebookFields
  extend ActiveSupport::Concern
  
  module ClassMethods
    # The user that owns a given Facebook OAuth2 token.
    #
    # A new user will be created if the token doesn't belong to any user. This
    # is the case for a new visitor.
    def for_facebook_token(access_token)
      Credentials::Facebook.for(access_token).user
    end
    
    # The user who has a certain e-mail, or nil if the e-mail is unclaimed.
    def with_facebook_uid(facebook_uid)
      credential = Credentials::Facebook.where(name: facebook_uid).
                                         includes(:user).first
      credential && credential.user
    end
  end
  
  # Credentials::Facebook instance associated with this user.
  def facebook_credential
    credentials.find { |c| c.instance_of?(Credentials::Facebook) }
  end
  
  # FBGraph client loaded with this access token.
  #
  # Returns nil if this user has no Facebook credential.
  def facebook_client
    credential = self.facebook_credential
    credential && credential.facebook_client
  end

  # The facebook user ID from the user's Facebook credential.
  #
  # Returns nil if this user has no Facebook credential.
  def facebook_uid
    credential = self.facebook_credential
    credential && credential.facebook_uid
  end
  
  # The facebook OAuth2 access token from the user's Facebook credential.
  #
  # Returns nil if this user has no Facebook credential.
  def facebook_access_token
    credential = self.facebook_credential
    credential && credential.access_token
  end
end  # module Authpwn::UserExtensions::FacebookFields
  
end  # module Authpwn::UserExtensions
  
end  # module Authpwn
