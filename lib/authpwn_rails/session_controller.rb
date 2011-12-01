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
    authenticates_using_session
  end

  # Included in controllers that include Authpwn::SessionController.
  module InstanceMethods
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
  
    # GET /session/token/token-code
    def token
      auth = Credentials::Token.authenticate params[:code]
      self.current_user = auth unless auth.kind_of? Symbol
          
      respond_to do |format|
        if current_user
          format.html { redirect_to session_url }
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
                :auth_redirect_url => session_url }
          end
          format.json { render :json => { :error => auth, :text => notice } }
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
  
    # Hook for setting up the home view.
    def home
    end
    private :home
    
    # Hook for setting up the welcome view.
    def welcome
    end
    private :welcome

    # Hook for customizing the bounce notification text.    
    def bounce_notice_text(reason)
      case reason
      when :invalid
        'Invalid e-mail or password'
      when :blocked
        'Account blocked. Please verify your e-mail address'
      end
    end
  end  # module Authpwn::SessionController::InstanceMethods

end  # module Authpwn::SessionController

end  # namespace Authpwn
