# :nodoc: stubbed, because controllers inherit from it
class ApplicationController < ActionController::Base
  prepend_view_path File.expand_path(
      '../../../lib/authpwn_rails/generators/templates', __FILE__)

  # This is necessary for testing CSRF exceptions in API calls.
  protect_from_forgery with: :exception
end
