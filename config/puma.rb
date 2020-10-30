# frozen_string_literal: true

# Simple configuration based on
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
threads_count = ENV['MAX_WEB_THREADS'] || 5
threads threads_count, threads_count

rackup      DefaultRackup
port        ENV['PORT']     || 21004
environment ENV['RACK_ENV'] || 'development'
