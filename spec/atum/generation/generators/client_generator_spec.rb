require 'spec_helper'

describe Atum::Generation::Generators::ClientGenerator do
  let(:module_name) { 'Lemon' }
  let(:schema) { double }
  let(:url) { 'http://api.lemon.com' }
  let(:options) { {} }
  let(:generator) { described_class.new(module_name, schema, url, options) }

  describe '#context' do
    let(:erb_context) { {} }
    let(:resources) { double }
    let(:description) { double }
    let(:schema) { double(description: description) }

    before do
      allow(Atum::Generation::ErbContext).to receive(:new)
        .and_return(erb_context)
      allow(generator).to receive(:resources).and_return(resources)
    end

    it 'sets the description on the context' do
      expect(generator.context).to include(description: description)
    end

    it 'sets the resources on the context' do
      expect(generator.context).to include(resources: resources)
    end
  end
end
