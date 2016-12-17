ruby '2.3.1'

source 'https://rubygems.org'

gem 'puma'
gem 'rails', '4.2.7'
gem 'pg'
gem 'rails-api'
gem 'grape'
gem 'avro-salsify-fork', '1.9.0.3', require: 'avro'
gem 'ice_nine', require: 'ice_nine/core_ext/object'
gem 'private_attr', require: 'private_attr/everywhere'

group :test do
  gem 'rspec-rails'
  gem 'json_spec'
end

group :production do
  gem 'bugsnag'
end

group :development do
  gem 'heroku_rails_deploy', require: false
  gem 'annotate'
  gem 'spring'
  gem 'overcommit'
end

group :development, :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'salsify_rubocop', require: false
end
