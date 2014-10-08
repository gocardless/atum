require 'spec_helper'

describe Atum::Generation::Generators::ModuleGenerator do
  let(:module_name) { 'Lemon' }
  let(:schema) { instance_double('Atum::Schema::ApiSchema') }
  let(:url) { 'http://api.lemon.com' }
  let(:default_headers) { double }
  let(:options) { { default_headers: default_headers } }
  let(:generator) { described_class.new(module_name, schema, url, options) }

  describe '#context' do
    let(:erb_context) { {} }
    let(:resources) { double }
    let(:description) { double }
    let(:schema) { double(description: description, schema: {}) }

    before do
      allow(Atum::Generation::ErbContext).to receive(:new)
        .and_return(erb_context)
      allow(generator).to receive(:resources).and_return(resources)
    end

    it 'sets the default_headers on the context' do
      expect(generator.context).to include(default_headers: default_headers)
    end

    it 'sets the schema on the context' do
      expect(generator.context).to include(schema: anything)
    end

    it 'sets the resources on the context' do
      allow(generator).to receive(:resources).and_return(resources)
      expect(generator.context).to include(resources: resources)
    end
  end
end
