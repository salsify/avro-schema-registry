module Helpers

  module SchemaVersionHelper
    include Helpers::ErrorHelper

    LATEST_VERSION = 'latest'.freeze

    private

    def with_schema_version(subject_name, version)
      schema_version = find_schema_version(subject_name, version)

      if schema_version
        yield schema_version
      elsif Subject.where(name: subject_name).exists?
        version_not_found!
      else
        subject_not_found!
      end
    end

    def find_schema_version(subject_name, version)
      if version == LATEST_VERSION
        SchemaVersion.for_subject_name(subject_name)
          .latest
      else
        SchemaVersion.where(version: version)
          .for_subject_name(subject_name)
      end.first
    end

  end
end
