# An user account.
class User < ActiveRecord::Base
  include Authpwn::UserModel

  # Add your extensions to the User class here.
end
