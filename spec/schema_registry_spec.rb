describe SchemaRegistry do
  let(:registry_subject) { version.subject }
  let(:version) { create(:schema_version) }
  let(:new_json) { build(:schema).json }
  let(:old_schema) { Avro::Schema.parse(version.schema.json) }
  let(:new_schema) { Avro::Schema.parse(new_json) }

  before do
    create(:config, subject_id: version.subject_id, compatibility: compatibility) if compatibility
  end

  describe ".compatible?" do
    subject(:check) { described_class.compatible?(new_json, version: version) }

    before do
      allow(Avro::SchemaCompatibility).to receive(:can_read?).and_call_original
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
    end

    context "when compatibility is FORWARD" do
      let(:compatibility) { 'FORWARD' }

      it "performs a check with the new schema as the readers schema" do
        check
        expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(old_schema, new_schema)
      end
    end

    context "when compatibility is BOTH (deprecated)" do
      let(:compatibility) { 'BOTH' }

      it "performs a check with each schema as the readers schema" do
        check
        expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(new_schema, old_schema)
        expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(old_schema, new_schema)
      end
    end

    context "when compatibility is FULL" do
      let(:compatibility) { 'FULL' }

      it "performs a check with each schema as the readers schema" do
        check
        expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(new_schema, old_schema)
        expect(Avro::SchemaCompatibility).to have_received(:can_read?).with(old_schema, new_schema)
      end
    end

    context "transitive checks" do
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
  end

  describe ".compatible!" do
    let(:compatibility) { Compatibility.global }

    subject(:check) { described_class.compatible!(new_json, version: version) }

    before do
      allow(described_class).to receive(:compatible?)
        .with(new_json, version: version).and_return(compatible)
    end

    context "when schemas are compatible" do
      let(:compatible) { true }

      it "does not raise an error" do
        expect { check }.not_to raise_error
      end
    end

    context "when schemas are incompatible" do
      let(:compatible) { false }

      it "raises IncompatibleAvroSchemaError" do
        expect { check }.to raise_error(SchemaRegistry::IncompatibleAvroSchemaError)
      end
    end
  end
end
