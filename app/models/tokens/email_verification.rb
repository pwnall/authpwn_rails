# :namespace
module Tokens

# A token that verifies the user's ownership of their e-mail address.
class EmailVerification < Tokens::OneTime
  # The e-mail address verified by this token.
  #
  # Note that it's useful to keep track of the exact e-mail address that the
  # token vouches for, even if an application only allows a single e-mail per
  # user. Otherwise, a user might be able to change their e-mail address and
  # then use the token to verify the ownership of the wrong address.
  alias_attribute :email, :key
  validates :email, presence: true

  # Verification tokens only work this much time after they have been issued.
  self.expires_after =
      Authpwn::Engine.config.authpwn.email_verification_expiration

  # Creates a token with a random code that verifies the given e-mail address.
  def self.random_for(email_credential)
    super email_credential.user, email_credential.email, self
  end

  # Marks the e-mail associated with the token as verified.
  #
  # Returns the token instance.
  def spend
    self.transaction do
      if credential = self.email_credential
        credential.verified = true
        credential.save!
      end
      super
    end
  end

  # The credential whose ownership is verified by this token.
  #
  # @return [Credentials::Email, nil] might return nil if a user is trying to
  #     take advantage of a race condition and changes her e-mail address
  #     before using the token.
  def email_credential
    user.credentials.where(name: email).first
  end
end  # class Tokens::EmailVerification

end  # namespace Tokens
