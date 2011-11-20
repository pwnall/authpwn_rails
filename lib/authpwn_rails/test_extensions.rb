# :nodoc: namespace
module Authpwn

# Included in test cases.
module TestExtensions
  # Sets the authenticated user in the test session.
  def set_session_current_user(user)
    request.session[:user_exuid] = user ? user.to_param : nil
  end
  
  # The authenticated user in the test session.
  def session_current_user
    return nil unless user_param = request.session[:user_exuid]
    User.find_by_param user_param
  end
end  # module Authpwn::TestExtensions

end  # namespace Authpwn


# :nodoc: extend Test::Unit
class ActionController::TestCase
  include Authpwn::TestExtensions
end
