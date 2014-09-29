require 'spec_helper'

describe Atum::Core::Schema::LinkSchema do
  let(:schema) { Atum::Core::Schema::ApiSchema.new(SAMPLE_SCHEMA) }
  let(:resource) { schema.resource_schema_for('resource') }
  let(:list) { resource.link_schema_for('list') }
  let(:info) { resource.link_schema_for('info') }
  let(:identify) { resource.link_schema_for('identify_resource') }
  let(:create) { resource.link_schema_for('create') }
  let(:update) { resource.link_schema_for('update') }

  describe '#name' do
    it 'returns the name' do
      expect(list.name).to eq('list')
    end
  end

  describe '#description' do
    it 'returns the link description' do
      expect(list.description).to eq('Show all sample resources')
    end
  end

  describe '#method' do
    it 'returns the link method' do
      expect(list.method).to eq(:get)
    end
  end

  describe '#needs_request_body?' do
    subject { link_schema.needs_request_body? }

    context 'when link_schema has a schema' do
      let(:link_schema) { create }
      it { is_expected.to be_truthy }
    end

    context "when link_schema doesn't have a schema" do
      let(:link_schema) { list }
      it { is_expected.to be_falsey }
    end
  end

  describe '#parameters' do
    let(:parameters) { identify.parameters }

    it 'returns an array of parameters' do
      expect(parameters).to be_an(Array)
    end

    it 'returns the right number of parameters' do
      expect(parameters.length).to eq(1)
    end

    it 'gives parameters the right names' do
      expect(parameters.first.name)
        .to eq('resource_uuid_field_or_resource_email_field')
    end

    it 'gives parameters the right descriptions' do
      expect(parameters.first.description)
        .to eq('A sample UUID field or A sample email address field')
    end
  end

  describe '#construct_path' do
    subject(:method) { -> { info.construct_path(*args) } }

    context 'with valid args' do
      let(:args) { ['4472831-bf66-4bc2-865f-e2c4c2b14c78'] }
      it 'prepends a relative url to the action' do
        expect(method.call).to eq('/resource/4472831-bf66-4bc2-865f-e2c4c2b14c78')
      end
    end

    context 'with missing args' do
      let(:args) { [] }
      it { is_expected.to raise_error(ArgumentError) }
    end

    context 'with unwanted args' do
      let(:args) { %w(too many args) }
      it { is_expected.to raise_error(ArgumentError) }
    end

    it 'returns relative url' do
      expect(update.construct_path('4472831-bf66-4bc2-865f-e2c4c2b14c78'))
        .to eq('/resource/4472831-bf66-4bc2-865f-e2c4c2b14c78')
    end
  end
end
