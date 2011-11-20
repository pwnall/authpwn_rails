# :namespace
module Credentials
  
# Associates a Facebook account and OAuth2 token with an account.
class Facebook < ::Credential
  # The Graph API object ID of the Facebook account.
  validates :name, :format => /^\d+$/,
       :presence => true, :length => 1..32, :uniqueness => { :scope => [:type],
       :message => 'Your Facebook user is already associated to an account' }

end  # class Credentials::Facebook 

end  # namespace Credentials

# :nodoc: adds Facebook integration methods to the User model.
class User
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
