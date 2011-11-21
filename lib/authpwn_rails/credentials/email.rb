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
  alias_attribute :verified, :key
  validates :verified, :presence => true

  before_validation :set_verified_to_false, :on => :create
  # :nodoc: by default, e-mail addresses are not verified
  def set_verified_to_false
    self.verified ||= '0' if self.key.nil?
  end
end  # class Credentials::Email 

end  # namespace Credentials

# :nodoc: adds e-mail integration to the user model
module Authpwn::UserModel::InstanceMethods
  def email_credential
    credentials.find { |c| c.instance_of?(Credentials::Email) }
  end
  
  # The e-mail from the user's Email credential, or nil no credential exists.
  def email
    credential = self.email_credential
    credential && credential.email
  end
end  # module Authpwn::UserModel::InstanceMethods
