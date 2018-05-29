# avro-schema-registry

## v0.13.3
- Upgrade to avro-patches 0.3.4

## v0.13.2
- Missing database no longer causes `docker_start` script to fail in auto-migrate mode.

## v0.13.1
- Missing database no longer causes `docker_start` script to fail in auto-migrate mode.

## v0.13.0
- Add auto-migrate and waiting for Postgres to the Docker container.

## v0.12.1
- Upgrade to Puma 3.11.3.

## v0.12.0
- Upgrade to Ruby 2.4.2.
- Upgrade to Rails 5.1.
- Allow default compatibility level to be set via environment variable and
  change the default for non-production environments.
- Include Dockerfile.

## v0.11.0
- Change the default fingerprint version to '2'. Set `FINGERPRINT_VERSION=1`
  before upgrading if you have not migrated to fingerprint version 2.

## v0.10.0
- Use `avro-patches` instead of `avro-salsify-fork`.

## v0.9.1
- Support dual deploys.

## v0.9.0
- Add read-only mode for the application.

## v0.8.1
- Reverse the definition of BACKWARD and FORWARD compatibility levels.
  Previous releases had these backwards.
  Note: The compatibility level is NOT changed for existing configs in the
  database. Current compatibility levels should be reviewed to ensure that the
  expectation is consistent with the description here:
  http://docs.confluent.io/3.2.0/avro.html#schema-evolution.

## v0.8.0
- Allow the compatibility level to use while registering a schema to be specified,
  and a compatibility level to set for the subject after registration.

## v0.7.0
- Allow the compatibility level to be specified in the Compatibility API.

## v0.6.2
- Update `cache_all_requests` task to use the resolution fingerprint.

## v0.6.1
- Only define rake task to cache requests in the development environment.

## v0.6.0
- Introduce fingerprint2 based on `avro-resolution_canonical_form`.
  This is a compatibility breaking change and requires a sequence of upgrade steps.
- Fix fingerprint endpoint when using an integer fingerprint.

## v0.5.0
- Fix Config API for subjects.
- Add endpoint to get schema id by fingerprint.
- Upgrade to Rails 5.0.
- Add rake task to issue cacheable requests for all schemas.

## v0.4.0
- Use `avro-salsify-fork` v1.9.0.3.
- Implement full schema compatibility check and transitive options from
  Confluent Schema Registry API v3.1.0.

## v0.3.0
- Use `heroku_rails_deploy` gem.

## v0.2.0
- Update to Rails 4.2.7.
- Use `avro-salsify-fork`.
- Add `bin/deploy` script.

## v0.1.0
- Initial release
