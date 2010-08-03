# :nodoc: stubbed, because controllers inherit from it
class ApplicationController < ActionController::Base
  prepend_view_path File.expand_path(
      '../../../lib/authpwn_rails/generators/templates', __FILE__)
end
