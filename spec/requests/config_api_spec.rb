# frozen_string_literal: true

describe ConfigAPI do
  let(:expected) do
    { compatibility: compatibility }.to_json
  end

  describe "GET /config" do
    let(:compatibility) { Compatibility.global }

    it "returns the global compatibility level" do
      get('/config')
      expect(response).to be_ok
      expect(response.body).to be_json_eql(expected)
    end

    it_behaves_like "a secure endpoint" do
      let(:action) { unauthorized_get('/config') }
    end
  end

  describe "PUT /config" do
    let(:compatibility) { 'FORWARD' }

    it "changes the global compatibility level" do
      put('/config', params: { compatibility: compatibility })
      expect(response).to be_ok
      expect(response.body).to be_json_eql({ compatibility: compatibility }.to_json)
      expect(Config.global.compatibility).to eq(compatibility)
    end

    context "when the app is in read-only mode" do
      before do
        allow(Rails.configuration.x).to receive(:read_only_mode).and_return(true)
      end

      it "returns an error" do
        put('/config', params: { compatibility: compatibility })
        expect(response.status).to eq(403)
        expect(response.body).to be_json_eql({ message: 'Running in read-only mode' }.to_json)
      end
    end

    it_behaves_like "a secure endpoint" do
      let(:action) { unauthorized_put('/config', params: { compatibility: compatibility }) }
    end

    context "when the compatibility value is not uppercase" do
      it "changes the global compatibility level" do
        put('/config', params: { compatibility: compatibility.downcase })
        expect(response).to be_ok
        expect(response.body).to be_json_eql({ compatibility: compatibility }.to_json)
        expect(Config.global.compatibility).to eq(compatibility)
      end
    end

    context "when the compatibility level is invalid" do
      let(:compatibility) { 'BACK' }

      it "returns an unprocessable entity error" do
        put('/config', params: { compatibility: compatibility })
        expect(status).to eq(422)
        expect(response.body)
          .to be_json_eql(SchemaRegistry::Errors::INVALID_COMPATIBILITY_LEVEL.to_json)
      end
    end
  end

  describe "GET /config/:subject" do
    let(:subject) { create(:subject) }
    let(:compatibility) { Compatibility.global }

    it_behaves_like "a secure endpoint" do
      let(:action) { unauthorized_get("/config/#{subject.name}") }
    end

    context "when compatibility is set for the subject" do
      before { subject.create_config.update_compatibility!(compatibility) }

      it "returns the compatibility level for the subject" do
        get("/config/#{subject.name}")
        expect(response).to be_ok
        expect(response.body).to be_json_eql(expected)
      end
    end

    context "when compatibility has not been set for the subject" do
      let(:compatibility) { nil }

      it "returns null" do
        get("/config/#{subject.name}")
        expect(response).to be_ok
        expect(response.body).to be_json_eql(expected)
      end
    end

    context "when the subject does not exist" do
      let(:name) { 'example.does_not_exist' }

      it "returns a not found error" do
        get("/config/#{name}")
        expect(response).to be_not_found
        expect(response.body).to be_json_eql(SchemaRegistry::Errors::SUBJECT_NOT_FOUND.to_json)
      end
    end
  end

  describe "PUT /config/:subject" do
    let(:subject) { create(:subject) }
    let(:compatibility) { 'BACKWARD' }

    it "updates the compatibility level on the subject" do
      put("/config/#{subject.name}", params: { compatibility: compatibility })
      expect(response).to be_ok
      expect(response.body).to be_json_eql(expected)
      expect(subject.config.compatibility).to eq(compatibility)
    end

    context "when the app is in read-only mode" do
      before do
        allow(Rails.configuration.x).to receive(:read_only_mode).and_return(true)
      end

      it "returns an error" do
        put("/config/#{subject.name}", params: { compatibility: compatibility })
        expect(response.status).to eq(403)
        expect(response.body).to be_json_eql({ message: 'Running in read-only mode' }.to_json)
      end
    end

    context "when the subject already has a compatibility level set" do
      let(:original_compatibility) { 'FORWARD' }

      before { subject.create_config!(compatibility: original_compatibility) }

      it "updates the compatibility level on the subject" do
        put("/config/#{subject.name}", params: { compatibility: compatibility })
        expect(response).to be_ok
        expect(response.body).to be_json_eql(expected)
        expect(subject.config.reload.compatibility).to eq(compatibility)
      end
    end

    context "when the compatibility level is not uppercase" do
      it "updates the compatibility level on the subject" do
        put("/config/#{subject.name}", params: { compatibility: compatibility.downcase })
        expect(response).to be_ok
        expect(response.body).to be_json_eql(expected)
        expect(subject.config.compatibility).to eq(compatibility)
      end
    end

    it_behaves_like "a secure endpoint" do
      let(:action) do
        unauthorized_put("/config/#{subject.name}", params: { compatibility: compatibility })
      end
    end

    context "when the subject does not exist" do
      let(:name) { 'example.does_not_exist' }

      it "returns a not found error" do
        put("/config/#{name}", params: { compatibility: compatibility })
        expect(response).to be_not_found
        expect(response.body).to be_json_eql(SchemaRegistry::Errors::SUBJECT_NOT_FOUND.to_json)
      end
    end

    context "when the compatibility level is invalid" do
      let(:compatibility) { 'FOO' }

      it "returns an unprocessable entity error" do
        put("/config/#{subject.name}", params: { compatibility: compatibility })
        expect(status).to eq(422)
        expect(response.body)
          .to be_json_eql(SchemaRegistry::Errors::INVALID_COMPATIBILITY_LEVEL.to_json)
      end
    end
  end
end
