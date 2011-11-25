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
    validates_associated :credentials
    # This is safe, because credentials use attr_accessible.
    accepts_nested_attributes_for :credentials, :allow_destroy => true
    
    # Automatically assign exuid.
    before_validation :set_default_exuid, :on => :create
    
    # Forms should not be able to touch any attribute.
    attr_accessible :credentials_attributes
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
