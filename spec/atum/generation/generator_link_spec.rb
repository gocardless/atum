require 'spec_helper'

describe Atum::Generation::GeneratorLink do
  let(:generator_link) { described_class.new(link_schema) }

  describe '#name' do
    let(:link_schema) { double(name: 'foo') }
    it 'delegates to the link schema' do
      expect(generator_link.name).to eq('foo')
    end
  end

  describe '#description' do
    let(:link_schema) { double(description: 'a really cool link') }
    it 'delegates to the link schema' do
      expect(generator_link.description).to eq('a really cool link')
    end
  end

  describe '#parameters' do
    let(:params) { [double] }
    let(:link_schema) { instance_double('LinkSchema', parameters: params) }

    it 'includes the link schema param details' do
      params.each do |param|
        expect(generator_link.parameters).to include(param)
      end
    end

    it 'adds an optional parameter' do
      expect(generator_link.parameters.last).to be_an(Atum::Generation::OptionsParameter)
    end
  end

  describe '#parameter_names_with_defaults' do
    let(:link_schema) { double }
    before do
      allow(generator_link).to receive(:parameters)
        .and_return([double(name: 'first_param'),
                     double(name: 'options', default: '{}')])
    end

    it 'should return the right function signature' do
      expect(generator_link.parameter_names_with_defaults).to eq(
        'first_param, options = {}')
    end
  end

  describe '#parameter_names' do
    let(:link_schema) { double }
    before do
      allow(generator_link).to receive(:parameters)
        .and_return([double(name: 'first_param'),
                     double(name: 'options', default: '{}')])
    end

    it 'should return the right signature' do
      expect(generator_link.parameter_names).to eq(
        'first_param, options')
    end
  end
end
