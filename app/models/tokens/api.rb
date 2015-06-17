# :namespace
module Tokens

# API tokens can be used to issue API calls on behalf of an account.
class Api < Tokens::Base
  # NOTE: If we ever implement OAuth tokens, they should hang off of API
  #       tokens.

  # For now, we allow exactly one API token for each user.
  validates :user, uniqueness: { scope: :type }
end

end  # namespace Tokens
