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
    validates :euid, :presence => true, :length => 1..32
    
    # Credentials used to authenticate the user.
    has_many :credentials, :dependent => :destroy, :inverse_of => :user
  end

  # Class methods on models that include Authpwn::UserModel.
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
  end  # module Authpwn::UserModel::ClassMethods
  
  # Included in models that include Authpwn::UserModel.
  module InstanceMethods    
    # Use e-mails instead of exposing ActiveRecord IDs.
    def to_param
      euid
    end
  end  # module Authpwn::UserModel::InstanceMethods

end  # namespace Authpwn::UserModel

end  # namespace Authpwn
