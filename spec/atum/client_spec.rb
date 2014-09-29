require 'spec_helper'

describe Atum::Client do
  let(:client) { Atum::Client.new({}, 'http://foo:bar@example.com') }

  # TODO: I think this is really testing password redaction, refactor?
  describe '#to_s' do
    subject { client.to_s }
    it { should eq('#<Atum::Client url="http://foo:REDACTED@example.com">') }
  end

  describe '#resource' do
    let(:client) { Atum::Client.new({}, 'http://example.com') }
    subject(:command) { -> { client.unknown } }

    context 'without a matching resource' do
      it do
        is_expected.to raise_error(
          NoMethodError,
          "resource `unknown' doesn't exist for " \
          '#<Atum::Client url="http://example.com">')
      end
    end
  end

  describe '.client_from_schema' do
    let(:schema) { Atum::Schemas::ApiSchema.new(SAMPLE_SCHEMA) }
    let(:client) do
      Atum::Client.client_from_schema(schema, 'https://example.com')
    end
    let(:body) { { 'resources' => { 'Hello' => 'World' } } }

    it 'should make requests to the API' do
      WebMock.stub_request(:post, 'https://example.com/resource')
        .to_return(status: 201, body: body.to_json,
                  headers: { 'Content-Type' => 'application/json' })

      expect(client.resource.create(body)).to eq(body['resources'])
    end
  end
end
