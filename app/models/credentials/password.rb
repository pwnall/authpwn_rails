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

  # A user can have a single password
  validates :user_id, :uniqueness => true

  # Compares the given password against the user's stored password.
  #
  # Returns +true+ for a match, +false+ otherwise.
  def authenticate(password)
    return false unless key
    key == self.class.hash_password(password, key.split('|', 2).first)
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
  # Returns a hash with one of the following keys:
  #   :user:: the authenticated User instance
  #   :reason:: reason why the (potentially valid) credential was rejected
  def self.authenticate_email(email, password)
    email_cred = Credentials::Email.where(:name => email).
                                    includes(:user => :credentials).first
    return { :reason => :invalid } unless email_cred
    user = email_cred.user
    return { :reason => reason } if reason = user.auth_bounce_reason(email_cred)
    
    credential = email_cred.user.credentials.
                            find { |c| c.kind_of? Credentials::Password }
    if credential.authenticate(password)
      return { :user => user }
    else
      return { :reason => :invalid }
    end
  end

  # Computes a password hash from a raw password and a salt.
  def self.hash_password(password, salt)
    salt + '|' + Digest::SHA2.hexdigest(password + salt)
  end
  
  # Generates a random salt value.
  def self.random_salt
    [(0...12).map { |i| 1 + rand(255) }.pack('C*')].pack('m').strip
  end
  
  # Forms can only change the plain-text password fields.
  attr_accessible :password, :password_confirmation  
end  # class Credentials::Password

end  # namespace Credentials
