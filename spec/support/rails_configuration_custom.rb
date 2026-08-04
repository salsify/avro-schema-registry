# frozen_string_literal: true

# Monkey-patch Rails::Application::Configuration::Custom to allow configuration
# to be stubbed.
module Rails
  class Application::Configuration::Custom
    def respond_to_missing?(*)
      true
    end
  end
end
