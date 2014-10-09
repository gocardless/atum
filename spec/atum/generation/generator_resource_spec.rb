require 'spec_helper'

describe Atum::Generation::GeneratorResource do
  let(:resource_schema) do
    instance_double('Atum::Core::Schema::ResourceSchema',
                    name: 'super-awesome-resource',
                    description: 'really great',
                    link_schemas: [double, double, double])
  end
  let(:generator_resource) { described_class.new(resource_schema) }

  describe '#name' do
    subject { generator_resource.name }
    it 'should delegate to the resource schema' do
      expect(generator_resource.name).to eq('super_awesome_resource')
    end
  end

  describe '#description' do
    subject { generator_resource.description }
    it { is_expected.to eq(resource_schema.description) }
  end

  describe '#links' do
    subject(:method) { -> {} }

    it 'should create a GeneratorLink for each link schema' do
      expect(Atum::Generation::GeneratorLink).to receive(:new).exactly(3).times
      generator_resource.links
    end

    it 'should return an Array of GeneratorLinks' do
      generator_resource.links.each do |link|
        expect(link).to be_a(Atum::Generation::GeneratorLink)
      end
    end

    it 'should memoize' do
      expect(resource_schema).to receive(:link_schemas).once
      generator_resource.links
      generator_resource.links
    end
  end
end
