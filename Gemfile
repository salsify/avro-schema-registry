ruby '2.3.1'

source 'https://rubygems.org'

gem 'puma'
gem 'rails', '4.2.6'
gem 'pg'
gem 'rails-api'
gem 'grape'
gem 'avro'
gem 'ice_nine', require: 'ice_nine/core_ext/object'
gem 'private_attr', require: 'private_attr/everywhere'

group :test do
  gem 'rspec-rails'
  gem 'json_spec'
end

group :development do
  gem 'annotate'
  gem 'spring'
  gem 'overcommit'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'salsify_rubocop', require: false
end
