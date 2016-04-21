describe Schemas::Parse do
  describe ".call" do
    let(:json) { build(:schema).json }
    subject { described_class.call(json) }

    it { is_expected.to be_a(Avro::Schema) }

    context "with an invalid schema" do
      let(:json) { {}.to_json }

      it "raises an InvalidAvroSchemaError" do
        expect { subject }.to raise_error(SchemaRegistry::InvalidAvroSchemaError)
      end
    end
  end
end
