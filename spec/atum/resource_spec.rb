require 'spec_helper'

describe Atum::Resource do
  let(:resource) { Atum::Resource.new(params) }
  let(:params) { {} }
  let(:schema_resource) do
    Atum::Schemas::ApiSchema.new(SAMPLE_SCHEMA).resource('resource')
  end

  it 'raises on invalid link' do
    expect { resource.unknown }
      .to raise_error(NoMethodError,
                      /undefined method `unknown' for #<Atum::Resource/)
  end

  context 'when a link is available' do
    let(:link) do
      Atum::Link.new('https://username:password@example.com',
                     schema_resource.link_schema('list'))
    end
    let(:params) { { 'list' => link } }
    let(:response_body) { { 'resources' => ['Hello, world!'] } }

    it 'gets the link' do
      stub_request(:get, 'https://username:password@example.com/resource')
        .to_return(status: 200, body: response_body.to_json,
                  headers: { 'Content-Type' => 'application/json' })

      expect(resource.list({})).to eq(['Hello, world!'])
    end
  end
end
