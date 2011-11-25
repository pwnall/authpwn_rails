require 'active_model'
require 'active_support'

# :nodoc: namespace
module Authpwn

# Included by the model class that represents users.
#
# Parts of the codebase assume the model will be named User.
module UserModel
  extend ActiveSupport::Concern

  included do
    # Externally-visible user ID.
    #
    # This is decoupled from "id" column to avoid leaking information about
    # the application's usage.
    validates :exuid, :presence => true, :length => 1..32, :uniqueness => true
    
    # Credentials used to authenticate the user.
    has_many :credentials, :dependent => :destroy, :inverse_of => :user
    
    # Automatically assign exuid.
    before_validation :set_default_exuid, :on => :create
    
    # Forms should not be able to touch any attribute.
    attr_accessible
  end

  # Class methods on models that include Authpwn::UserModel.
  module ClassMethods
    # Queries the database using the value returned by User#to_param.
    #
    # Returns nil if no matching User exists.
    def find_by_param(param)
      where(:exuid => param).first
    end
  end  # module Authpwn::UserModel::ClassMethods
  
  # Included in models that include Authpwn::UserModel.
  module InstanceMethods
    # Use e-mails instead of exposing ActiveRecord IDs.
    def to_param
      exuid
    end
    
    # :nodoc: sets exuid to a (hopefully) unique value before validations occur. 
    def set_default_exuid
      self.exuid ||= (Time.now.to_f * 1_000_000).to_i
    end
  end  # module Authpwn::UserModel::InstanceMethods
  
end  # namespace Authpwn::UserModel

end  # namespace Authpwn


# :nodoc: adds e-mail integration to the user model
module Authpwn::UserModel::ClassMethods
  # The user who has a certain e-mail, or nil if the e-mail is unclaimed.
  def with_email(email)
    credential = Credentials::Email.where(:name => email).includes(:user).first
    credential && credential.user
  end
end  # module Authpwn::UserModel::ClassMethods

# :nodoc: adds e-mail integration to the user model
module Authpwn::UserModel::InstanceMethods
  def email_credential
    credentials.find { |c| c.instance_of?(Credentials::Email) }
  end
  
  # The e-mail from the user's Email credential, or nil no credential exists.
  def email
    credential = self.email_credential
    credential && credential.email
  end
end  # module Authpwn::UserModel::InstanceMethods


# :nodoc: adds Facebook integration methods to the User model.
module Authpwn::UserModel::ClassMethods
  # The user that owns a given Facebook OAuth2 token.
  #
  # A new user will be created if the token doesn't belong to any user. This
  # is the case for a new visitor.
  def for_facebook_token(access_token)
    Credentials::Facebook.for(access_token).user
  end
end  # module Authpwn::UserModel::ClassMethods

# :nodoc: adds Facebook integration methods to the User model.
module Authpwn::UserModel::InstanceMethods
  def facebook_credential
    credentials.find { |c| c.instance_of?(Credentials::Facebook) }
  end
end  # module Authpwn::UserModel::InstanceMethods


# :nodoc: adds password integration methods to the User model.
module Authpwn::UserModel::InstanceMethods
  def password_credential
    credentials.find { |c| c.instance_of?(Credentials::Password) }
  end
end  # module Authpwn::UserModel::InstanceMethods
