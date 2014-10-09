require 'spec_helper'

describe Atum::Generation::Generators::BaseGenerator do
  let(:module_name) { 'Lemon' }
  let(:schema) { instance_double('ApiSchema') }
  let(:url) { 'http://api.lemon.com' }
  let(:options) { {} }
  let(:generator) { described_class.new(module_name, schema, url, options) }

  describe '#context' do
    let(:erb_context) { {} }

    before do
      allow(Atum::Generation::ErbContext).to receive(:new)
        .and_return(erb_context)
    end

    it 'generates a new ErbContext' do
      expect(Atum::Generation::ErbContext).to receive(:new)
      generator.context
    end

    it 'sets the module name' do
      expect(generator.context).to include(module_name: module_name)
    end
  end

  describe '#template' do
    context 'when TEMPLATE_NAME is not defined' do
      subject(:method) { -> { generator.template } }
      it { is_expected.to raise_error(NotImplementedError) }
    end

    context 'when TEMPLATE_NAME is defined' do
      let(:template_name) { 'foobar' }
      before do
        allow(generator).to receive(:template_name).and_return(template_name)
      end

      it 'should attempt to read the file' do
        expect(File).to receive(:read) do |arg|
          expect(arg).to include(template_name)
        end.and_return(nil)
        generator.template
      end

      it 'should send the opened file through Erubis' do
        file = double
        allow(File).to receive(:read).and_return(file)
        expect(Erubis::Eruby).to receive(:new).with(file)
        generator.template
      end
    end
  end

  describe '#generate' do
    it 'evaluates the template with the context' do
      template = double
      context = double
      allow(generator).to receive(:template).and_return(template)
      allow(generator).to receive(:context).and_return(context)
      expect(template).to receive(:evaluate).with(context)
      generator.generate
    end
  end

  describe '#resources' do
    it 'wraps resources with GeneratorResource objects' do
      allow(schema).to receive(:resource_schemas).and_return([double])
      generator.resources.each do |gr|
        expect(gr).to be_a(Atum::Generation::GeneratorResource)
      end
    end
  end
end
