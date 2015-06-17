require 'action_controller'

# :nodoc: adds authenticates_using_http_token
class ActionController::Base
  # Keeps track of the currently authenticated user via the session.
  #
  # Assumes the existence of a User model. A bare ActiveModel model will do the
  # trick. Model instances must implement id, and the model class must implement
  # find_by_id.
  def self.authenticates_using_http_token(options = {})
    include Authpwn::HttpTokenControllerInstanceMethods
    before_action :authenticate_using_http_token, options
  end
end

# :nodoc: namespace
module Authpwn

# Included in controllers that call authenticates_using_http_token.
module HttpTokenControllerInstanceMethods
  include Authpwn::CurrentUser

  # The before_action that implements authenticates_using_http_token.
  #
  # If your ApplicationController contains authenticates_using_http_token, you
  # can opt out in individual controllers using skip_before_action.
  #
  #     skip_before_action :authenticate_using_http_filter
  def authenticate_using_http_token
    return if current_user
    authenticate_with_http_token do |token_code, options|
      auth = Tokens::Api.authenticate token_code

      # NOTE: Setting the instance variable directly bypasses the session
      #       setup. Tokens are generally used in API contexts, so the session
      #       cookie would get ignored anyway.
      @current_user = auth unless auth.kind_of? Symbol
    end
  end
  private :authenticate_using_http_token

  # Inform the user that their request is forbidden.
  #
  # If a user is logged on, this renders the session/forbidden view with a HTTP
  # 403 code.
  #
  # If no user is logged in, a HTTP 403 code is returned, together with an
  # HTTP Authentication header causing the user-agent (browser) to initiate
  # http token authentication.
  def bounce_to_http_token()
    unless current_user
      request_http_token_authentication
      return
    end

    respond_to do |format|
      format.html do
        render 'session/forbidden', status: :forbidden
      end
      format.json do
        render json: { error: "You're not allowed to access that" }
      end
    end
  end
end  # module Authpwn::HttpTokenControllerInstanceMethods

end  # namespace Authpwn
