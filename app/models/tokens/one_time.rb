# :namespace
module Tokens
  
# One-time tokens can only be used once to authenticate an account.
class OneTime < Credentials::Token
  # Updates the token's state to reflect that it was used for authentication.
  #
  # One-time tokens become invalid after they are spent.
  #
  # Returns the token instance.
  def spend
    destroy
  end
end  # class Tokens::OneTime

end  # namespace Tokens
