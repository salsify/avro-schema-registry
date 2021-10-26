# frozen_string_literal: true

describe Schemas::Parse do
  describe ".call" do
    let(:json) { build(:schema).json }

    let(:schema) { described_class.call(json) }

    it "returns an Avro::Schema" do
      expect(schema).to be_a(Avro::Schema)
    end

    context "with an invalid schema" do
      let(:json) { {}.to_json }

      it "raises an InvalidAvroSchemaError" do
        expect { schema }.to raise_error(SchemaRegistry::InvalidAvroSchemaError)
      end
    end
  end
end
