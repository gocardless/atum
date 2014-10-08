require 'spec_helper'

describe Atum::Core::Schema::ParameterChoice do
  let(:param_1) { Atum::Core::Schema::Parameter.new('resource', 'id', 'foo') }
  let(:param_2) { Atum::Core::Schema::Parameter.new('resource', 'email', 'bar') }
  let(:param_3) { Atum::Core::Schema::Parameter.new(nil, 'token', 'baz') }

  let(:parameter_choice) { described_class.new('resource', parameters) }

  describe '#description' do
    let(:parameters) { [param_1, param_2, param_3] }
    subject { parameter_choice.description }

    it { is_expected.to eq('foo or bar or baz') }
  end

  describe '#inspect' do
    let(:parameters) { [param_1, param_2, param_3] }

    it 'should include each of the parameters' do
      expect(parameter_choice.inspect).to include(param_1.inspect)
      expect(parameter_choice.inspect).to include(param_2.inspect)
      expect(parameter_choice.inspect).to include(param_3.inspect)
    end
  end

  describe '#name' do
    subject { parameter_choice.name }

    context 'when both parameters have a resource name' do
      let(:parameters) { [param_1, param_2] }
      it { is_expected.to eq('resource_id_or_resource_email') }
    end

    context "when a parameter doesn't have a resource name" do
      let(:parameters) { [param_1, param_3] }
      it { is_expected.to eq('resource_id_or_resource_token') }
    end
  end
end
