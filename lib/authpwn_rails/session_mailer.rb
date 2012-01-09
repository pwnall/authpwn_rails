# :nodoc: namespace
module Authpwn

# Included by the session mailer class.
#
# Parts of the codebase assume the mailer will be named SessionMailer.
module SessionMailer
  # Creates an e-mail containing a password reset token.
  #
  # Params:
  #   email:: the email to send the token to
  #   token:: the password reset token
  #   host:: the server's hostname (e.g. "localhost:3000")
  def reset_password_email(email, token, host)
    @email, @token, @host = email, token, host

    hostname = host.split(':', 2).first  # Strip out any port.
    mail :to => email, :subject => reset_password_subject(token, hostname),
         :from => reset_password_from(token, hostname)
  end
  
  # The subject line in a password reset e-mail.
  #
  # The authpwn generator encourages applications to override this method.
  def reset_password_subject(token, server_hostname)
    "#{server_hostname} password reset"
  end
  
  # The sender e-mail address for a password reset e-mail.
  #
  # The authpwn generator encourages applications to override this method.
  def reset_password_from(token, server_hostname)
    %Q|"#{server_hostname} staff" <admin@#{server_hostname}>|
  end
end  # namespace Authpwn::SessionMailer

end  # namespace Authpwn
