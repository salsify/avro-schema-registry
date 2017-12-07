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

    context "with JSON body" do
      include_examples "content type", :post do
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

        let(:path) { "/subjects/#{subject_name}" }
        let(:params) { { schema: version.schema.json } }
      end
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

    it_behaves_like "a secure endpoint" do
      let(:action) { unauthorized_get('/subjects') }
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

      it_behaves_like "a supported subject name",
                      'a name containing a period',
                      'com.example.foo'

      it_behaves_like "a supported subject name",
                      'a name beginning with an underscore',
                      '_underscore'

      it_behaves_like "a supported subject name",
                      'a name containing a digit',
                      'number5'

      it_behaves_like "a supported subject name",
                      'a name containing mixed case',
                      'UPPER_lower_0123456789'

      it_behaves_like "an unsupported subject name",
                      'a name beginning with a digit',
                      '5alive'

      it_behaves_like "an unsupported subject name",
                      'a name containing a hyphen',
                      'foo-bar'

      it_behaves_like "an unsupported subject name",
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

    it_behaves_like "a secure endpoint" do
      let(:version) { create(:version) }
      let(:action) { unauthorized_get("/subjects/#{version.subject.name}/versions") }
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
    it_behaves_like "a secure endpoint" do
      let(:version) { create(:schema_version) }
      let(:action) do
        unauthorized_get("/subjects/#{version.subject.name}/versions/#{version.version}")
      end
    end

    shared_examples_for "a version lookup" do
      before { get("/subjects/#{subject_name}/versions/#{version_id}") }
      subject { response }

      it "returns the schema and it's id" do
        get("/subjects/#{subject_name}/versions/latest")
        expect(response).to be_ok
        expect(response.body).to be_json_eql(expected)
        expect(response.body).to be_json_eql(schema.id).at_path('id')
      end
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
          schema: schema.json,
          id: schema.id
        }.to_json
      end

      context "with a valid version id" do
        let(:version_id) { version.version }

        it_behaves_like "a version lookup"
      end

      context "when the version is specified as 'latest'" do
        let(:version_id) { 'latest' }

        it_behaves_like "a version lookup"
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

  describe "GET /subjects/:name/fingerprints/:fingerprint" do
    let(:version) { create(:schema_version) }
    let(:schema) { version.schema }
    let(:other_schema) { build(:schema) }
    let(:other_version) { create(:schema_version) }
    let(:fingerprint) do
      Schemas::FingerprintGenerator.generate_v2(schema.json)
    end
    let(:other_fingerprint) do
      Schemas::FingerprintGenerator.generate_v2(other_schema.json)
    end
    let(:existing_fingerprint) do
      Schemas::FingerprintGenerator.generate_v2(other_version.schema.json)
    end

    it_behaves_like "a secure endpoint" do
      let(:action) { unauthorized_get("/subjects/#{version.subject.name}/fingerprints/#{fingerprint}") }
    end

    context "content type" do
      include_examples "content type", :get do
        let(:path) { "/subjects/#{version.subject.name}/fingerprints/#{fingerprint}" }
        let(:expected) do
          { id: schema.id }.to_json
        end
      end
    end

    shared_examples_for "identifying a schema by fingerprint" do
      context "when the schema is found" do
        let(:expected) do
          { id: schema.id }.to_json
        end

        it "returns the schema" do
          get("/subjects/#{version.subject.name}/fingerprints/#{fingerprint}")
          expect(response).to be_ok
          expect(response.body).to be_json_eql(expected).including(:id)
        end

        it_behaves_like "a cached endpoint" do
          let(:action) { get("/subjects/#{version.subject.name}/fingerprints/#{fingerprint}") }
        end
      end

      context "error cases" do
        context "when the schema is not found" do
          let(:expected) do
            {
              error_code: 40403,
              message: 'Schema not found'
            }.to_json
          end
          let(:action) { get("/subjects/#{version.subject.name}/fingerprints/#{other_fingerprint}") }

          it "returns a not found response" do
            action
            expect(response).to be_not_found
            expect(response.body).to be_json_eql(expected)
          end

          it_behaves_like "an error that cannot be cached"
        end

        context "when the schema exists for a different subject" do
          let(:expected) do
            {
              error_code: 40403,
              message: 'Schema not found'
            }.to_json
          end
          let(:action) { get("/subjects/#{version.subject.name}/fingerprints/#{existing_fingerprint}") }

          it "returns a not found response" do
            action
            expect(response).to be_not_found
            expect(response.body).to be_json_eql(expected)
          end

          it_behaves_like "an error that cannot be cached"
        end
      end
    end

    context "when the fingerprint version is '1'" do
      let(:fingerprint) { schema.fingerprint }
      let(:other_fingerprint) do
        Schemas::FingerprintGenerator.generate_v1(other_schema.json)
      end
      let(:existing_fingerprint) { other_version.schema.fingerprint }

      before do
        allow(Rails.configuration.x).to receive(:fingerprint_version).and_return('1')
      end

      context "using a string fingerprint" do
        it_behaves_like "identifying a schema by fingerprint"

        context "using a v2 fingerprint" do
          let(:fingerprint) { Schemas::FingerprintGenerator.generate_v2(schema.json) }

          it "does not return the schema" do
            get("/subjects/#{version.subject.name}/fingerprints/#{fingerprint}")
            expect(response).to be_not_found
          end
        end
      end

      context "using an integer fingerprint" do
        let(:fingerprint) { super().to_i(16) }
        let(:other_fingerprint) { super().to_i(16) }
        let(:existing_fingerprint) { super().to_i(16) }

        it_behaves_like "identifying a schema by fingerprint"
      end
    end

    context "when the fingerprint version is '2'" do
      before do
        allow(Rails.configuration.x).to receive(:fingerprint_version).and_return('2')
      end

      context "using a v1 fingerprint" do
        it "does not return the schema" do
          get("/subjects/#{version.subject.name}/fingerprints/#{schema.fingerprint}")
          expect(response).to be_not_found
        end
      end

      context "using a v2 fingerprint" do
        let(:fingerprint) { schema.fingerprint2 }
        let(:other_fingerprint) do
          Schemas::FingerprintGenerator.generate_v2(other_schema.json)
        end
        let(:existing_fingerprint) { other_version.schema.fingerprint2 }

        it_behaves_like "identifying a schema by fingerprint"
      end
    end

    context "when the fingerprint version is 'all'" do
      before do
        allow(Rails.configuration.x).to receive(:fingerprint_version).and_return('all')
      end

      it_behaves_like "identifying a schema by fingerprint"

      context "using a v2 fingerprint" do
        let(:fingerprint) { schema.fingerprint2 }
        let(:other_fingerprint) do
          Schemas::FingerprintGenerator.generate_v2(other_schema.json)
        end
        let(:existing_fingerprint) { other_version.schema.fingerprint2 }

        it_behaves_like "identifying a schema by fingerprint"
      end
    end
  end

  describe "POST /subjects/:name/versions" do
    it_behaves_like "a secure endpoint" do
      let(:version) { create(:version) }
      let(:action) do
        unauthorized_post("/subjects/#{version.subject.name}/versions",
                          params: { schema: version.schema.json })
      end
    end

    context "with an invalid avro schema" do
      let(:subject_name) { 'invalid' }

      it "returns an unprocessable entity error" do
        post("/subjects/#{subject_name}/versions", params: { schema: invalid_json })
        expect(response.status).to eq(422)
        expect(response.body).to be_json_eql(SchemaRegistry::Errors::INVALID_AVRO_SCHEMA.to_json)
      end
    end

    context "when DISABLE_SCHEMA_REGISTRATION is set to 'true'" do
      let(:json) { build(:schema).json }
      let(:subject_name) { 'new_subject' }

      before do
        allow(Rails.configuration.x).to receive(:disable_schema_registration).and_return(true)
      end

      it "returns an error" do
        post("/subjects/#{subject_name}/versions", params: { schema: json })
        expect(response.status).to eq(503)
        expect(response.body).to be_json_eql({ message: 'Schema registration is disabled' }.to_json)
      end
    end

    context "when the app is in read-only mode" do
      let(:json) { build(:schema).json }
      let(:subject_name) { 'new_subject' }

      before do
        allow(Rails.configuration.x).to receive(:read_only_mode).and_return(true)
      end

      it "returns an error" do
        post("/subjects/#{subject_name}/versions", params: { schema: json })
        expect(response.status).to eq(403)
        expect(response.body).to be_json_eql({ message: 'Running in read-only mode' }.to_json)
      end
    end

    context "when the schema and subject do not exist" do
      let(:json) { build(:schema).json }
      let(:subject_name) { 'new_subject' }

      it "returns the id of the new schema", :aggregate_failures do
        expect do
          post("/subjects/#{subject_name}/versions", params: { schema: json })
        end.to change(Schema, :count).by(1)
        expect(response).to be_ok
        schema_id = SchemaVersion.latest_for_subject_name(subject_name).first.schema_id
        expect(response.body).to be_json_eql({ id: schema_id }.to_json).including(:id)
      end

      it "creates a new subject and version" do
        expect do
          expect do
            post("/subjects/#{subject_name}/versions", params: { schema: json })
          end.to change(Subject, :count).by(1)
        end.to change(SchemaVersion, :count).by(1)
        expect(Subject.find_by(name: subject_name)).to be_present
        expect(SchemaVersion.latest_for_subject_name(subject_name).first).to be_present
      end

      context "when the compatibility level to use after registration is specified" do
        let(:after_compatibility) { 'FULL' }

        it "creates the config for the subject", :aggregate_failures do
          expect do
            post("/subjects/#{subject_name}/versions",
                 params: { schema: json, after_compatibility: after_compatibility })
          end.to change(Config, :count).by(1)
          expect(Subject.find_by(name: subject_name).config.compatibility).to eq(after_compatibility)
        end
      end
    end

    context "when the schema is already registered under the subject" do
      let!(:version) { create(:schema_version) }
      let(:subject) { version.subject }

      it "returns the id of the schema" do
        post("/subjects/#{subject.name}/versions", params: { schema: version.schema.json })
        expect(response).to be_ok
        expect(response.body).to be_json_eql({ id: version.schema_id }.to_json).including(:id)
      end

      it "does not create a new version" do
        expect do
          post("/subjects/#{subject.name}/versions", params: { schema: version.schema.json })
        end.not_to change(SchemaVersion, :count)
      end

      it "ignores setting a new compatibility level" do
        expect do
          post("/subjects/#{subject.name}/versions",
               params: { schema: version.schema.json, after_compatibility: 'BACKWARD' })
        end.not_to change(Config, :count)
      end
    end

    context "when a previous version of the schema is registered under the subject" do
      let!(:version) { create(:schema_version) }
      let(:subject) { version.subject }
      let(:json) do
        JSON.parse(version.schema.json).tap do |h|
          h['fields'] << { type: :string, name: :additional_field, default: '' }
        end.to_json
      end

      it "returns the id of a new schema" do
        expect do
          expect do
            post("/subjects/#{subject.name}/versions", params: { schema: json })
          end.to change(Schema, :count).by(1)
        end.to change(SchemaVersion, :count).by(1)

        expect(response).to be_ok
        expect(JSON.parse(response.body)['id']).not_to eq(version.schema.id)
      end

      context "when the new version of the schema adds a default" do
        let(:schema) { create(:schema_without_default) }
        let!(:version) { create(:schema_version, schema_id: schema.id) }
        let(:json) do
          JSON.parse(schema.json).tap do |h|
            h['fields'].first.merge!(default: 0)
          end.to_json
        end

        before do
          # only fingerprint version '2' recognizes a default as a change
          allow(Rails.configuration.x).to receive(:fingerprint_version).and_return('2')
        end

        it "returns the id of a new schema" do
          expect do
            expect do
              post("/subjects/#{subject.name}/versions", params: { schema: json })
            end.to change(Schema, :count).by(1)
          end.to change(SchemaVersion, :count).by(1)

          expect(response).to be_ok
          expect(JSON.parse(response.body)['id']).not_to eq(schema.id)
        end
      end

      context "when the new version of the schema is incompatible" do
        let(:json) { build(:schema).json }

        it "returns an incompatible schema error" do
          post("/subjects/#{subject.name}/versions", params: { schema: json })
          expect(status).to eq(409)
          expect(response.body).to be_json_eql(SchemaRegistry::Errors::INCOMPATIBLE_AVRO_SCHEMA.to_json)
        end

        context "when the compatibility level to use during registration is specified" do
          it "returns the id of a new schema" do
            expect do
              expect do
                expect do
                  post("/subjects/#{subject.name}/versions", params: { schema: json, with_compatibility: 'NONE' })
                end.to change(Schema, :count).by(1)
              end.to change(SchemaVersion, :count).by(1)
            end.not_to change(Config, :count)
          end

          context "when a compatibility level to use after registration is specified" do
            let(:after_compatibility) { 'FORWARD' }

            it "returns the id of a new schema and updates the config for the subject", :aggregate_failures do
              expect do
                expect do
                  expect do
                    post("/subjects/#{subject.name}/versions",
                         params: { schema: json, with_compatibility: 'NONE', after_compatibility: after_compatibility })
                  end.to change(Schema, :count).by(1)
                end.to change(SchemaVersion, :count).by(1)
              end.to change(Config, :count).by(1)

              expect(Config.find_by(subject_id: subject.id).compatibility).to eq(after_compatibility)
            end

            context "when config already exists for the subject" do
              let!(:config) { create(:config, subject_id: subject.id, compatibility: 'FULL') }

              it "updates the config for the subject" do
                expect do
                  post("/subjects/#{subject.name}/versions",
                       params: { schema: json, with_compatibility: 'NONE', after_compatibility: after_compatibility })
                end.not_to change(Config, :count)
                expect(config.reload.compatibility).to eq(after_compatibility)
              end
            end
          end
        end
      end
    end

    context "when the schema is already registered under a different subject" do
      let!(:version) { create(:schema_version) }
      let(:original_subject) { version.subject }

      context "when the subject does not exist" do
        let(:subject_name) { 'new_subject' }

        it "returns the id of the schema" do
          post("/subjects/#{subject_name}/versions", params: { schema: version.schema.json })
          expect(response).to be_ok
          expect(response.body).to be_json_eql({ id: version.schema_id }.to_json).including(:id)
        end

        it "creates a new subject and version" do
          expect do
            expect do
              post("/subjects/#{subject_name}/versions", params: { schema: version.schema.json })
            end.to change(Subject, :count).by(1)
          end.to change(SchemaVersion, :count).by(1)
          expect(Subject.find_by(name: subject_name)).to be_present
          expect(SchemaVersion.latest_for_subject_name(subject_name).first).to be_present
        end
      end

      context "when the subject exists" do
        let(:json) { version.schema.json }
        let(:new_subject) { create(:subject) }
        let(:subject_name) { new_subject.name }
        let(:new_json) do
          JSON.parse(json).tap do |avro|
            avro['fields'] << { name: :new, type: :string, default: '' }
          end.to_json
        end
        let(:new_schema) { create(:schema, json: new_json) }
        let!(:new_version) { create(:schema_version, subject: new_subject, schema: new_schema) }

        it "returns the id of the schema" do
          post("/subjects/#{subject_name}/versions", params: { schema: json })
          expect(response).to be_ok
          expect(response.body).to be_json_eql({ id: version.schema_id }.to_json).including(:id)
        end

        it "creates a new schema version" do
          expect do
            post("/subjects/#{subject_name}/versions", params: { schema: json })
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
          post("/subjects/#{subject_name}/versions", params: { schema: json })
          expect(response).to be_ok
          version = SchemaVersion.latest_for_subject_name(subject_name).first
          expect(response.body).to be_json_eql({ id: version.schema_id }.to_json).including(:id)
        end

        it "creates a new subject, schema, and schema version" do
          expect do
            expect do
              expect do
                post("/subjects/#{subject_name}/versions", params: { schema: json })
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
      before do
        # after migrations on version fingerprint2 has a unique constraint
        allow(Rails.configuration.x).to receive(:fingerprint_version).and_return('2')
      end

      context "registering a new schema for a subject" do
        let!(:previous_version) { create(:schema_version) }
        let(:subject_name) { previous_version.subject.name }
        let(:json) do
          JSON.parse(previous_version.schema.json).tap do |avro|
            avro['fields'] << { name: :extra, type: :string, default: '' }
          end.to_json
        end
        let(:fingerprint) { Schemas::FingerprintGenerator.generate_v2(json) }

        before do
          first_time = true
          allow(Schema).to receive(:find_by).with(fingerprint2: fingerprint) do
            if first_time
              @schema = Schema.create!(json: json)
              first_time = false
              nil
            else
              @schema
            end
          end
        end

        it "retries once" do
          expect do
            post("/subjects/#{subject_name}/versions", params: { schema: json })
          end.to change(Schema, :count).by(1)

          expect(response).to be_ok
          expect(response.body).to be_json_eql({ id: @schema.id }.to_json).including(:id)
        end
      end
    end
  end

  describe "POST /subjects/:name" do
    it_behaves_like "a secure endpoint" do
      let(:version) { create(:version) }
      let(:action) do
        unauthorized_post("/subjects/#{version.subject.name}",
                          params: { schema: version.schema.json })
      end
    end

    shared_examples_for "checking for schema existence" do
      before do
        allow(Rails.configuration.x).to receive(:fingerprint_version).and_return(fingerprint_version)
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
          post("/subjects/#{subject_name}", params: { schema: version.schema.json })
          expect(response).to be_ok
          expect(response.body).to be_json_eql(expected)
        end
      end

      context "when the subject does not exist" do
        let(:subject_name) { 'fnord' }
        let(:json) { build(:schema).json }

        it "returns a subject not found error" do
          post("/subjects/#{subject_name}", params: { schema: json })
          expect(response).to be_not_found
          expect(response.body).to be_json_eql(SchemaRegistry::Errors::SUBJECT_NOT_FOUND.to_json)
        end
      end

      context "when the schema does not exist for the subject" do
        let!(:version) { create(:schema_version) }
        let(:subject_name) { version.subject.name }
        let(:json) { build(:schema).json }

        it "return a schema not found error" do
          post("/subjects/#{subject_name}", params: { schema: json })
          expect(response).to be_not_found
          expect(response.body).to be_json_eql(SchemaRegistry::Errors::SCHEMA_NOT_FOUND.to_json)
        end
      end
    end

    context "when fingerprint_version is '1'" do
      let(:fingerprint_version) { '1' }

      it_behaves_like "checking for schema existence"
    end

    context "when fingerprint_version is '2'" do
      let(:fingerprint_version) { '2' }

      it_behaves_like "checking for schema existence"
    end

    context "when fingerprint_version is 'all'" do
      let(:fingerprint_version) { '2' }

      it_behaves_like "checking for schema existence"
    end

    context "when the schema is invalid" do
      # Confluent schema registry does not specify anything in this case, for
      # this endpoint, but a 422 makes the most sense to me. Better than a 404.
      it "returns an unprocessable entity error" do
        post('/subjects/foo', params: { schema: invalid_json })
        expect(response.status).to eq(422)
        expect(response.body).to eq(SchemaRegistry::Errors::INVALID_AVRO_SCHEMA.to_json)
      end
    end
  end
end
