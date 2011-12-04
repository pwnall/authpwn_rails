require 'securerandom'

# :namespace
module Credentials
  
# Associates a secret token code with the account.
#
# Subclasses of this class are in the tokens namespace.
class Token < ::Credential
  # The secret token code.
  alias_attribute :code, :name
  # Token names are random, so we can expect they'll be unique across the entire
  # namespace. We need this check to enforce name uniqueness across different
  # token types. 
  validates :name, :format => /^[A-Za-z0-9\_\-]+$/, :presence => true,
                   :uniqueness => true 

  # Authenticates a user using a secret token code.
  #
  # The token will be spent on successful authentication. One-time tokens are
  # deleted when spent.
  #
  # Returns the authenticated User instance, or a symbol indicating the reason
  # why the (potentially valid) token code was rejected.
  def self.authenticate(code)
    credential = self.with_code code
    credential ? credential.authenticate : :invalid
  end
  
  # The token matching a secret code.
  def self.with_code(code)
    # After using this method, it's likely that the user's other tokens (e.g.,
    # email or Facebook OAuth token) will be required, so we pre-fetch them.
    Credentials::Token.where(:name => code).
                       includes(:user => :credentials).first
  end
  
  # Authenticates a user using this token.
  #
  # The token will be spent on successful authentication. One-time tokens are
  # deleted when spent.
  #
  # Returns the authenticated User instance, or a symbol indicating the reason
  # why the (potentially valid) token code was rejected.
  def authenticate
    if bounce = user.auth_bounce_reason(self)
      return bounce
    end
    spend
    user
  end
  
  # Updates the token's state to reflect that it was used for authentication.
  #
  # Tokens may become invalid after they are spent.
  #
  # Returns the token instance.
  def spend
    self
  end

  # Creates a new random token for a user.
  #
  # Args:
  #   user:: the User who will be authenticated by the token
  #   key:: optional data associated with the token
  #   klass:: class that will be instantiated (should be a subclass of Token)
  #
  # Returns a newly created and saved token with a random code.
  def self.random_for(user, key = nil, klass = nil)
    klass ||= self
    if key.nil?
      token = self.new(:code => random_code)
    else
      token = self.new(:code => random_code, :key => key)
    end
    user.credentials << token
    token.save!
    token
  end

  # Generates a random token code.
  def self.random_code
    SecureRandom.urlsafe_base64(32)
  end
end  # class Credentials::Token

end  # namespace Credentials
