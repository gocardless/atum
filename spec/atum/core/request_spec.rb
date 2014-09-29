require 'spec_helper'

describe Atum::Core::Request do
  let(:root_url) { 'http://example.com' }
  let(:path) { '/things' }
  let(:querystring) { '' }
  let(:full_path) { "#{root_url}#{path}#{querystring}" }
  let(:method) { :get }
  let(:connection) { Faraday.new(url: root_url) }
  let(:pre_processor) { nil }
  let(:headers) { {} }
  let(:body) { nil }
  let(:query) { {} }
  let(:options) do
    {
      headers: headers,
      body: body,
      query: query,
      envelope_name: 'things'
    }
  end
  subject(:requestor) { described_class.new(connection, method, path, options) }

  describe '#request' do
    let(:make_request) { -> { requestor.request } }
    before { stub }

    context 'passing headers' do
      let(:headers) { { 'Foo' => 'BarBaz' } }
      let(:stub) { stub_request(:get, full_path).with(headers: headers) }

      it 'works as expected' do
        make_request.call
        expect(stub).to have_been_requested
      end
    end

    context 'passing a body' do
      let(:method) { :post }
      let(:body) { { 'Foo' => 'BarBaz' } }
      let(:stub) { stub_request(:post, full_path).with(body: body) }

      it 'works as expected' do
        make_request.call
        expect(stub).to have_been_requested
      end
    end

    context 'passing a query' do
      let(:query) { { 'a' => 'b' } }
      let(:stub) { stub_request(:get, full_path).with(query: query) }

      it 'works as expected' do
        make_request.call
        expect(stub).to have_been_requested
      end
    end

    context 'when the response is not JSON' do
      let(:response) { 'ABCDEFGH' }
      let(:stub) do
        stub_request(:get, full_path)
          .with(query: query)
          .to_return(body: response,
                     headers: { 'Content-Type' => 'application/text' })
      end

      it 'returns the raw response' do
        expect(make_request.call).to eq(response)
      end
    end

    context 'when the response is json' do
      context 'and is not paginated' do
        let(:response_body) { { 'ABC' => 'DEF' } }
        let(:response) { { 'things' => response_body } }
        let(:stub) do
          stub_request(:get, full_path)
            .with(query: query)
            .to_return(body: response.to_json,
                       headers: { 'Content-Type' => 'application/json' })
        end

        it 'returns an unenveloped body' do
          expect(requestor).to receive(:unenvelope).with(response)
            .and_return(response_body)
          make_request.call
        end
      end

      context 'and is paginated' do
        let(:limit) { 50 }
        let(:response) { { 'things' => (0..limit).map { |i| "item_#{i}" } } }
        let(:stub) do
          stub_request(:get, full_path)
            .to_return(body: {
              resources: response,
              meta: {
                limit: limit, cursors: { before: 'beforeID', after: 'afterID' }
              }
            }.to_json, headers: { 'Content-Type' => 'application/json' })
        end

        it 'returns an Enumerator' do
          expect(make_request.call).to be_an(Enumerator)
        end
      end
    end
  end
end
