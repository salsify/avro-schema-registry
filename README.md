# avro-schema-registry

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

[![Build Status](https://travis-ci.org/salsify/avro-schema-registry.svg?branch=master)][travis]

[travis]: https://travis-ci.org/salsify/avro-schema-registry

A service for storing and retrieving versions of Avro schemas.

Schema versions stored by the service are assigned an id. These ids can be
embedded in messages published to Kafka avoiding the need to send the full
schema with each message.

## Overview

This application provides the same API as the Confluent
[Schema Registry](http://docs.confluent.io/3.0.0/schema-registry/docs/api.html).

The service is implemented as a Rails 4.2 application and stores Avro schemas in
Postgres. The API is implemented using [Grape](https://github.com/ruby-grape/grape).

### Why?

The Confluent Schema Registry has been reimplemented because the original
implementation uses Kafka to store schemas. We view the messages that pass
through Kafka as more ephemeral and want the flexibility to change how we host Kafka.
In the future we may also apply per-subject permissions to the Avro schemas that
are stored by the registry.

## Setup

The application is written using Ruby 2.3.1. Start the service using the following
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

## Security

The service is secured using HTTP Basic authentication and should be used with
SSL. The default password for the service is 'avro' but it can be set via
the environment as `SCHEMA_REGISTRY_PASSWORD`.

Authentication can be disabled by setting `DISABLE_PASSWORD` to 'true' in the
environment.

## Usage

For more details on the REST API see the Confluent
[documentation](http://docs.confluent.io/3.0.0/schema-registry/docs/api.html).

A [client](https://github.com/dasch/avro_turf/blob/master/lib/avro_turf/schema_registry.rb)
(see [AvroTurf](https://github.com/dasch/avro_turf)) can be used to
communicate with the service:

```ruby
url = 'https://anything:avro@registry.example.com'
client = AvroTurf::SchemaRegistry.new(url)

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

### Compatibility

Support for compatibility checking is incomplete. The full Confluent Schema
Registry API is supported but compatibility checks are based on
[Avro::IO::DatumReader.match_schemas](https://github.com/apache/avro/blob/branch-1.8/lang/ruby/lib/avro/io.rb#L222)
from the [avro gem](https://github.com/apache/avro/tree/branch-1.8/lang/ruby).

This is a basic check that ensures the top-level Avro type and name match.

In the future, a complete implementation of compatibility checking may be added.

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

