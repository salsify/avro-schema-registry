# frozen_string_literal: true

require 'heroku_rails_deploy/deployer'

module DualHerokuRailsDeploy

  def self.deploy(root_dir, args)
    config_file = File.join(root_dir, 'config', 'heroku.yml')
    deploy = HerokuRailsDeploy::Deployer.new(config_file, args)
    deploy.run

    HerokuRailsDeploy::Deployer.new(config_file, %w(-e compatibility)).run if deploy.production?
  end
end
