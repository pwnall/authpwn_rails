# See the OmniAuth documentation for the contents of this file.
#
#     https://github.com/intridea/omniauth
#     https://github.com/intridea/omniauth/wiki

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?

  # provider :twitter, Rails.application.secrets.twitter_api_key,
  #                    Rails.application.secrets.twitter_api_secret
end

OmniAuth.config.logger = Rails.logger
