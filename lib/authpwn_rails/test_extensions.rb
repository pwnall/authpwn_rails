# :nodoc: namespace
module AuthpwnRails

# Included in test cases.
module TestExtensions
  # Sets the authenticated user in the test session.
  def set_session_current_user(user)
    request.session[:current_user_pid] = user ? user.to_param : nil
  end
  
  # The authenticated user in the test session.
  def session_current_user
    return nil unless user_param = request.session[:current_user_pid]
    User.find_by_param user_param
  end
end  # module AuthpwnRails::TestExtensions

end  # namespace AuthpwnRails


# :nodoc: extend Test::Unit
class ActionController::TestCase
  include AuthpwnRails::TestExtensions
end
