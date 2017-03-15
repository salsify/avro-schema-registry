if Rails.env.development?
  require 'avro_turf'
  require 'avro_turf/confluent_schema_registry'

  desc 'Make cacheable requests for all existing schemas in the registry'
  task cache_all_requests: [:environment] do
    raise 'registry_url must be specified' unless ENV['registry_url']

    logger = Logger.new($stdout)
    logger.level = Logger::ERROR
    client = AvroTurf::ConfluentSchemaRegistry.new(ENV['registry_url'], logger: logger)

    client.subjects.each do |subject|

      puts "Fetching schemas for subject #{subject}"
      client.subject_versions(subject).each do |version|
        subject_version = client.subject_version(subject, version)
        schema_object = Avro::Schema.parse(subject_version['schema'])
        fingerprint = schema_object.sha256_fingerprint.to_s(16)

        puts ".. Checking fingerprint #{fingerprint} for version #{subject_version['version']}"
        id = client.send(:get, "/subjects/#{subject}/fingerprints/#{fingerprint}")['id']

        puts ".. Fetching schema for id #{id}"
        client.fetch(id)
      end
    end
  end
end
