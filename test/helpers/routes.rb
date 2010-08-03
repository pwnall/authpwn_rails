# :nodoc: the routes used in all tests
class ActionController::TestCase
  def setup_routes
    @routes = ActionController::Routing::RouteSet.new
    @routes.draw do
      resource :cookie, :controller => 'cookie'
      resource :facebook, :controller => 'facebook'
      resource :session, :controller => 'session'
      root :to => 'session#index'
    end
    ApplicationController.send :include, @routes.url_helpers
  end
  
  setup :setup_routes
end