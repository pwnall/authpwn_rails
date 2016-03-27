# Fake application.
module AuthpwnApp
  class Application
    def config
      @_config ||= Authpwn::Engine.config
    end
  end
end

# Mock Rails.application.
module Rails
  class <<self
    # Used by the initializer.
    alias_method :_real_application, :application
    def application
      @_app ||= AuthpwnApp::Application.new
    end
  end
end
