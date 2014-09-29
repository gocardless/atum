require 'spec_helper'

describe Atum::Schemas::ResourceSchema do
  let(:schema) { Atum::Schemas::ApiSchema.new(SAMPLE_SCHEMA) }
  let(:resource) { schema.resource('resource') }

  describe '#link' do
    it 'gets a link' do
      expect(resource.link_schema('list').name).to eq('list')
    end

    it 'raises with unknown link' do
      expect { resource.link_schema('lolno') }.
        to raise_error(Atum::SchemaError)
    end
  end

  describe '#links' do
    it 'returns an array of links' do
      expect(resource.links.map(&:name)).
        to eq(%w(list info identify_resource create update delete))
    end
  end
end
