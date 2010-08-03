# :nodoc: namespace
module AuthpwnRails


class SessionViewsGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def create_session_views
    copy_file File.join('session', 'home.html.erb'),
              File.join('app', 'views', 'session', 'home.html.erb')
    copy_file File.join('session', 'welcome.html.erb'),
              File.join('app', 'views', 'session', 'welcome.html.erb')
  end
end  # class AuthpwnRails::SessionViewsGenerator

end  # namespace AuthpwnRails
