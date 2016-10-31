# :nodoc: namespace
module Authpwn

# rails g authpwn:all
class AllGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def create_user_model
    copy_file 'user.rb', File.join('app', 'models', 'user.rb')
    copy_file '001_create_users.rb',
        File.join('db', 'migrate', '20100725000001_create_users.rb')
    copy_file 'users.yml', File.join('test', 'fixtures', 'users.yml')
  end

  def create_credential_model
    copy_file 'credential.rb', File.join('app', 'models', 'credential.rb')
    copy_file '003_create_credentials.rb',
        File.join('db', 'migrate', '20100725000003_create_credentials.rb')
    copy_file 'credentials.yml',
        File.join('test', 'fixtures', 'credentials.yml')
  end

  def create_session_controller
    copy_file 'session.rb', File.join('app', 'models', 'session.rb')
    copy_file 'session_controller.rb',
              File.join('app', 'controllers', 'session_controller.rb')
    copy_file File.join('session_controller_test.rb'),
              File.join('test', 'functional', 'session_controller_test.rb')

    route "authpwn_session"
    route "root to: 'session#show'"
  end

  def create_session_views
    copy_file File.join('session', 'api_token.html.erb'),
              File.join('app', 'views', 'session', 'api_token.html.erb')
    copy_file File.join('session', 'forbidden.html.erb'),
              File.join('app', 'views', 'session', 'forbidden.html.erb')
    copy_file File.join('session', 'home.html.erb'),
              File.join('app', 'views', 'session', 'home.html.erb')
    copy_file File.join('session', 'new.html.erb'),
              File.join('app', 'views', 'session', 'new.html.erb')
    copy_file File.join('session', 'password_change.html.erb'),
              File.join('app', 'views', 'session', 'password_change.html.erb')
    copy_file File.join('session', 'welcome.html.erb'),
              File.join('app', 'views', 'session', 'welcome.html.erb')
  end

  def create_session_mailer
    copy_file 'session_mailer.rb',
              File.join('app', 'mailers', 'session_mailer.rb')
    copy_file File.join('session_mailer_test.rb'),
              File.join('test', 'functional', 'session_mailer_test.rb')
  end

  def create_session_mailer_views
    copy_file File.join('session_mailer', 'email_verification_email.html.erb'),
              File.join('app', 'views', 'session_mailer',
                        'email_verification_email.html.erb')
    copy_file File.join('session_mailer', 'email_verification_email.text.erb'),
              File.join('app', 'views', 'session_mailer',
                        'email_verification_email.text.erb')
    copy_file File.join('session_mailer', 'reset_password_email.html.erb'),
              File.join('app', 'views', 'session_mailer',
                        'reset_password_email.html.erb')
    copy_file File.join('session_mailer', 'reset_password_email.text.erb'),
              File.join('app', 'views', 'session_mailer',
                        'reset_password_email.text.erb')
  end

  def create_initializers
    copy_file 'initializer.rb',
              File.join('config', 'initializers', 'authpwn.rb')
    copy_file 'omniauth_initializer.rb',
              File.join('config', 'initializers', 'authpwn_omniauth.rb')
  end
end  # class Authpwn::AllGenerator

end  # namespace Authpwn
