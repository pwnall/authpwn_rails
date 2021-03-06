require_relative 'test_helper'

require 'authpwn_rails/generators/templates/session_controller.rb'

# Tests the routes created by authpwn_session.
class RoutesTest < ActionController::TestCase
  tests SessionController

  test 'authpwn_session routes' do
    assert_routing({path: '/session', method: :get},
                   {controller: 'session', action: 'show'})
    assert_routing({path: '/session/new', method: :get},
                   {controller: 'session', action: 'new'})
    assert_routing({path: '/session', method: :post},
                   {controller: 'session', action: 'create'})
    assert_routing({path: '/session', method: :delete},
                   {controller: 'session', action: 'destroy'})
    assert_routing({path: '/session/api_token', method: :get},
                   {controller: 'session', action: 'api_token'})
    assert_routing({path: '/session/api_token', method: :delete},
                   {controller: 'session', action: 'destroy_api_token'})
    assert_routing({path: '/session/change_password', method: :get},
                   {controller: 'session', action: 'password_change'})
    assert_routing({path: '/session/change_password', method: :post},
                   {controller: 'session', action: 'change_password'})
    assert_routing({path: '/session/reset_password', method: :post},
                   {controller: 'session', action: 'reset_password'})

    code = 'ue5tqbx3u4z7jxxglickknirxroy7c3bgig4e2yccbmwqvf3r2vq'
    assert_routing({path: "/session/token/#{code}", method: :get},
        {controller: 'session', action: 'token', code: code})

    assert_routing({path: '/auth/failure', method: :get},
                   {controller: 'session', action: 'omniauth_failure'})
    assert_routing({path: '/auth/twitter/callback', method: :get},
                   {controller: 'session', action: 'omniauth',
                    provider: 'twitter'})
    assert_routing({path: '/auth/twitter/callback', method: :post},
                   {controller: 'session', action: 'omniauth',
                    provider: 'twitter'})
  end
end
