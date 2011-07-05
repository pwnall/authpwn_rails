# An user account.
class User < ActiveRecord::Base
  include AuthpwnRails::UserModel

  # Add your extensions to the User class here.  
end
