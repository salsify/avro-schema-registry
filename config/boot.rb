ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'rails/commands/server'

Rails::Server.class_eval do
  def default_options
    super.merge(Port: 21000)
  end
end
