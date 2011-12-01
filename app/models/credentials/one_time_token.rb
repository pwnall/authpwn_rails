# :namespace
module Credentials
  
# Associates a one-time token or API token with the account.
class OneTimeToken < Token
  # Updates the token's state to reflect that it was used for authentication.
  #
  # One-time tokens will become invalid after they are spent.
  #
  # Returns the token instance.
  def spend!
    destroy
  end
end  # class Credentials::Token

end  # namespace Credentials
