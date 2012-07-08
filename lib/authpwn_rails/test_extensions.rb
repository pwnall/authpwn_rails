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
    # flexmock.new_instances doesn't work because ActiveRecord doesn't use new
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
    request.session[:user_exuid] = user ? user.to_param : nil
  end
  
  # The authenticated user in the test session.
  def session_current_user
    return nil unless user_param = request.session[:user_exuid]
    User.find_by_param user_param
  end

  # Sets the HTTP Authentication header.
  #
  # If no password is provided, the user's password is set to "password". This
  # change is normally reverted at the end of the test, as long as
  # transactional fixtures are not disabled.
  #
  # Tests that need to disable transactional fixures should specify the user's
  # password.
  def set_http_basic_user(user, password = nil)
    unless password
      password = 'password'
      credential = Credentials::Password.where(:user_id => user.id).first
      if credential
        credential.update_attributes! :password => password
      else
        credential = Credentials::Password.new :password => password
        credential.user_id = user.id
        credential.save!
      end
    end

    credential = Credentials::Email.where(:user_id => user.id).first
    unless credential
      raise RuntimeError, "Can't specify an user without an e-mail"
    end
    email = credential.email

    request.env['HTTP_AUTHORIZATION'] =
        "Basic #{::Base64.strict_encode64("#{email}:#{password}")}"
    user
  end
end  # module Authpwn::ControllerTestExtensions

end  # namespace Authpwn

class ActionController::TestCase
  include Authpwn::ControllerTestExtensions
end
