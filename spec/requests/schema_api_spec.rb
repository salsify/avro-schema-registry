require 'rails_helper'

describe SchemaAPI do
  describe "GET /schemas/ids/:id" do
    context "when the schema is found" do
      let(:schema) { create(:schema) }
      let(:expected) do
        { schema: schema.json }.to_json
      end

      it "returns the schema" do
        get("/schemas/ids/#{schema.id}")
        expect(response).to be_ok
        expect(response.body).to be_json_eql(expected)
      end
    end

    context "when the schema is not found" do
      let(:schema_id) { -1 }
      let(:expected) do
        {
          error_code: 40403,
          message: 'Schema not found'
        }.to_json
      end

      it "returns a not found response" do
        get("/schemas/ids/#{schema_id}")
        expect(response).to be_not_found
        expect(response.body).to be_json_eql(expected)
      end
    end
  end
end
