require 'heroku_rails_deploy/deployer'

module DualHerokuRailsDeploy

  COMPATIBILITY_ENVIRONMENT_ARGS = %w(-e compatibility).map(&:freeze).freeze

  def self.deploy(root_dir, args)
    config_file = File.join(root_dir, 'config', 'heroku.yml')
    deploy = HerokuRailsDeploy::Deployer.new(config_file, args)
    deploy.run

    if deploy.production?
      HerokuRailsDeploy::Deployer.new(config_file, COMPATIBILITY_ENVIRONMENT_ARGS).run
    end
  end
end
