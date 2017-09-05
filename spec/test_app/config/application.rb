require_relative 'boot'

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
begin
  require "active_job/railtie"
rescue LoadError
end
require "sprockets/railtie"
require "olive_branch"

Bundler.require(*Rails.groups)

module TestApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    if config.respond_to?(:load_defaults)
      config.load_defaults 5.1
    end

    config.middleware.use OliveBranch::Middleware

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
