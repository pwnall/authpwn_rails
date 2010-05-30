# :nodoc: the routes used in all tests
class ActionController::TestCase
  setup do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do |map|
      resource :cookie, :controller => 'cookie'
      resource :facebook, :controller => 'facebook'
      resource :session, :controller => 'session'
      root :to => 'session#index'
    end
    ApplicationController.send :include, @routes.url_helpers
  end
end
