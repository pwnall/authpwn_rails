# :nodoc: namespace
module Authpwn

# Included by the session mailer class.
#
# Parts of the codebase assume the mailer will be named SessionMailer.
module SessionMailer
  # Creates an e-mail containing a password reset token.
  #
  # Params:
  #   token:: the password reset token
  #   root_url:: url to the server's home page
  #   token_url:: the password reset url, including the secret token
  def reset_password_email(token, root_url, token_url)
    @token, @root_url, @token_url = token, root_url, token_url

    mail :to => @token.user.email,
         :subject => reset_password_subject(token, root_url),
         :from => reset_password_from(token, root_url) do |format|
      format.html  # session_mailer/reset_password.html.erb
      format.text  # session_mailer/reset_password.text.erb
    end
  end
  
  # The subject line in a password reset e-mail.
  def reset_password_subject(token, root_url)
    "#{root_url} password reset"
  end
  
  # The sender e-mail address for a password reset e-mail.
  def reset_password_from(token, root_url)
    "#{root_url} staff <admin@site.com>"
  end
end  # namespace Authpwn::SessionMailer

end  # namespace Authpwn
