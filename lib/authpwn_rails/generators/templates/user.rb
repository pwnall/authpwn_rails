# An user account.
class User < ActiveRecord::Base
  include Authpwn::UserModel

  # Virtual email attribute, with validation.
  # include Authpwn::UserExtensions::EmailField
  # Virtual password attribute, with confirmation validation.
  # include Authpwn::UserExtensions::PasswordField

  # Change this method to change the way users are looked up when signing in.
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

  # Add your extensions to the User class here.
end
