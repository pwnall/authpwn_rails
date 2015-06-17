# :nodoc: namespace
module Authpwn

# Included in all test cases.
module TestExtensions
  # Stubs User#auth_bounce_reason to block a given credential.
  #
  # The default implementation of User#auth_bounce_reason always returns nil.
  # Your application's implementation might differ. Either way, the method is
  # replaced for the duration of the block, such that it returns :block if
  # the credential matches the given argument, and nil otherwise.
  def with_blocked_credential(blocked_credential, reason = :blocked, &block)
    # Stub a method in all User instances for this test only.
    # mocha.any_instance doesn't work because ActiveRecord doesn't use new
    # to instantiate records.
    ::User.class_eval do
      alias_method :_auth_bounce_reason_wbc_stub, :auth_bounce_reason
      define_method :auth_bounce_reason do |credential|
        credential == blocked_credential ? reason : nil
      end
    end

    begin
      yield
    ensure
      ::User.class_eval do
        undef_method :auth_bounce_reason
        alias_method :auth_bounce_reason, :_auth_bounce_reason_wbc_stub
        undef_method :_auth_bounce_reason_wbc_stub
      end
    end
  end
end  # module Authpwn::TestExtensions

class ActiveSupport::TestCase
  include Authpwn::TestExtensions
end

# Included in controller test cases.
module ControllerTestExtensions
  # Sets the authenticated user in the test session.
  def set_session_current_user(user)
    if user
      # Avoid database inserts, if at all possible.
      if token = Tokens::SessionUid.where(user_id: user.id).first
        token.spend  # Only bump updated_at if necessary.
      else
        token = Tokens::SessionUid.random_for user, '127.0.0.1', 'UnitTests'
      end
      request.session[:authpwn_suid] = token.suid
    else
      request.session.delete :authpwn_suid
    end
  end

  # The authenticated user in the test session.
  def session_current_user
    return nil unless suid = request.session[:authpwn_suid]
    Tokens::Base.with_code(suid).first!.user
  end

  # Sets the HTTP Authentication header for Basic authentication.
  #
  # If no password is provided, the user's password is set to "password". This
  # change is normally reverted at the end of the test, as long as
  # transactional fixtures are not disabled.
  #
  # Tests that need to disable transactional fixures should specify the user's
  # password.
  def set_http_basic_user(user, password = nil)
    if user.nil?
      request.env.delete 'HTTP_AUTHORIZATION'
      return self
    end

    if password.nil?
      password = 'password'
      credential = Credentials::Password.where(user_id: user.id).first
      if credential
        credential.update_attributes! password: password
      else
        credential = Credentials::Password.new password: password
        credential.user_id = user.id
        credential.save!
      end
    end

    credential = Credentials::Email.where(user_id: user.id).first
    unless credential
      raise RuntimeError, "Can't specify an user without an e-mail"
    end
    email = credential.email

    request.env['HTTP_AUTHORIZATION'] =
        "Basic #{::Base64.strict_encode64("#{email}:#{password}")}"
    self
  end

  # Sets the HTTP Authentication header for Token authentication.
  #
  # If the user doesn't have an API token, one is generated automatically. This
  # change is normally reverted at the end of the test, as long as
  # transactional fixtures are not disabled.
  #
  # If a token code is provided, the user's API token's code is forced to the
  # given value.
  #
  # Tests that need to disable transactional fixures should delete the user's
  # API token after completion.
  def set_http_token_user(user, token_code = nil)
    if user.nil?
      request.env.delete 'HTTP_AUTHORIZATION'
      return self
    end

    credential = Tokens::Api.where(user_id: user.id).first
    credential ||= Tokens::Api.random_for(user)
    unless token_code.nil?
      credential.code = token_code
      credential.save!
    end

    request.env['HTTP_AUTHORIZATION'] = "Token #{credential.code}"
    self
  end
end  # module Authpwn::ControllerTestExtensions

end  # namespace Authpwn

class ActionController::TestCase
  include Authpwn::ControllerTestExtensions
end
