require 'spec_helper'

describe Atum::Core::Client do
  let(:client) { described_class.new({}, 'http://foo:bar@example.com') }

  describe '#inspect' do
    it 'should redact user password credentials' do
      expect(client.inspect).to include('url="http://foo:REDACTED@example.com"')
    end
  end

  describe '#unknown_resource' do
    let(:client) { described_class.new({}, 'http://example.com') }
    subject(:command) { -> { client.unknown_resource } }

    context 'without a matching resource' do
      it { is_expected.to raise_error(NoMethodError) }
    end
  end

  describe '.client_from_schema' do
    let(:schema) { Atum::Core::Schema::ApiSchema.new(SAMPLE_SCHEMA) }
    subject { described_class.client_from_schema(schema, 'https://example.com') }
    it { is_expected.to be_an(described_class) }
  end
end
