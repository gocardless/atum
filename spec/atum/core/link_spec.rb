require 'spec_helper'

describe Atum::Core::Link do
  describe '.new' do
    let(:url) { 'http://example.com' }
    let(:link_schema) { double }
    let(:options) { {} }
    subject(:method) { -> { described_class.new(url, link_schema, options) } }

    shared_examples_for 'creating a Faraday instance' do
      it 'generates a new Faraday connection with the root url' do
        expect(Faraday).to receive(:new).with(url: 'http://example.com')
        method.call
      end
    end
  end

  describe '#run' do
    let(:url) { 'http://example.com' }
    let(:link_schema) { double(method: :get) }
    let(:options) { {} }
    let(:param_one) { double }
    let(:envelope_name) { double }
    let(:params) { [param_one, options] }
    let(:fake_request) { double }
    let(:fake_api_request) { double(request: fake_request) }
    let(:link) { described_class.new(url, link_schema, options) }

    before do
      allow(link_schema).to receive_message_chain(
        :resource_schema, :name, :pluralize).and_return(envelope_name)
      allow(Atum::Core::Request).to receive(:new).and_return(fake_api_request)
      allow(link_schema).to receive(:construct_path).and_return('/things')
    end

    context 'options' do
      let(:headers) { { foo: 'bar' } }
      let(:options) { { headers: headers } }

      before do
        allow(link).to receive(:default_options)
          .and_return(headers: { bish: 'bash' })
      end

      it 'deep merges the options' do
        expect(Atum::Core::Request).to receive(:new)
          .with(anything, anything, anything,
                hash_including(headers: { bish: 'bash', foo: 'bar' }))
        link.run(param_one, options)
      end

      context 'when user headers would clash with the defaults' do
        let(:headers) { { bish: 'bosh' } }
        it 'overrides the default headers with user headers' do
          expect(Atum::Core::Request).to receive(:new)
            .with(anything, anything, anything,
                  hash_including(headers: { bish: 'bosh' }))
          link.run(param_one, options)
        end
      end
    end

    context 'the passed http method' do
      let(:http_method) { double }
      before { allow(link_schema).to receive(:method).and_return(http_method) }
      it 'should be from the link schema' do
        expect(Atum::Core::Request).to receive(:new)
          .with(anything, http_method, anything, anything)
        link.run(param_one, options)
      end
    end

    context 'when the last parameter is not an options hash' do
      subject { -> { link.run(*params) } }
      let(:params) { [] }
      it { is_expected.to raise_error(ArgumentError) }
    end

  end
end
