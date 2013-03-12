# :namespace
module Credentials

# Associates a password with the user account.
class Password < ::Credential
  # Virtual attribute: the user's password.
  attr_accessor :password
  validates :password, :presence => { :on => :create },
                       :confirmation => { :allow_nil => true }

  # Virtual attribute: confirmation for the user's password.
  attr_accessor :password_confirmation

  # A user can have a single password.
  validates :user_id, :uniqueness => true

  # Passwords can expire, if users don't change them often enough.
  include Authpwn::Expires
  # Passwords don't expire by default, because it is non-trivial to get e-mail
  # delivery working in Rails, which is necessary for recovering from expired
  # passwords.
  self.expires_after = Authpwn::Engine.config.authpwn.password_expiration

  # Compares a plain-text password against the password hash in this credential.
  #
  # Returns +true+ for a match, +false+ otherwise.
  def check_password(password)
    return false unless key
    key == self.class.hash_password(password, key.split('|', 2).first)
  end

  # Compares a plain-text password against the password hash in this credential.
  #
  # Returns the authenticated User instance, or a symbol indicating the reason
  # why the (potentially valid) password was rejected.
  def authenticate(password)
    return :expired if expired?
    return :invalid unless check_password(password)
    user.auth_bounce_reason(self) || user
  end

  # Password virtual attribute.
  def password=(new_password)
    @password = new_password
    salt = self.class.random_salt
    self.key = new_password && self.class.hash_password(new_password, salt)
  end

  # Resets the virtual password attributes.
  def clear_plaintext
    @password = @password_confirmation = nil
  end

  # Authenticates a user given an e-mail / password pair.
  #
  # Returns the authenticated User instance, or a symbol indicating the reason
  # why the (potentially valid) credential was rejected.
  def self.authenticate_email(email, password)
    user = Credentials::Email.authenticate email
    return user if user.is_a? Symbol

    credential = user.credentials.find { |c| c.kind_of? Credentials::Password }
    credential ? credential.authenticate(password) : :invalid
  end

  # Computes a password hash from a raw password and a salt.
  def self.hash_password(password, salt)
    salt + '|' + Digest::SHA2.hexdigest(password + salt)
  end

  # Generates a random salt value.
  def self.random_salt
    [(0...12).map { |i| 1 + rand(255) }.pack('C*')].pack('m').strip
  end

  if ActiveRecord::Base.respond_to? :mass_assignment_sanitizer=
    # Forms can only change the plain-text password fields.
    attr_accessible :password, :password_confirmation
  end
end  # class Credentials::Password

end  # namespace Credentials
