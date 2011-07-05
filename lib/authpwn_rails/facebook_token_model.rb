require 'active_support'

# :nodoc: namespace
module AuthpwnRails

# Included by the model class that represents facebook tokens.
#
# Right now, some parts of the codebase assume the model will be named
# FacebookToken.
module FacebookTokenModel
  extend ActiveSupport::Concern

  included do
    # The user whose token this is.
    belongs_to :user, :inverse_of => :facebook_token
    validates :user, :presence => true
    
    # A unique ID on the Facebook site for the user owning this token.
    validates :external_uid, :length => 1..32, :presence => true
  
    # The OAuth2 access token.
    validates :access_token, :length => 1..128, :presence => true
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
    # This is a hack. It works based on the current format, but might break at
    # any time. Hopefully, we'll eventually have an official way of pulling the
    # UID out of an OAuth2 token.
    def uid_from_token(access_token)
      access_token.split('|')[1].split('-').last
    end
  end  # module AuthpwnRails::FacebookTokenModel::ClassMethods

  
  # Included in models that include AuthpwnRails::FacebookTokenModel.
  module InstanceMethods
    # FBGraph client loaded with this access token.
    def facebook_client
      @client ||= FBGraphRails.fbclient(access_token)
    end  
  end  # module AuthpwnRails::FacebookTokenModel::InstanceMethods
  
end  # namespace AuthpwnRails::FacebookTokenModel

end  # namespace AuthpwnRails
