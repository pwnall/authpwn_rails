# :nodoc: namespace
module Authpwn

# Common code for credentials that expire.
module Expires
  extend ActiveSupport::Concern

  included do
    # Number of seconds after which a credential becomes unusable.
    #
    # Users can reset this timer by updating their credentials, e.g. changing
    # their password.
    class_attribute :expires_after, :instance_writer => false
  end

  # True if this password is too old and should not be used for authentication.
  def expired?
    return false unless expires_after
    updated_at < Time.now - expires_after
  end
end  # module Authpwn::Expires

end  # namespace Authpwn
