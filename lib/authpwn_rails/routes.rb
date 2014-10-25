require 'action_pack'

# :nodoc: namespace
module Authpwn

# :nodoc: namespace
module Routes

# :nodoc: mixed into ActionPack's route mapper.
module MapperMixin
  # Draws the routes for a session controller.
  #
  # @param [Object] options
  # @option options [String] controller the name of the controller; defaults to
  #     "session" for SessionController
  # @option options [String] paths the prefix of the route paths; defaults to
  #     the controller name
  # @option options [String] method_names the root of name used in the path
  #     methods; defaults to "session", which will generate names like
  #     session_path, new_session_path, and token_session_path
  # @option options [String] omniauth_path_prefix the prefix of the OmniAuth
  #     route paths; defaults to '/auth'; this option should equal
  #     OmniAuth.config.path_prefix
  def authpwn_session(options = {})
    controller = options[:controller] || 'session'
    paths = options[:paths] || controller
    methods = options[:method_names] || 'session'
    oa_prefix = options[:omniauth_path_prefix] || '/auth'

    get "/#{paths}/token/:code", controller: controller, action: 'token',
                                 as: :"token_#{methods}"

    get "/#{paths}", controller: controller, action: 'show',
                     as: :"#{methods}"
    get "/#{paths}/new", controller: controller, action: 'new',
                         as: :"new_#{methods}"
    post "/#{paths}", controller: controller, action: 'create'
    delete "/#{paths}", controller: controller, action: 'destroy'

    get "/#{paths}/change_password", controller: controller,
                                    action: 'password_change',
                                    as: "change_password_#{methods}"
    post "/#{paths}/change_password", controller: controller,
                                     action: 'change_password'
    post "/#{paths}/reset_password", controller: controller,
                                     action: 'reset_password',
                                     as: "reset_password_#{methods}"

    match "#{oa_prefix}/:provider/callback", via: [:get, :post],
                                             controller: controller,
                                             action: 'omniauth',
                                             as: "omniauth_#{methods}"
    get "#{oa_prefix}/failure", controller: controller,
                                action: 'omniauth_failure',
                                as: "omniauth_failure_#{methods}"
  end
end

ActionDispatch::Routing::Mapper.send :include, MapperMixin

end  # namespace Authpwn::Routes

end  # namespace Authpwn
