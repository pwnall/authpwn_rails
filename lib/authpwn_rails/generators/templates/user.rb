# An user account.
class User < ActiveRecord::Base
  include Authpwn::UserModel

  # Virtual email attribute, with validation.
  # include Authpwn::UserExtensions::EmailField
  # Virtual password attribute, with confirmation validation.
  # include Authpwn::UserExtensions::PasswordField

  # Change this to customize user lookup in the e-mail/password signin process.
  #
  # For example, to implement Facebook / Twitter's ability to log in using
  # either an e-mail address or a username, look up the user by the username,
  # create a new Session with the e-mail and password, and pass it to super
  #
  # @param [Session] signin the information entered in the sign-in form
  # @return [User, Symbol] the authenticated user, or a symbol indicating the
  #     reason why the authentication failed
  def self.authenticate_signin(signin)
    super
  end

  # Change this to customize user lookup in the OmniAuth signup process.
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
  def self.related_to_omniauth(omniauth_hash)
    super
  end

  # Change this to customize on-demand user creation on OmniAuth signup.
  #
  # This method is called when there is no existing user matching the OmniAuth
  # information, and is responsible for creating a user. It is an opportunity
  # to collect the OmniAuth information to populate the user's account.
  #
  # The default implementation creates a user with the e-mail matching the
  # 'email' key in the OmniAuth hash. If no e-mail key is present, no User is
  # created.
  #
  # @param [Hash] omniauth_hash the hash provided by OmniAuth
  # @return [User] a saved User, or nil if the OmniAuth sign-in information
  #   should not be used to create a user
  def self.create_from_omniauth(omniauth_hash)
    super
  end

  # Add your extensions to the User class here.
end
