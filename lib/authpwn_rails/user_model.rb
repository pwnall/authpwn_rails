require 'active_model'
require 'active_support'

# :nodoc: namespace
module AuthpwnRails

# Included by the model class that represents users.
#
# Right now, some parts of the codebase assume the model will be named User.
module UserModel
  extend ActiveSupport::Concern
  
  included do
    # E-mail address identifying the user account.
    validates :email, :format => /^[A-Za-z0-9.+_]+@[^@]*\.(\w+)$/,
                      :presence => true, :length => 1..128, :uniqueness => true
    
    # Hash of e-mail address of the user account.
    validates :email_hash, :length => 64..64, :allow_nil => false
    
    # Random string preventing dictionary attacks on the password database.
    validates :password_salt, :length => { :in => 1..16, :allow_nil => true }
    
    # SHA-256 of (salt + password).
    validates :password_hash, :length => { :in => 64..64, :allow_nil => true }
      
    # Virtual attribute: the user's password.
    attr_reader :password
    validates :password, :confirmation => true

    # Virtual attribute: confirmation for the user's password.
    attr_accessor :password_confirmation
    validates_confirmation_of :password
    
    # Facebook token.
    has_one :facebook_token, :dependent => :destroy, :inverse_of => :user    
  end

  # Class methods on models that include AuthpwnRails::UserModel.
  module ClassMethods
    # Queries the database using the value returned by User#to_param.
    #
    # Returns nil if no matching User exists.
    def find_by_param(param)
      where(:email_hash => param).first
    end
    
    # The authenticated user or nil.
    def find_by_email_and_password(email, password)
      user = where(:email => email).first
      (user && user.password_matches?(password)) ? user : nil
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
      self.create! :email => "#{token.external_uid}@graph.facebook.com"
    end
    
    # The user that owns a given Facebook OAuth2 token.
    #
    # A new user will be created if the token doesn't belong to any user. This
    # is the case for a new visitor.
    def for_facebook_token(access_token)
      FacebookToken.for(access_token).user
    end
  end  # module AuthpwnRails::UserModel::ClassMethods
  
  # Included in models that include AuthpwnRails::UserModel.
  module InstanceMethods
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
      self.password_hash = new_password &&
                           self.class.hash_password(new_password, password_salt)
    end
    
    # Use e-mails instead of exposing ActiveRecord IDs.
    def to_param
      email_hash
    end
    
    # :nodoc: overwrites
    def email=(new_email)
      super
      self.email_hash = new_email && Digest::SHA2.hexdigest(new_email)
    end
    
    # Do not expose password and ActiveRecord IDs in JSON representation.
    def as_json(options = {})
      options ||= {}
      super(options.merge(:except => [:password_salt, :password_hash, :id]))
    end
  end  # module AuthpwnRails::UserModel::InstanceMethods

end  # namespace AuthpwnRails::UserModel

end  # namespace AuthpwnRails
