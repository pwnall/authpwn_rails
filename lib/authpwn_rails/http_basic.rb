require 'action_controller'

# :nodoc: adds authenticates_using_http_basic
class ActionController::Base
  # Keeps track of the currently authenticated user via the session.
  #
  # Assumes the existence of a User model. A bare ActiveModel model will do the
  # trick. Model instances must implement id, and the model class must
  # implement find_by_id.
  def self.authenticates_using_http_basic(options = {})
    include Authpwn::HttpBasicControllerInstanceMethods
    before_filter :authenticate_using_http_basic, options
  end
end

# :nodoc: namespace
module Authpwn

# Included in controllers that call authenticates_using_http_basic.
module HttpBasicControllerInstanceMethods
  include Authpwn::CurrentUser

  # Filter that implements authenticates_using_http_basic.
  #
  # If your ApplicationController contains authenticates_using_http_basic, you
  # can opt out in individual controllers using skip_before_filter.
  #
  #     skip_before_filter :authenticate_using_http_filter
  def authenticate_using_http_basic
    return if current_user
    authenticate_with_http_basic do |email, password|
      signin = Session.new email: email, password: password
      auth = User.authenticate_signin signin
      self.current_user = auth unless auth.kind_of? Symbol
    end
  end
  private :authenticate_using_http_basic

  # Inform the user that their request is forbidden.
  #
  # If a user is logged on, this renders the session/forbidden view with a HTTP
  # 403 code.
  #
  # If no user is logged in, a HTTP 403 code is returned, together with an
  # HTTP Authentication header causing the user-agent (browser) to initiate
  # http basic authentication.
  def bounce_to_http_basic()
    unless current_user
      request_http_basic_authentication
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
end  # module Authpwn::HttpBasicControllerInstanceMethods

end  # namespace Authpwn
