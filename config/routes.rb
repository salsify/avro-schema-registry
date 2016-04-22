Rails.application.routes.draw do
  mount SchemaAPI => '/schemas'
  mount SubjectAPI => '/subjects'
  mount ConfigAPI => '/config'
  mount CompatibilityAPI => '/compatibility'
end
