require 'securerandom'

require 'active_model'
require 'active_support'
require 'base32'

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
    validates :exuid, presence: true, length: 1..32, uniqueness: true

    # Credentials used to authenticate the user.
    has_many :credentials, dependent: :destroy, inverse_of: :user,
                           autosave: true
    validates_associated :credentials

    # Automatically assign exuid.
    before_validation :set_default_exuid, on: :create
  end

  # Class methods on models that include Authpwn::UserModel.
  module ClassMethods
    # Scope using the value returned by User#to_param.
    #
    # @param [String] param value returned by User#to_param
    # @return [ActiveRecord::Relation]
    def with_param(param)
      where(exuid: param)
    end

    # Authenticates a user given the information on a signup form.
    #
    # The easiest method of accepting other login information is to override
    # this method, locate the user's email, and supply it in a call to super.
    #
    # @param [Session] signin the information entered in the sign-in form
    # @return [User, Symbol] the authenticated user, or a symbol indicating the
    #     reason why the authentication failed
    def authenticate_signin(signin)
      Credentials::Password.authenticate_email signin.email, signin.password
    end

    # Looks up the User tat may be related to an OmniAuth sign-in.
    #
    # This method is called when there is no Credential matching the OmniAuth
    # information, but before {User#create_from_omniauth}. It is an opportunity
    # to identify an existing user who uses a new sign-in method.
    #
    # The default implementation finds an user whose e-mail matches the 'email'
    # value in the OmniAuth hash.
    #
    # @param [Hash] omniauth_hash the hash provided by OmniAuth
    # @return [User] the user who should be signed in, or nil if no such user
    #   exists
    def related_to_omniauth(omniauth_hash)
      info_hash = omniauth_hash['info']
      return nil unless email = info_hash && info_hash['email']
      credential = Credentials::Email.with email
      credential and credential.user
    end

    # Change this to customize on-demand user creation on OmniAuth signup.
    #
    # This method is called when there is no existing user matching the
    # OmniAuth information, and is responsible for creating a user. It is an
    # opportunity to collect the OmniAuth information to populate the user's
    # account.
    #
    # The default implementation creates a user with the e-mail matching the
    # 'email' key in the OmniAuth hash. If no e-mail key is present, no User is
    # created.
    #
    # @param [Hash] omniauth_hash the hash provided by OmniAuth
    # @return [User] a saved User, or nil if the OmniAuth sign-in information
    #   should not be used to create a user
    def create_from_omniauth(omniauth_hash)
      info_hash = omniauth_hash['info']
      return nil unless email = info_hash && info_hash['email']
      user = User.new
      user.credentials << Credentials::Email.new(email: email, verified: true)
      user.save!
      user
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
        Base32.encode(SecureRandom.random_bytes(16)).downcase.sub(/=*$/, '')
  end
end  # namespace Authpwn::UserModel

end  # namespace Authpwn
