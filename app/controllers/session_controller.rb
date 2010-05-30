# Manages logging in and out of the application.
class SessionController < ApplicationController
  authenticates_using_session

  # DELETE /session
  def destroy
    self.current_user = nil
    redirect_to root_url
  end
end
