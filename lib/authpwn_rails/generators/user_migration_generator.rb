# :nodoc: namespace
module AuthpwnRails


class UserMigrationGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def create_session_model
    template 'user_token.rb',
             File.join('app/models', class_path, 'user.rb')
    template '001_create_users.rb',
        File.join('db/migrations', '20100725000001_create_users.rb')
    template 'users.yml', File.join('test/fixtures', 'users.yml')
  end
end  # class AuthpwnRails::UserMigrationGenerator

end  # namespace AuthpwnRails
