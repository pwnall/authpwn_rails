require 'active_model'


# :nodoc: namespace
module Authpwn

# Included by the model class that collects sign-up information.
#
# Parts of the codebase assume the model will be named Session.
module SessionModel
  extend ActiveSupport::Concern

  included do
    if defined? ActiveModel::Model
      # Rails 4.
      include ActiveModel::Model
    else
      # Rails 3.
      include ActiveModel::Conversion
      extend  ActiveModel::Naming
      extend  ActiveModel::Translation
      include ActiveModel::Validations

      def initialize(params={})
        params.each do |attr, value|
          self.public_send("#{attr}=", value)
        end if params

        super()
      end
      def persisted?
        false
      end
    end

    # The e-mail used to sign up.
    attr_accessor :email

    # The password used to sign up.
    attr_accessor :password
  end

  # Class methods on models that include Authpwn::SessionModel.
  module ClassMethods
    # Extracts signup information from a controller's params hash.
    #
    # @param [Hash] params the parameters received by a controller action
    # @return [Session] new Session instance containing the signup information
    def from_params(params)
      if params[:session]
        self.new email: params[:session][:email],
                 password: params[:session][:password]
      else
        self.new email: params[:email], password: params[:password]
      end
    end
  end  # module Authpwn::SessionModel::ClassMethods
end  # namespace Authpwn::SessionModel

end  # namespace Authpwn
