# :nodoc: namespace
module AuthpwnRails


class SessionGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def create_session
    copy_file 'session_controller.rb',
              File.join('app', 'controllers', 'session_controller.rb')    
    copy_file File.join('session', 'home.html.erb'),
              File.join('app', 'views', 'session', 'home.html.erb')
    copy_file File.join('session', 'new.html.erb'),
              File.join('app', 'views', 'session', 'new.html.erb')
    copy_file File.join('session', 'welcome.html.erb'),
              File.join('app', 'views', 'session', 'welcome.html.erb')

    route "resource :session, :controller => 'session'"
  end
end  # class AuthpwnRails::SessionViewsGenerator

end  # namespace AuthpwnRails
