require 'spec_helper'

describe Atum::Core::ApiError do
  let(:message) { 'Foo failed' }
  let(:url) { 'http://example.com/how-to-fix' }

  subject { described_class.new(request: nil, response: response).message }

  let(:response) { Atum::Core::Response.new(json_response) }
  let(:json_response) do
    double(headers: { 'Content-Type' => content_type },
           body: response_body,
           status: 500)
  end
  let(:content_type) { 'application/json' }

  context 'without a documentation url' do
    let(:response_body) { { 'error' => { 'message' => message } }.to_json }
    it { is_expected.to eq(message) }
  end

  context 'with a documentation url' do
    let(:response_body) do
      {
        'error' => { 'message' => message, 'documentation_url' => url }
      }.to_json
    end
    it { is_expected.to include(message) }
    it { is_expected.to include(url) }
  end

  context 'with a raw response' do
    let(:content_type) { 'application/text' }
    let(:response_body) { 'FOOBAR' }
    it { is_expected.to include(response_body) }
  end
end
