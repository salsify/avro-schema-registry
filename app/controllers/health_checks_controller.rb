class HealthChecksController < ApplicationController
  OK_RESPONSE = { status: :OK }.freeze

  def show
    # Verify Postgres connection is healthy
    ApplicationRecord.connection.select_value('select true'.freeze)

    render json: OK_RESPONSE
  end
end
