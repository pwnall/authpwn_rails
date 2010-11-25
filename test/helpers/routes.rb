# :nodoc: the routes used in all tests
class ActionController::TestCase
  def setup_routes
    @routes = ActionController::Routing::RouteSet.new
    @routes.draw do
      resource :cookie, :controller => 'cookie' do
        collection { get :bouncer }
      end
      resource :facebook, :controller => 'facebook'
      # NOTE: this route should be kept in sync with the session template.
      resource :session, :controller => 'session'
      root :to => 'session#index'
    end
    ApplicationController.send :include, @routes.url_helpers
  end
  
  setup :setup_routes
end
