# :namespace
module Credentials
  
# Associates a Facebook account and OAuth2 token with an account.
class Facebook < ::Credential
  # The Graph API object ID of the Facebook account.
  validates :name, :format => /^\d+$/,
       :presence => true, :length => 1..32, :uniqueness => { :scope => [:type],
       :message => 'Your Facebook user is already associated to an account' }

  # FBGraph client loaded with this access token.
  def facebook_client
    @client ||= FBGraphRails.fbclient(access_token)
  end  

  # Finds or creates the model containing a token.
  #
  # If a model for the same user exists, the model is updated with the given
  # token. Otherwise, a new model will be created, together with a user.
  def self.for(access_token)
    uid = uid_from_token access_token
    credential = self.where(:name => uid.to_str).first
    if credential
      credential.update_attributes! :key => access_token
    else
      User.transaction do
        user = User.create!
        credential = self.create! :name => uid, :key => access_token,
                                  :user => user
      end
    end
    credential
  end
  
  # Extracts the Facebook user ID from a OAuth2 token.
  #
  # This used to be a hack that pulled the UID out of an OAuth2 token. The new
  # encrypted OAuth2 tokens don't have UIDs anymore, so this method is an
  # interim hack for old code that still depends on it.
  def self.uid_from_token(access_token)
    FBGraphRails.fbclient(access_token).selection.me.info!.id.to_s
  end
end  # class Credentials::Facebook 

end  # namespace Credentials

# :nodoc: adds Facebook integration methods to the User model.
class <<User
  # Fills out a new user's information based on a Facebook access token.
  def create_with_facebook_token(token)
    self.create! :email => "#{token.external_uid}@graph.facebook.com"
  end
  
  # The user that owns a given Facebook OAuth2 token.
  #
  # A new user will be created if the token doesn't belong to any user. This
  # is the case for a new visitor.
  def for_facebook_token(access_token)
    FacebookToken.for(access_token).user
  end
end
