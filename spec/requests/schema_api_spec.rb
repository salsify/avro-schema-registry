# frozen_string_literal: true

require 'rails_helper'

describe SchemaAPI do
  describe "GET /schemas/ids/:id" do
    let(:schema) { create(:schema) }

    it_behaves_like "a secure endpoint" do
      let(:action) { unauthorized_get("/schemas/ids/#{schema.id}") }
    end

    context "content type" do
      include_examples "content type", :get do
        let(:path) { "/schemas/ids/#{schema.id}" }
        let(:expected) do
          { schema: schema.json }.to_json
        end
      end
    end

    context "when the schema is found" do
      let(:expected) do
        { schema: schema.json }.to_json
      end

      it "returns the schema" do
        get("/schemas/ids/#{schema.id}")
        expect(response).to be_ok
        expect(response.body).to be_json_eql(expected)
      end

      it_behaves_like "a cached endpoint" do
        let(:action) { get("/schemas/ids/#{schema.id}") }
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
      let(:action) { get("/schemas/ids/#{schema_id}") }

      it "returns a not found response" do
        action
        expect(response).to be_not_found
        expect(response.body).to be_json_eql(expected)
      end

      it_behaves_like "an error that cannot be cached"
    end
  end
end
