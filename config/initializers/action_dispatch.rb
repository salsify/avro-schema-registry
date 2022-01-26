# frozen_string_literal: true

# Patches CVE-2021-22942 https://github.com/advisories/GHSA-2rqw-v265-jf8c
# This module can be removed when Rails updated to 6.0.4.1 or >= 6.1.4.1
module ActionDispatch
  class HostAuthorization
    HOSTNAME = /[a-z0-9.-]+|\[[a-f0-9]*:[a-f0-9.:]+\]/i.freeze
    VALID_ORIGIN_HOST = /\A(#{HOSTNAME})(?::\d+)?\z/.freeze
    VALID_FORWARDED_HOST = /(?:\A|,[ ]?)(#{HOSTNAME})(?::\d+)?\z/.freeze

    private

    def authorized?(request)
      origin_host =
        request.get_header('HTTP_HOST')&.slice(VALID_ORIGIN_HOST, 1) || ''
      forwarded_host =
        request.x_forwarded_host&.slice(VALID_FORWARDED_HOST, 1) || ''
      @permissions.allows?(origin_host) &&
        (forwarded_host.blank? || @permissions.allows?(forwarded_host))
    end
  end
end
