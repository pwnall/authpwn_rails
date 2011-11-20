# :namespace
module Credentials
  
# Associates a password with the user account.
class Password < ::Credential
  # Virtual attribute: the user's password.
  attr_accessor :password
  validates :password, :confirmation => true, :presence => true

  # Virtual attribute: confirmation for the user's password.
  attr_accessor :password_confirmation

  # Compares the given password against the user's stored password.
  #
  # Returns +true+ for a match, +false+ otherwise.
  def authenticate(password)
    return false unless password_hash
    salt = password_hash.split('|', 2).first
    key == self.class.hash_password(password, salt)
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

  # The authenticated user or nil.
  def self.authenticate_by_email(email, password)
    user = where(:email => email).first
    (user && user.password_matches?(password)) ? user : nil
  end

  # Computes a password hash from a raw password and a salt.
  def self.hash_password(password, salt)
    salt + '|' + Digest::SHA2.hexdigest(password + salt)
  end
  
  # Generates a random salt value.
  def self.random_salt
    [(0...12).map { |i| 1 + rand(255) }.pack('C*')].pack('m').strip
  end  
end  # class Credentials::Password

end  # namespace Credentials
