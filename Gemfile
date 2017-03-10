ruby '2.3.3'

source 'https://rubygems.org'

gem 'avro-salsify-fork', '1.9.0.5', require: 'avro'

gem 'avro-resolution_canonical_form', '0.1.0.rc0'
gem 'grape'
gem 'ice_nine', require: 'ice_nine/core_ext/object'
gem 'pg'
gem 'private_attr', require: 'private_attr/everywhere'
gem 'puma'
gem 'rails', '5.0.1'

group :test do
  gem 'json_spec'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'simplecov'
end

group :production do
  gem 'bugsnag'
end

group :development do
  gem 'annotate'
  gem 'avro_turf', '>= 0.8.0', require: false
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
