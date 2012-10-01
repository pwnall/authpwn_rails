require 'securerandom'
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

    # Authenticates a user given the information on a signup form.
    #
    # The method's parameter names are an acknowledgement to the email and
    # password fields on automatically-generated forms.
    #
    # The easiest method of accepting other login information is to override
    # this method, locate the user's email, and supply it in a call to super.
    #
    # Returns an authenticated user, or a symbol indicating the reason why the
    # authentication failed.
    def authenticate_signin(email, password)
      Credentials::Password.authenticate_email email, password
    end
  end  # module Authpwn::UserModel::ClassMethods

  # Checks if a credential is acceptable for authenticating a user.
  #
  # Returns nil if the credential is acceptable, or a String containing a
  # user-visible reason why the credential is not acceptable.
  def auth_bounce_reason(crdential)
    nil
  end

  # Use e-mails instead of exposing ActiveRecord IDs.
  def to_param
    exuid
  end

  # :nodoc: sets exuid to a (hopefully) unique value before validations occur.
  def set_default_exuid
    self.exuid ||=
        SecureRandom.random_bytes(8).unpack('Q').first & 0x7fffffffffffffff
  end
end  # namespace Authpwn::UserModel

end  # namespace Authpwn
