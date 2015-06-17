require 'active_model'
require 'active_support'

# :nodoc: namespace
module Authpwn

# :nodoc: namespace
module UserExtensions

# Augments the User model with a password virtual attribute.
module ApiTokenField
  extend ActiveSupport::Concern

  # Credentials::Password instance associated with this user.
  def api_token_credential
    credentials.find { |c| c.instance_of?(Tokens::Api) }
  end

  # The code from the user's API token credential.
  #
  # Creates an API token if the user doesn't already have one.
  def api_token
    credential = self.api_token_credential || Tokens::Api.random_for(self)
    credential.code
  end
end  # module Authpwn::UserExtensions::ApiTokenField

end  # module Authpwn::UserExtensions

end  # module Authpwn
