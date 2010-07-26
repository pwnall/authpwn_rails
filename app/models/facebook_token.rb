require 'active_record'


# Wraps an OAuth2 access token for Facebook.
class FacebookToken < ActiveRecord::Base
  # The user whose token this is.
  belongs_to :user
  validates :user, :presence => true
  
  # A unique ID on the Facebook site for the user owning this token.
  validates :external_uid, :length => 1..32, :presence => true

  # The OAuth2 access token.
  validates :access_token, :length => 1..128, :presence => true
  
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
    token = self.where(:external_uid => uid).first
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
  def self.uid_from_token(access_token)
    access_token.split('|')[1].split('-').last
  end
end
