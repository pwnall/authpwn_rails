require 'action_pack'

# :nodoc: namespace
module Authpwn

# :nodoc: namespace
module Routes

# :nodoc: mixed into ActionPack's route mapper.
module MapperMixin
  # Draws the routes for a session controller.
  #
  # The options hash accepts the following keys.
  #   :controller:: the name of the controller; defaults to "session" for
  #                 SessionController
  #   :paths:: the prefix of the route paths; defaults to the controller name
  #   :method_names:: the root of name used in the path methods; defaults to
  #                   "session", which will generate names like session_path,
  #                   new_session_path, and token_session_path
  def authpwn_session(options = {})
    controller = options[:controller] || 'session'
    paths = options[:paths] || controller
    methods = options[:method_names] || 'session'
    
    get "/#{paths}/token/:code", :controller => controller, :action => 'token',
                                 :as => :"token_#{methods}"
    
    get "/#{paths}", :controller => controller, :action => 'show',
                     :as => :"#{methods}"
    get "/#{paths}/new", :controller => controller, :action => 'new',
                         :as => :"new_#{methods}"
    post "/#{paths}", :controller => controller, :action => 'create'
    delete "/#{paths}", :controller => controller, :action => 'destroy'
  end
end

ActionDispatch::Routing::Mapper.send :include, MapperMixin

end  # namespace Authpwn::Routes

end  # namespace Authpwn
