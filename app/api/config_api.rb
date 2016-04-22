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

  helpers do
    def find_subject!(name)
      Subject.eager_load(:config).find_by!(name: name)
    end
  end

  desc 'Get top-level config'
  get '/' do
    { compatibility: Config.global.compatibility }
  end

  desc 'Update compatibility requirements globally'
  params { requires :compatibility, type: String }
  put '/' do
    config = Config.global
    config.update_compatibility!(params[:compatibility])
    { compatibility: config.compatibility }
  end

  desc 'Get compatibility level for a subject'
  params do
    requires :subject, type: String, desc: 'Subject name'
  end
  get '/:subject', requirements: { name: Subject::NAME_REGEXP } do
    subject = find_subject!(params[:subject])
    { compatibility: subject.config.try(:compatibility) }
  end

  desc 'Update compatibility requirements for a subject'
  params do
    requires :subject, type: String, desc: 'Subject name'
    requires :compatibility, type: String
  end
  put '/:subject', requirements: { name: Subject::NAME_REGEXP } do
    subject = find_subject!(params[:subject])
    subject.create_config! unless subject.config
    subject.config.update_compatibility!(params[:compatibility])
    { compatibility: subject.config.compatibility }
  end
end
