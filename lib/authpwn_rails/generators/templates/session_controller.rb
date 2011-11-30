# Manages logging in and out of the application.
class SessionController < ApplicationController
  include Authpwn::SessionController
  
  # Sets up the 'session/welcome' view. No user is logged in.
  def welcome
    # You can brag about some statistics.
    @user_count = User.count
  end
  private :welcome

  # Sets up the 'session/home' view. A user is logged in.
  def home
    # Pull information about the current user.
    @user = current_user
  end
  private :home
  
  # The notification text displayed when a session authentication fails.
  def bounce_notice_text(reason)
    case reason
    when :invalid
      'Invalid e-mail or password'
    when :blocked
      'Account blocked. Please verify your e-mail address'
    end
  end
  
  # You shouldn't extend the session controller, so you can benefit from future
  # features, like Facebook / Twitter / OpenID integration. But, if you must,
  # you can do it here.
end
