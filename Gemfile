# frozen_string_literal: true

ruby '2.7.4'

source 'https://ezcater.jfrog.io/ezcater/api/gems/ezcater-gem-source'

gem 'avro'
gem 'avro-resolution_canonical_form', '>= 0.2.0'
gem 'bootsnap', require: false
gem 'ezcater_apm'
gem 'grape'
gem 'pg'
gem 'private_attr', require: 'private_attr/everywhere'
gem 'procto'
gem 'puma'
gem 'rails', '~> 6.0.3'
gem 'sentry-raven'

group :test do
  gem 'json_spec'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'simplecov'
end

group :development do
  gem 'annotate'
  gem 'avro_turf', '>= 0.8.0', require: false
  gem 'ezcater_docker_shared', require: false
  gem 'heroku_rails_deploy', '>= 0.4.1', require: false
  gem 'overcommit'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-rubocop'
  gem 'spring-watcher-listen'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'salsify_rubocop', require: false
end
