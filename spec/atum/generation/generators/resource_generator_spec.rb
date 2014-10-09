require 'spec_helper'

describe Atum::Generation::Generators::ResourceGenerator do
  let(:description) { double }
  let(:class_name) { double }
  let(:links) { double }
  let(:resource_name) { double }
  let(:resource) do
    double(description: description,
           class_name: class_name,
           links: links,
           name: resource_name)
  end
  let(:module_name) { 'Lemon' }
  let(:schema) { double }
  let(:url) { 'http://api.lemon.com' }
  let(:default_headers) { double }
  let(:options) { { default_headers: default_headers } }
  let(:generator) do
    described_class.new(resource, module_name, schema, url, options)
  end

  describe '#context' do
    let(:erb_context) { {} }

    it 'sets the description on the context' do
      expect(generator.context.to_hash.with_indifferent_access)
        .to include(description: description)
    end

    it 'sets the class_name on the context' do
      expect(generator.context.to_hash.with_indifferent_access)
        .to include(class_name: class_name)
    end

    it 'sets the links on the context' do
      expect(generator.context.to_hash.with_indifferent_access)
        .to include(links: links)
    end

    it 'sets the resource_name on the context' do
      expect(generator.context.to_hash.with_indifferent_access)
        .to include(resource_name: resource_name)
    end
  end
end
