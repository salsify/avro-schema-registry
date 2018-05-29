describe SchemaRegistry do
  let(:json_hash) do
    {
      type: :record,
      name: :rec,
      fields: [
        { name: :field1, type: :string, default: '' },
        { name: :field2, type: :string }
      ]
    }
  end
  let(:old_json) { json_hash.to_json }
  let(:schema) { create(:schema, json: old_json) }
  let(:version) { create(:schema_version, schema: schema) }
  let(:new_json) { build(:schema).json }
  let(:backward_json) do
    # BACKWARD compatible - can read old schema
    # It ignores the removed field in the old schema
    hash = JSON.parse(old_json)
    hash['fields'].pop
    hash.to_json
  end
  let(:forward_json) do
    # FORWARD compatible - can be read by old schema
    # The old schema ignores the new field.
    hash = JSON.parse(old_json)
    hash['fields'] << { name: :extra, type: :string }
    hash.to_json
  end
  let(:full_json) do
    # FULL compatible
    hash = JSON.parse(old_json)
    # removed required field with default
    hash['fields'].shift
    # add required field with default
    hash['fields'] << { name: :extra, type: :string, default: '' }
    hash.to_json
  end
  let(:old_schema) { Avro::Schema.parse(old_json) }
  let(:new_schema) { Avro::Schema.parse(new_json) }

  before do
    create(:config, subject_id: version.subject_id, compatibility: compatibility) if compatibility
  end

  describe ".compatible?" do
    let(:compatibility) { 'FULL_TRANSITIVE' }

    subject(:check) { described_class.compatible?(new_json, version: version) }

    before do
      allow(Avro::SchemaCompatibility).to receive(:can_read?).and_call_original
    end

    it "allows compatibility to be specified" do
      described_class.compatible?(new_json, version: version, compatibility: 'BACKWARD')
      expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(new_schema, old_schema)
    end

    context "when compatibility is nil" do
      let(:compatibility) { nil }

      it "uses the global Compatibility level" do
        allow(Compatibility).to receive(:global).and_call_original
        check
        expect(Compatibility).to have_received(:global)
      end
    end

    context "when compatibility is NONE" do
      let(:compatibility) { 'NONE' }

      it "does not perform any check" do
        expect(check).to eq(true)
        expect(Avro::SchemaCompatibility).not_to have_received(:can_read?)
      end
    end

    context "when compatibility is BACKWARD" do
      let(:compatibility) { 'BACKWARD' }

      it "performs a check with the old schema as the readers schema" do
        check
        expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(new_schema, old_schema)
      end

      it "returns false for a forward compatible schema" do
        expect(described_class.compatible?(forward_json, version: version)).to eq(false)
      end

      it "returns true for a backward compatible schema" do
        expect(described_class.compatible?(backward_json, version: version)).to eq(true)
      end
    end

    context "when compatibility is FORWARD" do
      let(:compatibility) { 'FORWARD' }

      it "performs a check with the new schema as the readers schema" do
        check
        expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(old_schema, new_schema)
      end

      it "returns true for a forward compatible schema" do
        expect(described_class.compatible?(forward_json, version: version)).to eq(true)
      end

      it "returns false for a backward compatible schema" do
        expect(described_class.compatible?(backward_json, version: version)).to eq(false)
      end
    end

    context "when compatibility is BOTH (deprecated)" do
      let(:compatibility) { 'BOTH' }

      it "performs a check with each schema as the readers schema" do
        check
        expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(new_schema, old_schema).once
        expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(old_schema, new_schema).once
      end

      it "returns false" do
        expect(check).to eq(false)
      end
    end

    context "when compatibility is FULL" do
      let(:compatibility) { 'FULL' }

      it "performs a check with each schema as the readers schema" do
        check
        expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(new_schema, old_schema)
        expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(old_schema, new_schema)
      end

      it "returns false for a forward compatible schema" do
        expect(described_class.compatible?(forward_json, version: version)).to eq(false)
      end

      it "returns false for a backward compatible schema" do
        expect(described_class.compatible?(backward_json, version: version)).to eq(false)
      end

      it "returns true for a fully compatible schema" do
        expect(described_class.compatible?(full_json, version: version)).to eq(true)
      end
    end

    context "transitive checks" do
      let(:registry_subject) { version.subject }
      let!(:second_version) { create(:schema_version, subject: registry_subject, version: 2) }
      let(:second_schema) { Avro::Schema.parse(second_version.schema.json) }
      let(:can_read_args) { [] }

      before do
        # rspec checks for ordered calls with have_received were not working so
        # expectations are checked directly based on captured args
        allow(Avro::SchemaCompatibility).to receive(:can_read?) do |*args|
          can_read_args << args
          true
        end
      end

      context "when compatibility is BACKWARD_TRANSITIVE" do
        let(:compatibility) { 'BACKWARD_TRANSITIVE' }

        it "performs a check with all schemas as the readers schema" do
          check
          expect(can_read_args.first).to eq([new_schema, second_schema])
          expect(can_read_args.second).to eq([new_schema, old_schema])
        end
      end

      context "when compatibility is FORWARD_TRANSITIVE" do
        let(:compatibility) { 'FORWARD_TRANSITIVE' }

        it "performs a check with all schemas as the writers schema" do
          check
          expect(can_read_args.first).to eq([second_schema, new_schema])
          expect(can_read_args.second).to eq([old_schema, new_schema])
        end
      end

      context "when compatibility is FULL_TRANSITIVE" do
        let(:compatibility) { 'FULL_TRANSITIVE' }

        it "performs a check with all schemas as the writers schema" do
          check
          expect(can_read_args.first).to eq([new_schema, second_schema])
          expect(can_read_args.second).to eq([second_schema, new_schema])
          expect(can_read_args.third).to eq([new_schema, old_schema])
          expect(can_read_args.fourth).to eq([old_schema, new_schema])
        end
      end
    end

    context "server error" do
      let(:compatibility) { 'BOTH' }

      let(:old_json) do
        {
            type: 'record',
            name: 'event',
            fields: [
              {
                  name: 'attribute',
                  type: {
                      type: 'record',
                      name: 'reference',
                      fields: [
                        {
                              name: 'id',
                              type: 'string'
                          }
                      ]
                  }
              }
            ]
        }.to_json
      end

      let(:new_json) do
        {
            type: 'record',
            name: 'event',
            fields: [
              {
                  name: 'attribute',
                  type: [
                    'null',
                    {
                        type: 'record',
                        name: 'reference',
                        fields: [
                          {
                                name: 'id',
                                type: 'string'
                            }
                        ]
                    }
                  ],
                  default: nil
              }
            ]
        }.to_json
      end

      it "returns false" do
        expect(check).to eq(false)
      end

    end
  end

  describe ".compatible!" do
    subject(:check) { described_class.compatible!(new_json, version: version) }

    before do
      allow(described_class).to receive(:compatible?)
        .with(new_json, version: version, compatibility: compatibility).and_return(compatible)
    end

    context "when the compatibility level is specified" do
      let(:compatibility) { 'FORWARD' }
      let(:compatible) { true }

      it "checks compatibility using the specified level" do
        expect do
          described_class.compatible!(new_json, version: version, compatibility: compatibility)
        end.not_to raise_error
      end
    end

    context "when schemas are compatible" do
      let(:compatibility) { nil }
      let(:compatible) { true }

      it "does not raise an error" do
        expect { check }.not_to raise_error
      end
    end

    context "when schemas are incompatible" do
      let(:compatibility) { nil }
      let(:compatible) { false }

      it "raises IncompatibleAvroSchemaError" do
        expect { check }.to raise_error(SchemaRegistry::IncompatibleAvroSchemaError)
      end
    end
  end
end
