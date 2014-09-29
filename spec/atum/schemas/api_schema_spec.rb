require 'spec_helper'

describe Atum::Schemas::ApiSchema do
  let(:schema) { described_class.new(SAMPLE_SCHEMA) }

  describe '#description' do
    it 'returns the schema description' do
      expect(schema.description).to eq(SAMPLE_SCHEMA['description'])
    end
  end

  describe '#resource' do
    it 'has name' do
      expect(schema.resource('resource').name).to eq('resource')
    end

    it 'raises with unknown resources' do
      expect { schema.resource('lolno') }.
        to raise_error(Atum::SchemaError)
    end
  end

  describe '#resources' do
    it 'has several resources' do
      expect(schema.resources.map(&:name)).
        to eq(%w(resource another-resource))
    end
  end

  describe '#to_s' do
    it 'includes description' do
      expect(schema.to_s).to include(SAMPLE_SCHEMA['description'])
    end
  end

  describe '#lookup_path' do
    it 'returns whole schema for empty path' do
      expect(schema.lookup_path).to eq(SAMPLE_SCHEMA)
    end

    it 'fetches values at nested keys' do
      expect(schema.lookup_path('definitions', 'another-resource', 'id')).
        to eq('schema/another-resource')

      expect(schema.lookup_path('definitions', 'resource')).
        to eq(SAMPLE_SCHEMA['definitions']['resource'])
    end
  end
end
