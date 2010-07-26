require 'active_record'


# An user account.
class User < ActiveRecord::Base
  # E-mail address identifying the user account.
  validates :email, :format => /^[A-Za-z0-9.+_]+@[^@]*\.(\w+)$/,
                    :presence => true, :length => 1..64, :uniqueness => true
  
  # Random string preventing dictionary attacks on the password database.
  validates :password_salt, :length => 1..16, :allow_nil => true
  
  # SHA-256 of (salt + password).
  validates :password_hash, :length => 1..64, :allow_nil => true
    
  # Virtual attribute: the user's password.
  attr_reader :password
  validates :password, :confirmation => true
  def password=(new_password)
    @password = new_password
    self.password_salt = self.class.random_salt
    self.password_hash = self.class.hash_password new_password, password_salt
  end
  
  # Virtual attribute: confirmation for the user's password.
  attr_accessor :password_confirmation
  validates_confirmation_of :password
  
  # The authenticated user or nil.
  def self.find_by_email_and_password(email, password)
    @user = User.where(:email => email).first
    (@user && @user.password_matches?(password)) ? @user : nil
  end
  
  # Compares the given password against the user's stored password.
  #
  # Returns +true+ for a match, +false+ otherwise.
  def password_matches?(passwd)
    password_hash == User.hash_password(passwd, password_salt)
  end  
  
  # Computes a password hash from a raw password and a salt.
  def self.hash_password(password, salt)
    Digest::SHA2.hexdigest(password + salt)
  end
  
  # Generates a random salt value.
  def self.random_salt
    (0...16).map { |i| 1 + rand(255) }.pack('C*')
  end    
  
  # Resets the virtual password attributes.
  def reset_password
    @password = @password_confirmation = nil
  end
  
  
  # Fills out a new user's information based on a Facebook access token.
  def self.create_with_facebook_token(token)
    self.create :email => "#{token.external_uid}@graph.facebook.com"
  end
  
  # The user that owns a given Facebook OAuth2 token.
  #
  # A new user will be created if the token doesn't belong to any user. This is
  # the case for a new visitor.
  def self.for_facebook_token(access_token)
    FacebookToken.for(access_token).user
  end  
end
