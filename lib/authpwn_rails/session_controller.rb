require 'active_support'

# :nodoc: namespace
module Authpwn

# Included by the controller that handles user authentication.
#
# Right now, some parts of the codebase assume the controller will be named
# Session.
module SessionController
  extend ActiveSupport::Concern
  
  included do
    skip_filter :authenticate_using_session
    authenticates_using_session :except => [:create, :reset_password, :token]
  end

  # GET /session/new
  def new
    @email = params[:email]
    @redirect_url = flash[:auth_redirect_url]
    redirect_to session_url if current_user
  end

  # GET /session
  def show
    @user = current_user || User.new
    if @user.new_record?
      welcome
      unless performed?
        respond_to do |format|
          format.html { render :action => :welcome }
          format.json { render :json => {} }
        end
      end
    else      
      home
      unless performed?
        respond_to do |format|
          format.html { render :action => :home }
          format.json do
            user_data = @user.as_json
            user_data = user_data['user'] if @user.class.include_root_in_json
            render :json => { :user => user_data,
                              :csrf => form_authenticity_token }
          end
        end
      end
    end
  end
  
  # POST /session
  def create
    # Workaround for lack of browser support for the formaction attribute.
    return reset_password if params[:reset_password]
    
    @redirect_url = params[:redirect_url] || session_url
    @email = params[:email]
    auth = Credentials::Password.authenticate_email @email, params[:password]
    self.current_user = auth unless auth.kind_of? Symbol
        
    respond_to do |format|
      if current_user
        format.html { redirect_to @redirect_url }
        format.json do
          user_data = current_user.as_json
          if current_user.class.include_root_in_json
            user_data = user_data['user']
          end
          render :json => { :user => user_data,
                            :csrf => form_authenticity_token }
        end
      else
        notice = bounce_notice_text auth
        format.html do
          redirect_to new_session_url, :flash => { :notice => notice,
              :auth_redirect_url => @redirect_url }
        end
        format.json { render :json => { :error => auth, :text => notice } }
      end
    end
  end
  
  # POST /session/reset_password
  def reset_password
    @email = params[:email]
    credential = Credentials::Email.with @email
    
    if user = (credential && credential.user)
      token = Tokens::PasswordReset.random_for user
      ::SessionMailer.reset_password_email(@email, token, root_url).deliver
    end
     
    respond_to do |format|
      if user
        format.html do
          redirect_to new_session_url, :notice =>
              'Please check your e-mail for instructions'
        end
        format.json { render :json => { } }
      else
        notice = 'Invalid e-mail'
        format.html do
          redirect_to new_session_url, :notice => notice
        end
        format.json do
          render :json => { :error => :not_found, :text => notice }
        end
      end
    end
  end
  
  # GET /session/token/token-code
  def token
    if token = Credentials::Token.with_code(params[:code])
      auth = token.authenticate
    else
      auth = :invalid
    end
        
    if auth.is_a? Symbol
      notice = bounce_notice_text auth
      respond_to do |format|        
        format.html do
          redirect_to new_session_url, :flash => { :notice => notice,
              :auth_redirect_url => session_url }
        end
        format.json { render :json => { :error => auth, :text => notice } }
      end
    else
      self.current_user = auth
      home_with_token token
      unless performed?
        respond_to do |format|
          format.html { redirect_to session_url }
          format.json do
            user_data = current_user.as_json
            if current_user.class.include_root_in_json
              user_data = user_data['user']
            end
            render :json => { :user => user_data,
                              :csrf => form_authenticity_token }
          end
        end
      end
    end
  end

  # DELETE /session
  def destroy
    self.current_user = nil
    respond_to do |format|
      format.html { redirect_to session_url }
      format.json { head :ok }
    end
  end

  # GET /session/change_password
  def password_change
    unless current_user
      bounce_user
      return
    end

    respond_to do |format|
      format.html do
        @credential = current_user.credentials.
                                   find { |c| c.is_a? Credentials::Password }
        unless @credential
          @credential = Credentials::Password.new
          @credential.user = current_user
        end
        # Renders session/password_change.html.erb
      end
    end
  end
  
  # POST /session/change_password
  def change_password
    unless current_user
      bounce_user
      return
    end
    
    @credential = current_user.credentials.
                               find { |c| c.is_a? Credentials::Password }
    if @credential
      # An old password is set, must verify it.
      if @credential.check_password params[:old_password]
        success = @credential.update_attributes params[:credential]
      else
        success = false
        flash[:notice] = 'Incorrect old password. Please try again.'
      end
    else
      @credential = Credentials::Password.new params[:credential]
      @credential.user = current_user
      success = @credential.save
    end
    respond_to do |format|
      if success
        format.html do
          redirect_to session_url, :notice => 'Password updated'
        end
        format.json { head :ok }
      else
        format.html { render :action => :password_change }
        format.json { render :json => { :error => :invalid } }
      end
    end
  end

  # Hook for setting up the home view.
  def home
  end
  private :home
  
  # Hook for setting up the welcome view.
  def welcome
  end
  private :welcome
  
  # Hook for setting up the home view after token-based authentication.
  def home_with_token(token)
  end
  private :home_with_token

  # Hook for customizing the bounce notification text.    
  def bounce_notice_text(reason)
    case reason
    when :invalid
      'Invalid e-mail or password'
    when :blocked
      'Account blocked. Please verify your e-mail address'
    end
  end
end  # module Authpwn::SessionController

end  # namespace Authpwn
