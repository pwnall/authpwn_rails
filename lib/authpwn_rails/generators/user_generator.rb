# :nodoc: namespace
module AuthpwnRails


class UserGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def create_user_model
    copy_file 'user.rb', File.join('app', 'models', 'user.rb')
    copy_file '001_create_users.rb',
        File.join('db', 'migrations', '20100725000001_create_users.rb')
    copy_file 'users.yml', File.join('test', 'fixtures', 'users.yml')
  end
end  # class AuthpwnRails::UserGenerator

end  # namespace AuthpwnRails
