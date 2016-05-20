# This shared example expects the following variables to be defined
# @param :expected [JSON] JSON response
# @param :path [String] Request path
# @param :params [Hash, NilClass] Optional params for request
shared_examples_for 'content type' do |verb|
  let(:_params) { defined?(params) ? params : nil }

  it "returns a schema registry v1 response" do
    send(verb, path, _params)
    expect(response.headers['Content-Type']).to eq(BaseAPI::SCHEMA_REGISTRY_V1_CONTENT_TYPE)
  end

  it "accepts schema registry v1 json requests" do
    send(verb, path, _params,
         'ACCEPT' => BaseAPI::SCHEMA_REGISTRY_V1_CONTENT_TYPE,
           'CONTENT_TYPE' => BaseAPI::SCHEMA_REGISTRY_V1_CONTENT_TYPE)
    expect(response).to be_ok
    expect(response.body).to be_json_eql(expected)
  end

  it "accepts schema registry json requests" do
    send(verb, path, _params,
         'ACCEPT' => BaseAPI::SCHEMA_REGISTRY_CONTENT_TYPE,
           'CONTENT_TYPE' => BaseAPI::SCHEMA_REGISTRY_CONTENT_TYPE)
    expect(response).to be_ok
    expect(response.body).to be_json_eql(expected)
  end

  it "accepts json requests" do
    send(verb, path, _params,
         'ACCEPT' => Grape::ContentTypes::CONTENT_TYPES[:json],
           'CONTENT_TYPE' => Grape::ContentTypes::CONTENT_TYPES[:json])
    expect(response).to be_ok
    expect(response.body).to be_json_eql(expected)
  end
end
