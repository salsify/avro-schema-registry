# avro-schema-registry

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

[![Build Status](https://circleci.com/gh/salsify/avro-schema-registry.svg?style=svg)][circleci]

[circleci]: https://circleci.com/gh/salsify/avro-schema-registry

A service for storing and retrieving versions of Avro schemas.

Schema versions stored by the service are assigned an id. These ids can be
embedded in messages published to Kafka avoiding the need to send the full
schema with each message.

## Upgrading to v0.11.0

v0.11.0 changes the default fingerprint version to 2. Set `FINGERPRINT_VERSION=1`
before upgrading if you have not migrated to fingerprint version 2.

## Upgrading to v0.6.0

There is a compatibility break when upgrading to v0.6.0 due to the way that
fingerprints are generated. Prior to v0.6.0 fingerprints were generated based
on the Parsing Canonical Form for Avro schemas. This does not take into account
attributes such as `default` that are used during schema resolution and for
compatibility checking. The new fingerprint is based on [avro-resolution_canonical_form](https://github.com/salsify/avro-resolution_canonical_form).

To upgrade:

1. Set `FINGERPRINT_VERSION=1` and `DISABLE_SCHEMA_REGISTRATION=true` in the
  environment for the application, and restart the application.
2. Deploy v0.6.0 and run migrations to create and populate the new `fingerprint2`
  column.
3. If NOT using the fingerprint endpoint, move to the final step.
4. Set `FINGERPRINT_VERSION=all`, unset `DISABLE_SCHEMA_REGISTRATION`, and restart the application.
5. Update all clients to use the v2 fingerprint.
6. Set `FINGERPRINT_VERSION=2` and unset `DISABLE_SCHEMA_REGISTRATION` (if still set) and
  restart the application.

At some point in the future the original `fingerprint` column will be removed.

## Overview

This application provides the same API as the Confluent
[Schema Registry](http://docs.confluent.io/3.1.0/schema-registry/docs/api.html).

The service is implemented as a Rails 7.1 application and stores Avro schemas in
Postgres. The API is implemented using [Grape](https://github.com/ruby-grape/grape).

### Why?

The Confluent Schema Registry has been reimplemented because the original
implementation uses Kafka to store schemas. We view the messages that pass
through Kafka as more ephemeral and want the flexibility to change how we host Kafka.
In the future we may also apply per-subject permissions to the Avro schemas that
are stored by the registry.

## Extensions

In addition to the Confluent Schema Registry API, this application provides some
extensions.

### Schema ID by Fingerprint

There is an endpoint that can be used to determine by
fingerprint if a schema is already registered for a subject.

This endpoint provides a success response that can be cached indefinitely since
the id for a schema will not change once it is registered for a subject.

`GET /subjects/(string: subject)/fingerprints/(:fingerprint)`

Get the id of the schema registered for the subject by fingerprint. The
fingerprint may either be the hex string or the integer value produced by the
[SHA256 fingerprint](http://avro.apache.org/docs/1.8.1/spec.html#Schema+Fingerprints).

**Parameters:**
- **subject** (_string_) - Name of the subject that the schema is registered under
- **fingerprint** (_string_ or _integer_) - SHA256 fingerprint for the schema

**Response JSON Object:**
- **id** (_int_) - Globally unique identifier of the schema

**Status Codes:**
- 404 Not Found - Error Code 40403 - Schema not found
- 500 Internal Server Error - Error code 50001 - Error in the backend datastore

**Example Request:**
```
GET /subjects/test/fingerprints/90479eea876f5d6c8482b5b9e3e865ff1c0931c1bfe0adb44c41d628fd20989c HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json
```

**Example response:**
```
HTTP/1.1 200 OK
Content-Type: application/vnd.schemaregistry.v1+json

{"id":1}
```

### Test Compatibility with a Specified Level

The Compatibility API is extended to support a `with_compatibility` parameter
that controls the level used for the compatibility check against the specified
schema version.

When `with_compatibility` is specified, it overrides any configuration for the
subject and the global configuration.

**Example Request:**
```
POST /subjects/test/versions/latest HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json

{
  "schema": "{ ... }",
  "with_compatibility": "BACKWARD"
}
```

### Register A New Schema With Specified Compatibility Levels

The Subject API is extended to support a `with_compatibility` parameter that
controls the level used for the compatibility check when registering a new
schema for a subject.

An `after_compatibility` parameter is also supported to set a new compatibility
level for the subject after a new schema version is registered. This option is
ignored if no new version is created.

**Example Request:**
```
POST /subjects/test/versions HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json

{
  "schema": "{ ... }",
  "with_compatibility": "NONE",
  "after_compatibility": "BACKwARD"
}
```

## Setup

The application is written using Ruby 3.3.6. Start the service using the following
steps:

```bash
git clone git@github.com:salsify/avro-schema-registry.git
cd avro-schema-registry
bundle install
bin/rake db:setup
bin/rails s
```

By default the service runs on port 21000.

## Deployment

Salsify hosts a public instance of this application at
[avro-schema-registry.salsify.com](https://avro-schema-registry.salsify.com) that
anyone can experiment with, just please don't rely on it for production!

There is also a button above to easily deploy your own copy of the application to Heroku.

### Docker

A Dockerfile is provided to run the application within a container. To
build the image, navigate to the root of the repo and run `docker build`:

```bash
docker build . -t avro-schema-registry
```

The container is built for the `production` environment, so you'll
need to pass in a few environment flags to run it:

```bash
docker run -p 5000:5000 -d \
  -e DATABASE_URL=postgresql://user:pass@host/dbname \
  -e FORCE_SSL=false \
  -e SECRET_KEY_BASE=supersecret \
  -e SCHEMA_REGISTRY_PASSWORD=avro \
  avro-schema-registry
```

If you also want to run PostgreSQL in a container, you can link the two containers:

```bash
docker run --name avro-postgres -d \
  -e POSTGRES_PASSWORD=avro \
  -e POSTGRES_USER=avro \
  postgres:9.6

docker run --name avro-schema-registry --link avro-postgres:postgres -p 5000:5000 -d \
  -e DATABASE_URL=postgresql://avro:avro@postgres/avro \
  -e FORCE_SSL=false \
  -e SECRET_KEY_BASE=supersecret \
  -e SCHEMA_REGISTRY_PASSWORD=avro \
  avro-schema-registry
```

To setup the database the first time you run the app, you can call
`rails db:setup` from within the container:

```bash
docker exec avro-schema-registry bundle exec rails db:setup
```

Alternatively, your can pass `-e AUTO_MIGRATE=1` to your `docker run` command to have the 
container automatically create and migrate the database schema.

## Security

The service is secured using HTTP Basic authentication and should be used with
SSL. The default password for the service is 'avro' but it can be set via
the environment as `SCHEMA_REGISTRY_PASSWORD`.

Authentication can be disabled by setting `DISABLE_PASSWORD` to 'true' in the
environment.

## Caching

When the environment variable `ALLOW_RESPONSE_CACHING` is set to `true` then the
service sets headers to allow responses from the following endpoints to be cached:

- `GET /schemas/(int: id)`
- `GET /subjects/(string: subject)/fingerprints/(:fingerprint)`

By default, responses for these endpoints are allowed to be cached for 30 days.
This max age can be configured by setting `CACHE_MAX_AGE` to a number of seconds.

To populate a cache of the responses from these endpoints, the application
contains a rake task that can be run in a development environment to iterate
through all registered schemas and issue the cacheable requests:

```bash
rake cache_all_requests registry_url=https://anything:avro@registry.example.com
```

## Usage

For more details on the REST API see the Confluent
[documentation](http://docs.confluent.io/3.1.0/schema-registry/docs/api.html).

A [client](https://github.com/dasch/avro_turf/blob/master/lib/avro_turf/confluent_schema_registry.rb)
(see [AvroTurf](https://github.com/dasch/avro_turf)) can be used to
communicate with the service:

```ruby
require 'avro_turf'
require 'avro_turf/confluent_schema_registry'

url = 'https://anything:avro@registry.example.com'
client = AvroTurf::ConfluentSchemaRegistry.new(url)

# registering a new schema returns an id
id = client.register('test_subject', avro_json_schema)
# => 99

# attempting to register the same schema for a subject returns the existing id
id = client.register('test_subject', avro_json_schema)
# => 99

# the JSON for an Avro schema can be fetched by id
client.fetch(id)
# => avro_json_schema
```

## Tests

Tests for the application can be run using:

```
bundle exec rspec
```

## License

This code is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/salsify/avro-schema-registry.
