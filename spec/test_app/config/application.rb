require_relative 'boot'

require 'action_controller/railtie'
require 'olive_branch'

Bundler.require(*Rails.groups)

module TestApp
  # Application
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1 if config.respond_to?(:load_defaults)

    config.middleware.use OliveBranch::Middleware
  end
end
