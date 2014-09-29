require 'spec_helper'

describe Atum::Core::Schema::Parameter do
  let(:name) { 'id' }
  let(:description) { 'The ID for the resource Yo!' }
  let(:resource_name) { 'resource' }
  subject(:parameter) { described_class.new(resource_name, name, description) }

  describe '#name' do
    subject { parameter.name }
    it { is_expected.to eq("#{resource_name}_#{name}") }
  end

  describe '#description' do
    subject { parameter.description }
    it { is_expected.to eq(description) }
  end

  describe '#inspect' do
    subject { parameter.inspect }
    it { is_expected.to include("#{resource_name}_#{name}") }
    it { is_expected.to include("#{description}") }
  end
end
