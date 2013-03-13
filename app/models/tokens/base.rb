require 'securerandom'

# :nodoc: Backport urlsafe_base64 to 1.8.7.
unless SecureRandom.respond_to? :urlsafe_base64
  SecureRandom.class_eval do
    # :nodoc: lifted from 1.9.3 securerandom.rb, line 190
    def self.urlsafe_base64(n=nil, padding=false)
      s = [random_bytes(n)].pack("m*")
      s.delete!("\n")
      s.tr!("+/", "-_")
      s.delete!("=") if !padding
      s
    end
  end
end

# :namespace
module Tokens

# Credential that associates a secret token code with the account.
#
# Subclasses of this class are in the tokens namespace.
class Base < ::Credential
  # The secret token code.
  alias_attribute :code, :name
  # Token names are random, so we can expect they'll be unique across the
  # entire namespace. We need this check to enforce name uniqueness across
  # different token types.
  validates :name, :format => /\A[A-Za-z0-9\_\-]+\Z/, :presence => true,
                   :uniqueness => true

  # Tokens can expire. This is a good idea most of the time, because token
  # codes are supposed to be used quickly.
  include Authpwn::Expires

  # Authenticates a user using a secret token code.
  #
  # The token will be spent on successful authentication. One-time tokens are
  # deleted when spent.
  #
  # Returns the authenticated User instance, or a symbol indicating the reason
  # why the (potentially valid) token code was rejected.
  def self.authenticate(code)
    credential = self.with_code(code).first
    credential ? credential.authenticate : :invalid
  end

  
  begin
    ActiveRecord::QueryMethods.instance_method :references
    # Rails 4.

    # Scope that uses a secret code.
    def self.with_code(code)
      # NOTE 1: The where query must be performed off the root type, otherwise
      #         Rails will try to guess the right values for the 'type' column,
      #         and will sometimes get them wrong.
      # NOTE 2: After using this method, it's likely that the user's other
      #         tokens (e.g., email or Facebook OAuth token) will be required,
      #         so we pre-fetch them.
      Credential.where(:name => code).includes(:user => :credentials).
          where(Credential.arel_table[:type].matches('Tokens::%')).
          references(:credential)
    end
  rescue NameError
    # Rails 3.

    def self.with_code(code)
      Credential.where(:name => code).includes(:user => :credentials).
          where(Credential.arel_table[:type].matches('Tokens::%'))
    end
  end

  # Authenticates a user using this token.
  #
  # The token will be spent on successful authentication. One-time tokens are
  # deleted when spent.
  #
  # Returns the authenticated User instance, or a symbol indicating the reason
  # why the (potentially valid) token code was rejected.
  def authenticate
    if expired?
      destroy
      return :invalid
    end
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
  # @param [User] user the user who will be authenticated by the token
  # @param [String] key data associated with the token
  # @param [Class] klass the ActiveRecord class that will be instantiated;
  #     it should be a subclass of Token
  # @return [Tokens::Base] a newly created and saved token with a random
  #     code
  def self.random_for(user, key = nil, klass = nil)
    klass ||= self
    token = self.new
    token.code = random_code
    token.key = key unless key.nil?
    user.credentials << token
    token.save!
    token
  end

  # Generates a random token code.
  def self.random_code
    SecureRandom.urlsafe_base64(32)
  end

  # Use codes instead of exposing ActiveRecord IDs.
  def to_param
    code
  end

  # Scope using the value returned by Token#to_param.
  #
  # @param [String] param value returned by Token#to_param
  # @return [ActiveRecord::Relation]
  def self.with_param(param)
    where(:name => param)
  end
end  # class Tokens::Base

end  # namespace Tokens
