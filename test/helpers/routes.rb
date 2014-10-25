def setup_authpwn_routes
  # The routes used in all the tests.
  routes = ActionDispatch::Routing::RouteSet.new
  routes.draw do
    resource :cookie, controller: 'cookie' do
      collection do
        get :bouncer
        put :update
      end
    end
    resource :http_basic, controller: 'http_basic' do
      collection { get :bouncer }
    end

    authpwn_session controller: 'bare_session', method_names: 'bare_session',
                    omniauth_path_prefix: '/bare_auth'
    authpwn_session controller: 'bare_session2',
                    method_names: 'bare_session2',
                    omniauth_path_prefix: '/bare_auth2'
    root to: 'session#index'

    # NOTE: this route should be kept in sync with the session template.
    authpwn_session
  end

  # NOTE: this must happen before any ActionController or ActionMailer tests
  #       run
  ApplicationController.send :include, routes.url_helpers
  ActionMailer::Base.send :include, routes.url_helpers

  # NOTE: ActionController tests expect @routes to be set to the drawn routes.
  #       We use the block form of define_method to capture the routes local
  #       variable.
  ActionController::TestCase.send :define_method, :setup_authpwn_routes do
    @routes = routes
  end
  ActionController::TestCase.setup :setup_authpwn_routes
end

setup_authpwn_routes
