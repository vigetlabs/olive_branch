Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.read_encrypted_secrets = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.log_level = :debug
  config.log_tags = [:request_id]
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
end
