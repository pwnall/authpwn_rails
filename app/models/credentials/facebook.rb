# :namespace
module Credentials
  
# Associates a Facebook account and OAuth2 token with an account.
class Facebook < ::Credential
  # The Graph API object ID of the Facebook account.
  alias_attribute :facebook_uid, :name
  validates :name, :format => /^\d+$/, :presence => true,
       :uniqueness => { :scope => [:type],
       :message => 'Your Facebook user is already associated to an account' }

  # A user can be associated to a single Facebook account.
  validates :user_id, :uniqueness => {
      :message => 'Your account is already associated to a Facebook user' }

  # OAuth2 token issued by Facebook.
  alias_attribute :access_token, :key
  validates :key, :presence => true

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
      credential.key = access_token
      credential.save!
    else
      User.transaction do
        user = User.create!
        credential = self.new
        user.credentials << credential
        credential.facebook_uid = uid
        credential.access_token = access_token
        credential.save!
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
    FBGraphRails.fbclient(access_token).selection.me.info![:id].to_s
  end
  
  # Forms should not be able to touch any attribute.
  attr_accessible
end  # class Credentials::Facebook 

end  # namespace Credentials
