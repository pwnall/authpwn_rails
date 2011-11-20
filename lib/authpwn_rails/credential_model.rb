require 'active_support'

# :nodoc: namespace
module Authpwn

# Included by the model class that represents facebook tokens.
#
# Parts of the codebase assume the model will be named Credential.
module CredentialModel
  extend ActiveSupport::Concern

  included do
    # The user whose token this is.
    belongs_to :user, :inverse_of => :credentials
    validates :user, :presence => true
    
    # Name that can be used to find the token.
    validates :name, :length => { :in => 1..32, :allow_nil => true },
                     :uniqueness => { :scope => [:type], :allow_nil => true }
  
    # Secret information associated with the token.
    serialize :key, JSON
  end

  # Included in the metaclass of models that call pwnauth_facebook_token_model.
  module ClassMethods
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
    # This used to be a hack that pulled the UID out of an OAuth2 token. The new
    # encrypted OAuth2 tokens don't have UIDs anymore, so this method is an
    # interim hack for old code that still depends on it.
    def uid_from_token(access_token)
      FBGraphRails.fbclient(access_token).selection.me.info!.id.to_s
    end
  end  # module Authpwn::FacebookTokenModel::ClassMethods

  
  # Included in models that include Authpwn::FacebookTokenModel.
  module InstanceMethods
    # FBGraph client loaded with this access token.
    def facebook_client
      @client ||= FBGraphRails.fbclient(access_token)
    end  
  end  # module Authpwn::FacebookTokenModel::InstanceMethods
  
end  # namespace Authpwn::FacebookTokenModel

end  # namespace Authpwn
