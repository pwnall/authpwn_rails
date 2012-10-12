# :namespace
module Tokens

# Lets the user to change their password without knowing the old one.
class PasswordReset < Tokens::OneTime
  # Decent compromise between convenience and security.
  self.expires_after = 3.days

  # Blanks the user's old password, so the new password form won't ask for it.
  #
  # Returns the token instance.
  def spend
    self.transaction do
      if credential = password_credential
        credential.destroy
      end
      super
    end
  end

  # The credential that is removed by this token.
  #
  # This method might return nil if a user initiates password recovery multiple
  # times.
  def password_credential
    user.credentials.find { |c| c.is_a? Credentials::Password }
  end
end  # class Tokens::PasswordReset

end  # namespace Tokens
