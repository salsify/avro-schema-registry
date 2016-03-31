describe SubjectAPI do
  let(:invalid_json) do
    # invalid due to missing record name
    { type: :record, fields: [{ name: :i, type: :int }] }.to_json
  end

  context "content type" do
    # content type is configured at the API level so only one endpoint is
    # tested here.
    include_examples "content type", :get do
      let(:path) { '/subjects' }
      let(:expected) { [].to_json }
    end
  end

  describe "GET /subjects" do
    let!(:subjects) { create_list(:subject, 3) }
    let(:expected) do
      subjects.map(&:name).sort.to_json
    end

    it "returns a list of subject names" do
      get('/subjects')
      expect(response).to be_ok
      expect(response.body).to be_json_eql(expected)
    end

    it "is secured by Basic auth" do
      unauthorized_get('/subjects')
      expect(status).to eq(401)
    end
  end

  describe "GET /subjects/:name/versions" do

    context "supported subject names" do
      # This is only being tested for one representative route under
      # /subjects/:name
      shared_examples_for "a supported subject name" do |desc, name|
        let(:subject) { create(:subject, name: name) }
        let!(:schema_version) { create(:version, subject: subject) }

        it "supports #{desc}" do
          get("/subjects/#{subject.name}/versions")
          expect(response).to be_ok
          expect(response.body).to eq([schema_version.version].to_json)
        end
      end

      shared_examples_for "an unsupported subject name" do |desc, name|
        it "does not support #{desc}" do
          expect do
            get("/subjects/#{name}/versions")
          end.to raise_error(ActionController::RoutingError)
        end
      end

      it_behaves_like 'a supported subject name',
                      'a name containing a period',
                      'com.example.foo'

      it_behaves_like 'a supported subject name',
                      'a name beginning with an underscore',
                      '_underscore'

      it_behaves_like 'a supported subject name',
                      'a name containing a digit',
                      'number5'

      it_behaves_like 'a supported subject name',
                      'a name containing mixed case',
                      'UPPER_lower_0123456789'

      it_behaves_like 'an unsupported subject name',
                      'a name beginning with a digit',
                      '5alive'

      it_behaves_like 'an unsupported subject name',
                      'a name containing a hyphen',
                      'foo-bar'

      it_behaves_like 'an unsupported subject name',
                      'a name beginning with a period',
                      '.com'
    end

    context "when the subject exists" do
      let(:subject) { create(:subject) }
      let!(:schema_versions) { Array.new(1) { create(:version, subject: subject) } }
      let(:expected) do
        schema_versions.map(&:version).sort.to_json
      end

      it "returns a list of the versions" do
        get("/subjects/#{subject.name}/versions")
        expect(response).to be_ok
        expect(response.body).to eq(expected)
      end
    end

    it "is secured by Basic auth" do
      unauthorized_get('/subjects/name')
      expect(status).to eq(401)
    end

    context "when the subject does not exist" do
      let(:name) { 'fnord' }

      it "returns a not found error" do
        get("/subjects/#{name}/versions")
        expect(response).to be_not_found
        expect(response.body).to be_json_eql(SchemaRegistry::Errors::SUBJECT_NOT_FOUND.to_json)
      end
    end
  end

  describe "GET /subjects/:name/versions/:version_id" do
    it "is secured by Basic auth" do
      unauthorized_get('/subjects/name/versions/1')
      expect(status).to eq(401)
    end

    context "when the subject and version exists" do
      let!(:other_schema_version) { create(:schema_version) }
      let(:version) { create(:schema_version) }
      let(:subject_name) { version.subject.name }
      let(:schema) { version.schema }
      let(:expected) do
        {
          name: subject_name,
          version: version.version,
          schema: schema.json
        }.to_json
      end

      it "returns the schema" do
        get("/subjects/#{subject_name}/versions/#{version.version}")
        expect(response).to be_ok
        expect(response.body).to be_json_eql(expected)
      end

      context "when the version is specified as 'latest'" do
        it "returns the schema" do
          get("/subjects/#{subject_name}/versions/latest")
          expect(response).to be_ok
          expect(response.body).to be_json_eql(expected)
        end
      end

      context "when the version is an invalid string" do
        it "returns a not found error" do
          get("/subjects/#{subject_name}/versions/invalid")
          expect(response).to be_not_found
          expect(response.body).to be_json_eql(SchemaRegistry::Errors::VERSION_NOT_FOUND.to_json)
        end
      end
    end

    context "when the subject does not exist" do
      it "returns a not found error" do
        get('/subjects/fnord/versions/latest')
        expect(response).to be_not_found
        expect(response.body).to be_json_eql(SchemaRegistry::Errors::SUBJECT_NOT_FOUND.to_json)
      end
    end

    context "when the version does not exist" do
      let!(:version) { create(:schema_version) }

      it "returns a not found error" do
        get("/subjects/#{version.subject.name}/versions/2")
        expect(response).to be_not_found
        expect(response.body).to be_json_eql(SchemaRegistry::Errors::VERSION_NOT_FOUND.to_json)
      end
    end
  end

  describe "POST /subjects/:name/versions" do
    it "is secured by Basic auth" do
      unauthorized_post('/subjects/name/versions')
      expect(status).to eq(401)
    end

    context "with an invalid avro schema" do
      let(:subject_name) { 'invalid' }

      it "returns an unprocessable entity error" do
        post("/subjects/#{subject_name}/versions", schema: invalid_json)
        expect(response.status).to eq(422)
        expect(response.body).to be_json_eql(SchemaRegistry::Errors::INVALID_AVRO_SCHEMA.to_json)
      end
    end

    context "when the schema is already registered under the subject" do
      let!(:version) { create(:schema_version) }
      let(:subject) { version.subject }

      it "returns the id of the schema" do
        post("/subjects/#{subject.name}/versions", schema: version.schema.json)
        expect(response).to be_ok
        expect(response.body).to be_json_eql({ id: version.schema_id }.to_json)
      end

      it "does not create a new version" do
        expect do
          post("/subjects/#{subject.name}/versions", schema: version.schema.json)
        end.not_to change(SchemaVersion, :count)
      end
    end

    context "when a previous version of the schema is registered under the subject" do
      let!(:version) { create(:schema_version) }
      let(:subject) { version.subject }
      let(:json) do
        JSON.parse(version.schema.json).tap do |h|
          h['fields'] << { type: :string, name: :additional_field }
        end.to_json
      end

      it "returns the id of a new schema" do
        post("/subjects/#{subject.name}/versions", schema: json)

        expect(response).to be_ok
        expect(response.body).to be_json_eql({ id: version.schema_id }.to_json)
      end
    end

    context "when the schema is already registered under a different subject" do
      let!(:version) { create(:schema_version) }
      let(:original_subject) { version.subject }

      context "when the subject does not exist" do
        let(:subject_name) { 'new_subject' }

        it "returns the id of the schema" do
          post("/subjects/#{subject_name}/versions", schema: version.schema.json)
          expect(response).to be_ok
          expect(response.body).to be_json_eql({ id: version.schema_id }.to_json)
        end

        it "creates a new subject and version" do
          expect do
            expect do
              post("/subjects/#{subject_name}/versions", schema: version.schema.json)
            end.to change(Subject, :count).by(1)
          end.to change(SchemaVersion, :count).by(1)
          expect(Subject.find_by(name: subject_name)).to be_present
          expect(SchemaVersion.latest_for_subject_name(subject_name).first).to be_present
        end
      end

      context "when the subject exists" do
        let!(:original_schema_version) { create(:schema_version) }
        let(:subject_name) { original_schema_version.subject.name }
        # Note: this schema probably fails compatibility
        let(:json) { version.schema.json }

        it "returns the id of the schema" do
          post("/subjects/#{subject_name}/versions", schema: json)
          expect(response).to be_ok
          expect(response.body).to be_json_eql({ id: version.schema_id }.to_json)
        end

        it "creates a new schema version" do
          expect do
            post("/subjects/#{subject_name}/versions", schema: json)
          end.to change(SchemaVersion, :count).by(1)
          new_schema_version = SchemaVersion.latest_for_subject_name(subject_name).first
          expect(new_schema_version.version).to eq(2)
          expect(new_schema_version.schema_id).to eq(version.schema_id)
        end
      end

      context "when the subject and schema do not exist" do
        let(:json) { build(:schema).json }
        let(:subject_name) { 'new_subject' }

        it "returns the id of a new schema" do
          post("/subjects/#{subject_name}/versions", schema: json)
          expect(response).to be_ok
          version = SchemaVersion.latest_for_subject_name(subject_name).first
          expect(response.body).to be_json_eql({ id: version.schema_id }.to_json)
        end

        it "creates a new subject, schema, and schema version" do
          expect do
            expect do
              expect do
                post("/subjects/#{subject_name}/versions", schema: json)
              end.to change(Schema, :count).by(1)
            end.to change(Subject, :count).by(1)
          end.to change(SchemaVersion, :count).by(1)

          version = SchemaVersion.latest_for_subject_name(subject_name).first
          expect(version.version).to eq(1)
          expect(version.subject.name).to eq(subject_name)
          expect(version.schema.json).to eq(json)
        end
      end
    end

    context "retry" do
      context "registering a new schema for a subject" do
        let(:previous_version) { create(:schema_version) }
        let(:subject_name) { previous_version.subject.name }
        let(:json) { build(:schema).json }
        let(:fingerprint) { Schemas::FingerprintGenerator.call(json) }

        before do
          first_time = true
          allow(Schema).to receive(:find_by).with(fingerprint: fingerprint) do
            if first_time
              @schema = Schema.create!(json: json)
              first_time = false
              nil
            else
              @schema
            end
          end
        end

        it "does stuff" do
          post("/subjects/#{subject_name}/versions", schema: json)
          expect(response).to be_ok
          expect(response.body).to be_json_eql({ id: @schema.id }.to_json)
        end
      end
    end
  end

  describe "POST /subjects/:name" do
    it "is secured by Basic auth" do
      unauthorized_post('/subjects/name')
      expect(status).to eq(401)
    end

    context "when the schema exists for the subject" do
      let!(:version) { create(:schema_version) }
      let(:subject_name) { version.subject.name }
      let(:expected) do
        {
          subject: version.subject.name,
          id: version.schema_id,
          version: version.version,
          schema: version.schema.json
        }.to_json
      end

      it "returns information about the schema" do
        post("/subjects/#{subject_name}", schema: version.schema.json)
        expect(response).to be_ok
        expect(response.body).to be_json_eql(expected)
      end
    end

    context "when the subject does not exist" do
      let(:subject_name) { 'fnord' }
      let(:json) { build(:schema).json }

      it "returns a subject not found error" do
        post("/subjects/#{subject_name}", schema: json)
        expect(response).to be_not_found
        expect(response.body).to be_json_eql(SchemaRegistry::Errors::SUBJECT_NOT_FOUND.to_json)
      end
    end

    context "when the schema does not exist for the subject" do
      let!(:version) { create(:schema_version) }
      let(:subject_name) { version.subject.name }
      let(:json) { build(:schema).json }

      it "return a schema not found error" do
        post("/subjects/#{subject_name}", schema: json)
        expect(response).to be_not_found
        expect(response.body).to be_json_eql(SchemaRegistry::Errors::SCHEMA_NOT_FOUND.to_json)
      end
    end

    context "when the schema is invalid" do
      # Confluent schema registry does not specify anything in this case, for
      # this endpoint, but a 422 makes the most sense to me. Better than a 404.
      it "returns an unprocessable entity error" do
        post("/subjects/foo", schema: invalid_json)
        expect(response.status).to eq(422)
        expect(response.body).to eq(SchemaRegistry::Errors::INVALID_AVRO_SCHEMA.to_json)
      end
    end
  end
end
