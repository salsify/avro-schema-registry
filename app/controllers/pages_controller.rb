# frozen_string_literal: true

class PagesController < ApplicationController

  # This page is primarily for the benefit of the schema registry hosted
  # at avro-schema-registry.salsify.com
  def index
    render(file: "#{Rails.root}/public/index.html", layout: false)
  end

  # This page is displayed after successfully deploying the app using the
  # Heroku button.
  def success
    render(file: "#{Rails.root}/public/success.html", layout: false)
  end
end
