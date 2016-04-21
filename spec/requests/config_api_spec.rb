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

    it "is secured by Basic auth" do
      unauthorized_get('/config')
      expect(status).to eq(401)
    end
  end

  describe "PUT /config" do
    let(:compatibility) { 'FORWARD' }

    it "changes the global compatibility level" do
      put('/config', compatibility: compatibility)
      expect(response).to be_ok
      expect(response.body)
      expect(Config.pluck(:value).first).to eq(compatibility)
    end

    it "is secured by Basic auth" do
      unauthorized_put('/config', compatibility: compatibility)
      expect(status).to eq(401)
    end

    context "when the compatibility level is invalid" do
      let(:compatibility) { 'BACK' }

      it "returns an unprocessable entity error" do
        put('/config', compatibility: compatibility)
        expect(status).to eq(422)
        expect(response.body)
          .to be_json_eql(SchemaRegistry::Errors::INVALID_COMPATIBILITY_LEVEL.to_json)
      end
    end
  end

  describe "GET /config/;subject" do
    let(:subject) { create(:subject, compatibility: compatibility) }
    let(:compatibility) { Compatibility.global }

    it "returns the compatibility level for the subject" do
      get("/config/#{subject.name}")
      expect(response).to be_ok
      expect(response.body).to be_json_eql(expected)
    end

    it "is secured by Basic auth" do
      unauthorized_get("/config/#{subject.name}")
      expect(status).to eq(401)
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
    let(:expected) { { compatibility: compatibility }.to_json }

    it "updates the compatibility level on the subject" do
      put("/config/#{subject.name}", compatibility: compatibility)
      expect(response).to be_ok
      expect(response.body).to be_json_eql(expected)
      expect(subject.reload.compatibility).to eq(compatibility)
    end

    it "is secured by Basic auth" do
      unauthorized_put("/config/#{subject.name}", compatibility: compatibility)
      expect(status).to eq(401)
    end

    context "when the subject does not exist" do
      let(:name) { 'example.does_not_exist' }

      it "returns a not found error" do
        put("/config/#{name}", compatibility: compatibility)
        expect(response).to be_not_found
        expect(response.body).to be_json_eql(SchemaRegistry::Errors::SUBJECT_NOT_FOUND.to_json)
      end
    end

    context "when the compatibility level is invalid" do
      let(:compatibility) { 'FOO' }

      it "returns an unprocessable entity error" do
        put("/config/#{subject.name}", compatibility: compatibility)
        expect(status).to eq(422)
        expect(response.body)
          .to be_json_eql(SchemaRegistry::Errors::INVALID_COMPATIBILITY_LEVEL.to_json)
      end
    end
  end
end
