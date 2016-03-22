Rails.application.routes.draw do
  mount SchemaAPI => '/schemas'
  mount SubjectAPI => '/subjects'
end
