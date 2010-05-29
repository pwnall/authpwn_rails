# :nodoc: the routes used in all tests
class ActionController::TestCase
  setup do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do |map|
      resource :session, :controller => 'session'
      resource :facebook, :controller => 'facebook'
    end
  end
end
