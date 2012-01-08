# :nodoc: add our views to the path
class ActionMailer::Base
  prepend_view_path File.expand_path(
      '../../../lib/authpwn_rails/generators/templates', __FILE__)

  self.delivery_method = :test
end
