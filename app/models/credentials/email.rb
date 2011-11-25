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

  # Forms can only change the e-mail in the credential.
  attr_accessible :email
end  # class Credentials::Email 

end  # namespace Credentials
