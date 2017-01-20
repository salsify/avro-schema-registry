ruby '2.3.1'

source 'https://rubygems.org'

gem 'avro-salsify-fork', '1.9.0.3', require: 'avro'
gem 'grape'
gem 'ice_nine', require: 'ice_nine/core_ext/object'
gem 'pg'
gem 'private_attr', require: 'private_attr/everywhere'
gem 'puma'
gem 'rails', '4.2.7'
gem 'rails-api'

group :test do
  gem 'json_spec'
  gem 'rspec-rails'
  gem 'simplecov'
end

group :production do
  gem 'bugsnag'
end

group :development do
  gem 'annotate'
  gem 'heroku_rails_deploy', '>= 0.2.2', require: false
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
  gem 'factory_girl_rails'
  gem 'salsify_rubocop', require: false
end
