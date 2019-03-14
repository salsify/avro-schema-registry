# frozen_string_literal: true

module Grape
  module Middleware
    # This middleware allows HTTP Basic/Digest middleware to be bypassed based
    # on configuration.
    class OptionalAuth < Grape::Middleware::Auth::Base
      def call(env)
        Rails.configuration.x.disable_password ? app.call(env) : super
      end
    end
  end
end
