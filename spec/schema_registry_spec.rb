describe SchemaRegistry do
  let(:old_json) { build(:schema).json }
  let(:new_json) { build(:schema).json }
  let(:old_schema) { Avro::Schema.parse(old_json) }
  let(:new_schema) { Avro::Schema.parse(new_json) }

  describe ".compatible?" do
    subject { described_class.compatible?(compatibility, old_json, new_json) }

    before do
      allow(Avro::IO::DatumReader).to receive(:match_schemas).and_call_original
    end

    context "when compatibility is nil" do
      let(:compatibility) { nil }

      it "uses the global Compatibility level" do
        allow(Compatibility).to receive(:global).and_call_original
        subject
        expect(Compatibility).to have_received(:global)
      end
    end

    context "when compatibility is NONE" do
      let(:compatibility) { 'NONE' }

      it "does not perform any check" do
        expect(subject).to eq(true)
        expect(Avro::IO::DatumReader).not_to have_received(:match_schemas)
      end
    end

    context "when compatibility is BACKWARD" do
      let(:compatibility) { 'BACKWARD' }

      it "performs a check with the old schema as the readers schema" do
        subject
        expect(Avro::IO::DatumReader).to have_received(:match_schemas).with(new_schema, old_schema)
      end
    end

    context "when compatibility is FORWARD" do
      let(:compatibility) { 'FORWARD' }

      it "performs a check with the new schema as the readers schema" do
        subject
        expect(Avro::IO::DatumReader).to have_received(:match_schemas).with(old_schema, new_schema)
      end
    end

    context "when compatibility is BOTH" do
      let(:compatibility) { 'BOTH' }

      it "performs a check with each schema as the readers schema" do
        subject
        expect(Avro::IO::DatumReader).to have_received(:match_schemas).with(new_schema, old_schema)
        expect(Avro::IO::DatumReader).to have_received(:match_schemas).with(old_schema, new_schema)
      end
    end
  end

  describe ".compatible!" do
    let(:compatibility) { Compatibility.global }

    subject { described_class.compatible!(compatibility, old_schema, new_schema) }

    before do
      allow(described_class).to receive(:compatible?)
        .with(compatibility, old_schema, new_schema).and_return(compatible)
    end

    context "when schemas are compatible" do
      let(:compatible) { true }

      it "does not raise an error" do
        expect { subject }.not_to raise_error
      end
    end

    context "when schemas are incompatible" do
      let(:compatible) { false }

      it "raises IncompatibleAvroSchemaError" do
        expect { subject }.to raise_error(SchemaRegistry::IncompatibleAvroSchemaError)
      end
    end
  end
end
