class HealthChecksController < ApplicationController
  OK_RESPONSE = { status: :OK }.freeze

  def show
    render json: OK_RESPONSE
  end
end
