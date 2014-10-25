# Raise exceptions so we can test require / permit on params.
ActionController::Parameters.action_on_unpermitted_parameters = :raise
