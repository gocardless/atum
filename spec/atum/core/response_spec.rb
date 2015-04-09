require 'spec_helper'

describe Atum::Core::Response do
  let(:response) { anything }
  let(:api_response) { described_class.new(response) }

  describe '#body' do
    subject(:body) { api_response.body }

    context 'when the response is a simple json type' do
      let(:response_body) { { name: 'thing', description: 'awesome thing' } }
      let(:response) do
        double(headers: { 'Content-Type' => 'application/json' },
               body: { 'thing' => response_body }.to_json,
               status: 200)
      end

      it { is_expected.to be_a(Hash) }
    end

    context 'when the response is a custom json type' do
      let(:response_body) { { name: 'thing', description: 'awesome thing' } }
      let(:response) do
        double(headers: { 'Content-Type' => 'application/vnd.api+json' },
               body: { 'thing' => response_body }.to_json,
               status: 200)
      end

      it { is_expected.to be_a(Hash) }
    end

    context 'when the response is not json' do
      let(:response_body) { 'FOOBARBAZ' }
      let(:response) do
        double(headers: { 'Content-Type' => 'application/text' },
               body: 'FOOBARBAZ', status: 200)
      end

      it 'should come through raw' do
        expect(body).to eq(response_body)
      end
    end
  end

  describe '#json?' do
    subject { api_response.json? }

    let(:response) { double(headers: { 'Content-Type' => content_type }) }

    context 'when the response is json' do
      let(:content_type) { 'application/json' }
      it { is_expected.to be_truthy }
    end

    context 'when the response is not json' do
      let(:content_type) { 'application/text' }
      it { is_expected.to be_falsey }
    end
  end

  describe 'error?' do
    subject { api_response.error? }

    let(:response) { double(status: status) }

    context 'when the response is an error' do
      let(:status) { 401 }
      it { is_expected.to be_truthy }
    end

    context 'when the response is not an error' do
      let(:status) { 200 }
      it { is_expected.to be_falsey }
    end
  end

  shared_examples_for 'it needs the response to be json' do
    context 'when the response is not json' do
      before { allow(api_response).to receive(:json?) { false } }
      it { is_expected.to raise_error(Atum::Core::ResponseError) }
    end
  end

  describe 'meta' do
    subject(:method) { -> { api_response.meta } }

    it_behaves_like 'it needs the response to be json'

    context 'when the response is json' do
      before do
        allow(api_response).to receive(:json?) { true }
        allow(api_response).to receive(:json_body) { body }
      end
      subject { method.call }
      let(:meta) { double }

      context 'when meta is present' do
        let(:body) { { 'meta' => meta } }
        it { is_expected.to eq(meta) }
      end

      context 'when meta is not present' do
        let(:body) { {} }
        it { is_expected.to eq({}) }
      end
    end
  end

  describe 'limit' do
    subject(:method) { -> { api_response.limit } }

    it_behaves_like 'it needs the response to be json'

    context 'when the response is json' do
      before do
        allow(api_response).to receive(:json?) { true }
        allow(api_response).to receive(:json_body) { body }
      end
      subject { method.call }
      let(:limit) { double }

      context 'and limit is present' do
        let(:body) { { 'meta' => { 'limit' => limit } } }
        it { is_expected.to eq(limit) }
      end

      context 'and limit is not present' do
        let(:body) { { 'meta' => {} } }
        it { is_expected.to eq(nil) }
      end

      context 'and meta is not present' do
        let(:body) { {} }
        it { is_expected.to eq(nil) }
      end
    end
  end
end
