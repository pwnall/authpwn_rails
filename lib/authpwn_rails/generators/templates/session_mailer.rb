class SessionMailer < ActionMailer::Base
  include Authpwn::SessionMailer

  def email_verification_subject(token, server_hostname, protocol)
    # Consider replacing the hostname with a user-friendly application name.
    "#{server_hostname} e-mail verification"
  end

  def email_verification_from(token, server_hostname, protocol)
    # You most likely need to replace the e-mail address below.
    %Q|"#{server_hostname} staff" <admin@#{server_hostname}>|
  end

  def reset_password_subject(token, server_hostname, protocol)
    # Consider replacing the hostname with a user-friendly application name.
    "#{server_hostname} password reset"
  end

  def reset_password_from(token, server_hostname, protocol)
    # You most likely need to replace the e-mail address below.
    %Q|"#{server_hostname} staff" <admin@#{server_hostname}>|
  end

  # You shouldn't extend the session mailer, so you can benefit from future
  # features. But, if you must, you can do it here.
end
