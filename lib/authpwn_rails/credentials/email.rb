# :namespace
module Credentials
  
# Associates an e-mail address with the user account.
class Email < ::Credential
  # The e-mail address.
  validates :name, :format => /^[A-Za-z0-9.+_]+@[^@]*\.(\w+)$/,
       :presence => true, :length => 1..128, :uniqueness => { :scope => [:type],
       :message => 'This e-mail address is already claimed by an account' }

  before_validation :set_key_to_false, :on => :create
  # :nodoc: by default, e-mail addresses are not verified
  def set_key_to_not_verified
    self.key ||= false if self.key.nil?
  end
end  # class Credentials::Email 

end  # namespace Credentials
