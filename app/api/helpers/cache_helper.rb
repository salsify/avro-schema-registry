module Helpers
  module CacheHelper

    CACHE_CONTROL_HEADER = 'Cache-Control'.freeze
    CACHE_CONTROL_VALUE = "public, max-age=#{Rails.configuration.x.cache_max_age}".freeze

    def cache_response!
      header(CACHE_CONTROL_HEADER, CACHE_CONTROL_VALUE) if Rails.configuration.x.allow_response_caching
    end
  end
end
