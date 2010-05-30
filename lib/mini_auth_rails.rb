# :nodoc: namespace
module MiniAuthRails
end

require 'mini_auth_rails/facebook_token.rb'
require 'mini_auth_rails/session.rb'

if defined?(Rails)
  require 'mini_auth_rails/engine.rb'
end
