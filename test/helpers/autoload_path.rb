require 'active_support/dependencies'

ActiveSupport::Dependencies.autoload_paths << File.expand_path(
    '../../../app/models', __FILE__)
