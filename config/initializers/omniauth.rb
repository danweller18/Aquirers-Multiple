module OmniAuth
  module Strategies
    autoload :Yahoo, 'lib/oauth-strategies/yahoo'
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :yahoo, 'dj0yJmk9Y25oanNuZEJWaWNKJmQ9WVdrOVJXaFdSRTAxTnpJbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD00Yg--', '9b192981a36df79e32a93f60cfa1f8bedee4f60e'
end
