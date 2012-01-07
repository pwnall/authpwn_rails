require 'active_model'
require 'active_support'

# :nodoc: namespace
module Authpwn

# :nodoc: namespace
module UserExtensions
  
# Augments the User model with a password virtual attribute.
module PasswordField
  extend ActiveSupport::Concern
  
  included do
    validates :password, :presence => { :on => :create },
                         :confirmation => { :allow_nil => true }
    attr_accessible :password, :password_confirmation
  end
  
  module ClassMethods
    # The user who has a certain e-mail, or nil if the e-mail is unclaimed.
    def with_email(email)
      credential = Credentials::Email.where(:name => email).includes(:user).first
      credential && credential.user
    end
  end
  
  # Credentials::Password instance associated with this user.
  def password_credential
    credentials.find { |c| c.instance_of?(Credentials::Password) }
  end
  
  # The password from the user's Password credential, or nil.
  #
  # Returns nil if this user has no Password credential.
  def password
    credential = self.password_credential
    credential && credential.password
  end
  
  # The password_confirmation from the user's Password credential, or nil.
  #
  # Returns nil if this user has no Password credential.
  def password_confirmation
    credential = self.password_credential
    credential && credential.password_confirmation
  end

  # Sets the password on the user's Password credential.
  #
  # Creates a new Credentials::Password instance if necessary.
  def password=(new_password)
    if credential = self.password_credential
      credential.password = new_password
    else
      credentials << Credentials::Password.new(:password => new_password)
    end
    new_password
  end

  # Sets the password on the user's Password credential.
  #
  # Creates a new Credentials::Password instance if necessary.
  def password_confirmation=(new_password_confirmation)
    if credential = self.password_credential
      credential.password_confirmation = new_password_confirmation
    else
      credentials << Credentials::Password.new(:password_confirmation =>
                                               new_password_confirmation)
    end
    new_password_confirmation
  end
end  # module Authpwn::UserExtensions::PasswordField
  
end  # module Authpwn::UserExtensions
  
end  # module Authpwn
