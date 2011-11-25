# An user account.
class User < ActiveRecord::Base
  include Authpwn::UserModel

  # Virtual email attribute, with validation.
  # include Authpwn::UserExtensions::EmailField
  # Virtual password attribute, with confirmation validation.
  # include Authpwn::UserExtensions::PasswordField

  # Add your extensions to the User class here.
end
