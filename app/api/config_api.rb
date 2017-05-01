class ConfigAPI < Grape::API
  include BaseAPI

  rescue_from Compatibility::InvalidCompatibilityLevelError do
    invalid_compatibility_level!
  end

  rescue_from :all do
    server_error!
  end

  helpers do
    def find_subject!(name)
      Subject.eager_load(:config).find_by!(name: name)
    rescue ActiveRecord::RecordNotFound
      subject_not_found!
    end
  end

  desc 'Get top-level config'
  get '/' do
    { compatibility: Config.global.compatibility }
  end

  desc 'Update compatibility requirements globally'
  params { requires :compatibility, type: String }
  put '/' do
    read_only_mode! if Rails.configuration.x.read_only_mode

    config = Config.global
    config.update_compatibility!(params[:compatibility])
    { compatibility: config.compatibility }
  end

  desc 'Get compatibility level for a subject'
  params do
    requires :subject, type: String, desc: 'Subject name'
  end
  get '/:subject', requirements: { subject: Subject::NAME_REGEXP } do
    subject = find_subject!(params[:subject])
    { compatibility: subject.config.try(:compatibility) }
  end

  desc 'Update compatibility requirements for a subject'
  params do
    requires :subject, type: String, desc: 'Subject name'
    requires :compatibility, type: String
  end
  put '/:subject', requirements: { subject: Subject::NAME_REGEXP } do
    read_only_mode! if Rails.configuration.x.read_only_mode

    subject = find_subject!(params[:subject])
    subject.create_config! unless subject.config
    subject.config.update_compatibility!(params[:compatibility])
    { compatibility: subject.config.compatibility }
  end
end
