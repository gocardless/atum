require 'spec_helper'

describe Atum::Core::Schema::ApiSchema do
  let(:schema) { described_class.new(SAMPLE_SCHEMA) }

  describe '#description' do
    it 'returns the schema description' do
      expect(schema.description).to eq(SAMPLE_SCHEMA['description'])
    end
  end

  describe '#resource_schema_for' do
    it 'has name' do
      expect(schema.resource_schema_for('resource').name).to eq('resource')
    end

    it 'raises with unknown resources' do
      expect { schema.resource_schema_for('lolno') }
        .to raise_error(Atum::Core::SchemaError)
    end
  end

  describe '#resource_schemas' do
    it 'has several resource schemas' do
      expect(schema.resource_schemas.map(&:name))
        .to eq(%w(resource another-resource))
    end
  end

  describe '#inspect' do
    it 'includes description' do
      expect(schema.inspect).to include(SAMPLE_SCHEMA['description'])
    end
  end

  describe '#lookup_path' do
    it 'returns whole schema for empty path' do
      expect(schema.lookup_path).to eq(SAMPLE_SCHEMA)
    end

    it 'fetches values at nested keys' do
      expect(schema.lookup_path('definitions', 'another-resource', 'id'))
        .to eq('schema/another-resource')

      expect(schema.lookup_path('definitions', 'resource'))
        .to eq(SAMPLE_SCHEMA['definitions']['resource'])
    end
  end
end
