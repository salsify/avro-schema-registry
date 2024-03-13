# frozen_string_literal: true

describe Schema do
  before do
    allow(Rails.configuration.x).to receive(:fingerprint_version).and_return(fingerprint_version)
  end

  describe '#save' do
    let(:schema) { build(:schema) }

    before do
      schema.save!
    end

    context "when fingerprint_version is '1'" do
      let(:fingerprint_version) { '1' }

      it "sets fingerprint" do
        expect(schema.fingerprint).to be_present
      end

      it "does not set fingerprint2" do
        expect(schema.fingerprint2).to be_nil
      end
    end

    shared_examples_for "it sets both fingerprints" do
      it "sets fingerprint" do
        expect(schema.fingerprint).to be_present
      end

      it "sets fingerprint2" do
        expect(schema.fingerprint2).to be_present
      end
    end

    context "when fingerprint_version is '2'" do
      let(:fingerprint_version) { '2' }

      it_behaves_like "it sets both fingerprints"
    end

    context "when fingerprint_version is 'all'" do
      let(:fingerprint_version) { 'all' }

      it_behaves_like "it sets both fingerprints"
    end
  end

  describe ".existing_schema" do
    let(:schema1) { create(:schema) }
    let(:schema2) { create(:schema) }
    let(:json) { build(:schema).json }
    let(:fingerprint_v1) { Schemas::FingerprintGenerator.generate_v1(json) }
    let(:fingerprint_v2) { Schemas::FingerprintGenerator.generate_v2(json) }

    # `Schema` is an immutable model, so we need raw SQL
    def update_schema_fingerprints(schema:, fingerprint:, fingerprint2:)
      params = [
        'UPDATE schemas SET fingerprint = ?, fingerprint2 = ? WHERE id = ?',
        fingerprint,
        fingerprint2,
        schema.id
      ]
      params = ActiveRecord::Base.sanitize_sql(params)
      ActiveRecord::Base.connection.execute(params)
    end

    before do
      update_schema_fingerprints(
        schema: schema1,
        fingerprint: fingerprint_v1,
        fingerprint2: Schemas::FingerprintGenerator.generate_v2(schema1.json)
      )

      update_schema_fingerprints(
        schema: schema2,
        fingerprint: Schemas::FingerprintGenerator.generate_v1(schema2.json),
        fingerprint2: fingerprint_v2
      )
    end

    context "when fingerprint_version is '1'" do
      let(:fingerprint_version) { '1' }

      it "finds the existing schema by fingerprint v1" do
        expect(Schema.existing_schema(json)).to eq(schema1)
      end

      context "when there is no schema matching fingerprint v1" do
        before do
          ActiveRecord::Base.connection.execute("DELETE FROM schemas where id = #{schema1.id}")
        end

        it "returns nil" do
          expect(Schema.existing_schema(json)).to be_nil
        end
      end
    end

    context "when fingerprint_version is '2'" do
      let(:fingerprint_version) { '2' }

      it "finds the existing schema by fingerprint v2" do
        expect(Schema.existing_schema(json)).to eq(schema2)
      end

      context "when there is no schema matching fingerprint v2" do
        before do
          ActiveRecord::Base.connection.execute("DELETE FROM schemas where id = #{schema2.id}")
        end

        it "returns nil" do
          expect(Schema.existing_schema(json)).to be_nil
        end
      end
    end

    context "when fingerprint_version is 'all'" do
      let(:fingerprint_version) { 'all' }

      it "finds the existing schema by fingerprint v2" do
        expect(Schema.existing_schema(json)).to eq(schema2)
      end

      context "when there is no schema matching fingerprint v2" do
        before do
          ActiveRecord::Base.connection.execute("DELETE FROM schemas where id = #{schema2.id}")
        end

        it "finds the existing schema by fingerprint v1" do
          expect(Schema.existing_schema(json)).to eq(schema1)
        end
      end
    end
  end
end
