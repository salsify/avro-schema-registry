# frozen_string_literal: true

Rails.application.routes.draw do
  mount SchemaAPI => '/schemas'
  mount SubjectAPI => '/subjects'
  mount ConfigAPI => '/config'
  mount CompatibilityAPI => '/compatibility'

  get '/', to: 'pages#index'
  get '/success', to: 'pages#success'
  get '/health_check', to: 'health_checks#show'
end
