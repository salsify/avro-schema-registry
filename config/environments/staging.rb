require Rails.root.join('config/environments/production')

Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/environments/production.rb.

  config.log_level = :debug
end
