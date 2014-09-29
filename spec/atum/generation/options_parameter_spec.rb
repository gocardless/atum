require 'spec_helper'

describe Atum::Generation::OptionsParameter do
  let(:name) { 'options' }
  let(:description) { 'any query parameters in the form of a hash' }
  subject(:parameter) { described_class.new }

  describe '#name' do
    subject { parameter.name }
    it { is_expected.to eq(name) }
  end

  describe '#description' do
    subject { parameter.description }
    it { is_expected.to eq(description) }
  end

  describe '#inspect' do
    subject { parameter.inspect }
    it { is_expected.to eq("Parameter(name=#{name}, description=#{description})") }
  end

  describe '#default' do
    subject { parameter.default }
    it { is_expected.to eq('{}') }
  end
end
