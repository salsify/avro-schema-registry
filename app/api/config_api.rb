class ConfigAPI < Grape::API
  include BaseAPI

  rescue_from Compatibility::InvalidCompatibilityLevelError do
    invalid_compatibility_level!
  end

  rescue_from ActiveRecord::RecordNotFound do
    subject_not_found!
  end

  rescue_from :all do
    server_error!
  end

  desc 'Get top-level config'
  get '/' do
    { compatibility: Compatibility.global }
  end

  desc 'Update compatibility requirements globally'
  params { requires :compatibility, type: String }
  put '/' do
    compatibility = Compatibility.update!(params[:compatibility])
    { compatibility: compatibility }
  end

  desc 'Get compatibility level for a subject'
  params do
    requires :subject, type: String, desc: 'Subject name'
  end
  get '/:subject', requirements: { name: Subject::NAME_REGEXP } do
    subject = Subject.find_by!(name: params[:subject])
    { compatibility: subject.compatibility }
  end

  desc 'Update compatibility requirements for a subject'
  params do
    requires :subject, type: String, desc: 'Subject name'
    requires :compatibility, type: String
  end
  put '/:subject', requirements: { name: Subject::NAME_REGEXP } do
    subject = Subject.find_by!(name: params[:subject])
    unless subject.update(compatibility: params[:compatibility].upcase)
      if subject.errors.key?(:compatibility)
        raise Compatibility::InvalidCompatibilityLevelError.new(subject.compatibility)
      else
        server_error!
      end
    end
    { compatibility: subject.compatibility }
  end
end
