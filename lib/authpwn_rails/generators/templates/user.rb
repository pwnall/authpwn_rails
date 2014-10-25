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
  # and pass their e-mail to super.
  def self.authenticate_signin(email, password)
    super
  end

  # Add your extensions to the User class here.
end
