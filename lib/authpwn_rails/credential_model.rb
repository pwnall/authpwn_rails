require 'active_support'

# :nodoc: namespace
module Authpwn

# Included by the model class that represents facebook tokens.
#
# Parts of the codebase assume the model will be named Credential.
module CredentialModel
  extend ActiveSupport::Concern

  included do
    # The user whose token this is.
    belongs_to :user, :inverse_of => :credentials
    validates :user, :presence => true
    
    # Name that can be used to find the token.
    validates :name, :length => { :in => 1..32, :allow_nil => true },
                     :uniqueness => { :scope => [:type], :allow_nil => true }
  
    # Secret information associated with the token.
    serialize :key, JSON
    validates :key, :length => { :in => 1..2.kilobytes, :allow_nil => true }
  end

  # Included in the metaclass of models that call pwnauth_facebook_token_model.
  module ClassMethods
    
  end  # module Authpwn::FacebookTokenModel::ClassMethods

  
  # Included in models that include Authpwn::FacebookTokenModel.
  module InstanceMethods
    
  end  # module Authpwn::FacebookTokenModel::InstanceMethods
  
end  # namespace Authpwn::FacebookTokenModel

end  # namespace Authpwn
