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
end  # module Authpwn::ControllerTestExtensions

end  # namespace Authpwn

# :nodoc: extend Test::Unit
class ActiveSupport::TestCase
  include Authpwn::TestExtensions
end

# :nodoc: extend Test::Unit
class ActionController::TestCase
  include Authpwn::ControllerTestExtensions
end
