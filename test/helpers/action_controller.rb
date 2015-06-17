# Raise exceptions so we can test require / permit on params.
ActionController::Parameters.action_on_unpermitted_parameters = :raise

# By default, CSRF protection is turned off in tests.
ActionController::Base.allow_forgery_protection = false
