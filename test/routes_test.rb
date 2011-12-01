require File.expand_path('../test_helper', __FILE__)

require 'authpwn_rails/generators/templates/session_controller.rb'

# Tests the routes created by authpwn_session.
class RoutesTest < ActionController::TestCase
  tests SessionController

  test "authpwn_session routes" do
    assert_routing({:path => "/session", :method => :get},
                   {:controller => 'session', :action => 'show'})
    assert_routing({:path => "/session/new", :method => :get},
                   {:controller => 'session', :action => 'new'})
    assert_routing({:path => "/session", :method => :post},
                   {:controller => 'session', :action => 'create'})
    assert_routing({:path => "/session", :method => :delete},
                   {:controller => 'session', :action => 'destroy'})
  end
end
