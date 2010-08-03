# :nodoc: namespace
module AuthpwnRails


class FacebookGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def create_facebook_model
    copy_file 'facebook_token.rb',
              File.join('app', 'models', 'facebook_token.rb')
    copy_file '002_create_facebook_tokens.rb',
        File.join('db', 'migrations', '20100725000002_create_facebook_tokens.rb')
    copy_file 'facebook_tokens.yml',
              File.join('test', 'fixtures', 'facebook_tokens.yml')
  end
end  # class AuthpwnRails::FacebookGenerator

end  # namespace AuthpwnRails
