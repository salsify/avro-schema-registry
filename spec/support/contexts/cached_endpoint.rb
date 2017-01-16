shared_examples_for "a cached endpoint" do
  context "when caching is enabled" do
    before do
      allow(Rails.configuration.x).to receive(:allow_response_caching).and_return(true)
    end

    it "allows the response to be cached" do
      action
      expect(response.headers['Cache-Control']).to eq(Helpers::CacheHelper::CACHE_CONTROL_VALUE)
    end
  end

  context "when caching is not enabled" do
    before do
      allow(Rails.configuration.x).to receive(:allow_response_caching).and_return(false)
    end

    it "does not allow the response to be cached" do
      action
      expect(response.headers['Cache-Control']).to match(/max-age=0,/)
    end
  end
end

shared_examples_for "an error that cannot be cached" do
  it "does not allow the response to be cached" do
    action
    expect(response.headers['Cache-Control']).to eq('no-cache')
  end
end
