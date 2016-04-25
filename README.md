# avro-schema-registry

A service for storing and retrieving versions of Avro schemas.

Schema versions stored by the service are assigned an id. These ids can be
embedded in messages published to Kafka avoiding the need to send the full
schema with each message.

## Overview

This application provides the same API as the Confluent
[Schema Registry](http://docs.confluent.io/2.0.1/schema-registry/docs/api.html).

The service is implemented as a Rails 4.2 application and stores Avro schemas in
Postgres.

### Why?

The Confluent Schema Registry has been reimplemented because the original
implementation uses Kafka to store schemas. We view the message that passes
through Kafka as more ephemeral and want the flexibility to change Kafka hosting
providers. In the future we may also apply per-subject permissions to the Avro
schemas that are stored by the registry.

## Setup

The application is written using Ruby 2.3. Start the service using the following
steps:

```bash
git clone git@github.com:salsify/avro-schema-registry.git
cd avro-schema-registry
bundle install
bin/rake db:setup
bin/rails s
```

By default the service runs on port 21000.

## Security

The service is secured using HTTP Basic authentication and should be with SSL.
The default password for the service is 'avro'.

## Usage

For more details on the REST API see the Confluent
[documentation](http://docs.confluent.io/2.0.1/schema-registry/docs/api.html).

A [client](https://github.com/salsify/salsify_avro#schema-registry-clients)
(see [SalsifyAvro](https://github.com/salsify/salsify_avro)) can be used to
communicate with the service:

```ruby
url = 'https://anything:avro@registry.example.com'
client = SalsifyAvro::SchemaRegistryClient.new(url)

# registering a new schema returns an id
id = client.register('test_subject', avro_json_schema)
# => 99

# attempting to register the same schema for a subject returns the existing id
id = client.register('test_subject', avro_json_schema)
# => 99

# the JSON for an Avro schema cna be fetched by id
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

```bash
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/salsify/avro-schema-registry.

