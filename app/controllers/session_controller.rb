# Manages logging in and out of the application.
class SessionController < ApplicationController
  authenticates_using_session

  # GET /session
  def show
    @user = current_user || User.new
    if @user.new_record?
      render :action => :welcome
    else
      render :action => :home
    end
  end
  
  # POST /session
  def create
    @user = User.new params[:user]
    self.current_user =
        User.find_by_email_and_password @user.email, @user.password
        
    respond_to do |format|
      if current_user
        format.html { redirect_to session_url }
      else
        flash[:notice] = 'Invalid e-mail or password'
        format.html { redirect_to session_url }
      end
    end
  end

  # DELETE /session
  def destroy
    self.current_user = nil
    redirect_to session_url
  end
end
