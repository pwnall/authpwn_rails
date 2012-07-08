# :namespace
module Credentials
  
# Associates an e-mail address with the user account.
class Email < ::Credential
  # The e-mail address.
  alias_attribute :email, :name
  validates :name, :format => /^[A-Za-z0-9.+_]+@[^@]*\.(\w+)$/,
       :presence => true, :uniqueness => { :scope => [:type],
       :message => 'This e-mail address is already claimed by an account' }

  # '1' if the user proved ownership of the e-mail address.
  validates :key, :presence => true, :inclusion => { :in => ['0', '1'] }

  before_validation :set_verified_to_false, :on => :create
  # :nodoc: by default, e-mail addresses are not verified
  def set_verified_to_false
    self.key ||= '0' if self.key.nil?
  end
  
  # True if the e-mail has been verified via a token URL.
  def verified?
    key == '1'
  end

  # True if the e-mail has been verified via a token URL.
  def verified=(new_verified_value)
    self.key = new_verified_value ? '1' : '0'
    new_verified_value ? true : false
  end

  # Locates the user that owns an e-mail address, for authentication purposes.
  #
  # Presenting the correct e-mail is almost never sufficient for authentication
  # purposes. This method will most likely used to kick off an authentication
  # process, such as in User#authenticate_signin and
  # Password#authenticate_email.
  #
  # Returns the authenticated User instance, or a symbol indicating the reason
  # why the (potentially valid) password was rejected.
  def self.authenticate(email)
    credential = with email
    return :invalid unless credential
    user = credential.user
    user.auth_bounce_reason(credential) || user
  end
  
  # Locates the credential holding an e-mail address.
  #
  # Returns the User matching the given e-mail, or nil if the e-mail is not
  # associated with any user.
  def self.with(email)
    # This method is likely to be used to kick off a complex authentication
    # process, so it makes sense to pre-fetch the user's other credentials.
    credential = Credentials::Email.where(:name => email).
                                    includes(:user => :credentials).first
  end

  # Forms can only change the e-mail in the credential.
  attr_accessible :email
end  # class Credentials::Email

end  # namespace Credentials
