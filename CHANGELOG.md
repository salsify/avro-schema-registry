# avro-schema-registry

## v0.6.0 (unreleased)
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
