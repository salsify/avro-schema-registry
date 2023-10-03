# frozen_string_literal: true

# Simple configuration based on
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

workers Integer(ENV['WEB_WORKER_PROCESSES'] || 2)
threads_count = Integer(ENV['MAX_WEB_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

port        ENV['PORT']     || 21000
environment ENV['RACK_ENV'] || 'development'
