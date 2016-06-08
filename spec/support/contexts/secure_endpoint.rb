shared_examples_for "a secure endpoint" do
  context "when HTTP Basic password is disabled" do
    before do
      allow(Rails.configuration.x).to receive(:disable_password).and_return(true)
    end

    it "allows unauthorized requests" do
      action
      expect(status).to eq(200)
    end
  end

  it "is secured by Basic auth" do
    action
    expect(status).to eq(401)
  end
end
