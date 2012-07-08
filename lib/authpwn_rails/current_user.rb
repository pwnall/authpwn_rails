# :nodoc: namespace
module Authpwn

# The unofficial Rails convention for tracking the authenticated user.
module CurrentUser
  attr_reader :current_user
  
  def current_user=(user)
    @current_user = user
    if user
      session[:user_exuid] = user.to_param
    else
      session.delete :user_exuid
    end
  end  
end  # module Authpwn::CurrentUser

end  # namespace Authpwn

