require 'spec_helper'

describe Atum::Schemas::LinkSchema do
  let(:schema) { Atum::Schemas::ApiSchema.new(SAMPLE_SCHEMA) }
  let(:resource) { schema.resource('resource') }
  let(:list) { resource.link_schema('list') }
  let(:info) { resource.link_schema('info') }
  let(:identify) { resource.link_schema('identify_resource') }
  let(:create) { resource.link_schema('create') }
  let(:update) { resource.link_schema('update') }

  describe '#name' do
    it 'returns the name' do
      expect(list.name).to eq('list')
    end
  end

  describe '#resource_name' do
    it 'returns the resource name' do
      expect(list.resource_name).to eq('resource')
    end
  end

  describe '#description' do
    it 'returns the link description' do
      expect(list.description).to eq('Show all sample resources')
    end
  end

  describe '#parameter_details' do
    it 'returns names and descriptions' do
      expect(identify.parameter_details.length).to eq(1)
      expect(identify.parameter_details[0].name).
        to eq('resource_uuid_field_or_resource_email_field')
      expect(identify.parameter_details[0].description).
        to eq('A sample UUID field or A sample email address field')
    end
  end

  describe '#construct_path' do
    it 'prepends relative url to info action' do
      expect(info.construct_path('4472831-bf66-4bc2-865f-e2c4c2b14c78')).
        to eq('/resource/4472831-bf66-4bc2-865f-e2c4c2b14c78')
    end

    it 'raises with missing args' do
      expect { info.construct_path }.to raise_error(ArgumentError)
    end

    it 'raises with unwanted args' do
     expect { info.construct_path('too', 'many', 'args') }.
        to raise_error(ArgumentError)
    end

    it 'returns relative url' do
      expect(update.construct_path('4472831-bf66-4bc2-865f-e2c4c2b14c78')).
        to eq('/resource/4472831-bf66-4bc2-865f-e2c4c2b14c78')
    end
  end
end
