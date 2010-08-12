require 'active_record'

# :nodoc: namespace
module AuthpwnRails

# :nodoc: namespace
module UserModel


# Mixed into ActiveRecord::Base
module ModelMixin
  def self.included(base)
    base.send :extend, ModelClassMethods
  end
end


# Methods here become ActiveRecord::Base class methods.
module ModelClassMethods
  # Extends the model with all that it needs to be PwnAuth's user model.
  def pwnauth_user_model
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

    # Virtual attribute: confirmation for the user's password.
    attr_accessor :password_confirmation
    validates_confirmation_of :password

    extend ModelMetaclassMethods    
    include ModelInstanceMethods
  end
end  # module AuthpwnRails::UserModel::ModelClassMethods


# Included in the metaclass of models that call pwnauth_user_model.
module ModelMetaclassMethods
  # The authenticated user or nil.
  def find_by_email_and_password(email, password)
    @user = where(:email => email).first
    (@user && @user.password_matches?(password)) ? @user : nil
  end
    
  # Computes a password hash from a raw password and a salt.
  def hash_password(password, salt)
    Digest::SHA2.hexdigest(password + salt)
  end
  
  # Generates a random salt value.
  def random_salt
    [(0...12).map { |i| 1 + rand(255) }.pack('C*')].pack('m').strip
  end  
  
  # Fills out a new user's information based on a Facebook access token.
  def create_with_facebook_token(token)
    self.create :email => "#{token.external_uid}@graph.facebook.com"
  end
  
  # The user that owns a given Facebook OAuth2 token.
  #
  # A new user will be created if the token doesn't belong to any user. This is
  # the case for a new visitor.
  def for_facebook_token(access_token)
    FacebookToken.for(access_token).user
  end  
end  # module AuthpwnRails::UserModel::ModelMetaclassMethods


# Included in models that call pwnauth_user_model.
module ModelInstanceMethods
  # Resets the virtual password attributes.
  def reset_password
    @password = @password_confirmation = nil
  end
    
  # Compares the given password against the user's stored password.
  #
  # Returns +true+ for a match, +false+ otherwise.
  def password_matches?(passwd)
    password_hash == self.class.hash_password(passwd, password_salt)
  end  

  # Password virtual attribute.
  def password=(new_password)
    @password = new_password
    self.password_salt = self.class.random_salt
    self.password_hash = self.class.hash_password new_password, password_salt
  end
end  # module AuthpwnRails::UserModel::ModelInstanceMethods

ActiveRecord::Base.send :include, ModelMixin

end  # namespace AuthpwnRails::UserModel

end  # namespace AuthpwnRails
