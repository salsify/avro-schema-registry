require 'heroku_rails_deploy/deployer'

module DualHerokuRailsDeploy

  def self.deploy(root_dir, args)
    config_file = File.join(root_dir, 'config', 'heroku.yml')
    deploy = HerokuRailsDeploy::Deployer.new(config_file, args)
    deploy.run

    if deploy.production?
      HerokuRailsDeploy::Deployer.new(config_file, %w(-e production-compat)).run
    end
  end
end
