if defined?(ActionController::Parameters) &&
    ActionController::Parameters.respond_to?(
    :action_on_unpermitted_parameters=)
  # Rails 4.

  # Raise exceptions so we can test against them.
  ActionController::Parameters.action_on_unpermitted_parameters = :raise
end
