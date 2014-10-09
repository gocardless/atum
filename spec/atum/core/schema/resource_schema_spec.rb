require 'spec_helper'

describe Atum::Core::Schema::ResourceSchema do
  let(:schema) { Atum::Core::Schema::ApiSchema.new(SAMPLE_SCHEMA) }
  let(:resource) { schema.resource_schema_for('resource') }

  describe '#link_schema_for' do
    it 'gets a link schema' do
      expect(resource.link_schema_for('list').name).to eq('list')
    end

    it 'raises with unknown link' do
      expect { resource.link_schema_for('lolno') }
        .to raise_error(Atum::Core::SchemaError)
    end
  end

  describe '#link_schemas' do
    it 'returns an array of link schemas' do
      expect(resource.link_schemas.map(&:name))
        .to eq(%w(list info identify_resource create update delete))
    end
  end
end
