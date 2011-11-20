require 'authpwn_rails'
require 'rails'

# :nodoc: namespace
module Authpwn

class Engine < Rails::Engine
  generators do
    require 'authpwn_rails/generators/all_generator.rb'
  end
  
  initializer 'authpwn.rspec.extensions' do
    begin
      require 'rspec'
      
      RSpec.configure do |c|
        c.include Authpwn::TestExtensions
      end
    rescue LoadError
      # No RSpec, no extensions.
    end
  end
end  # class Authpwn::Engine

end  # namespace Authpwn
