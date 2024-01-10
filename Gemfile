# frozen_string_literal: true

ruby '3.2.2'

source 'https://rubygems.org'

gem 'avro', '~> 1.10.0'
gem 'avro-resolution_canonical_form', '>= 0.2.0'
gem 'bootsnap', require: false
gem 'grape'
gem 'pg'
gem 'private_attr', require: 'private_attr/everywhere'
gem 'procto'
gem 'puma', '>= 5.6.7'
gem 'rails', '~> 6.0.3'

group :test do
  gem 'json_spec'
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'simplecov'
end

group :production do
  gem 'bugsnag'
end

group :development do
  gem 'annotate'
  gem 'avro_turf', '>= 0.8.0', require: false
  gem 'heroku_rails_deploy', '>= 0.4.1', require: false
  gem 'overcommit'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-rubocop'
  gem 'spring-watcher-listen'
end

group :development, :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'salsify_rubocop', require: false
end
