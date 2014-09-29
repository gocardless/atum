require 'spec_helper'

describe Atum::Link do
  let(:api_schema) { Atum::Schemas::ApiSchema.new(SAMPLE_SCHEMA) }
  let(:resource_schema) { api_schema.resource('resource') }
  let(:link_schema) { resource_schema.link_schema(link_name) }
  let(:url) { 'https://example.com' }
  let(:options) { {} }
  let(:link) { described_class.new(url, link_schema, options) }

  let(:req_body) { nil }
  let(:response_status) { 200 }
  let(:stub) do
    stub_request(req_method, "#{url}/resource#{req_path}")
      .with(body: req_body)
      .to_return(
        status: response_status,
        body: response_body.to_json,
        headers: { 'Content-Type' => 'application/json' })
  end

  before { stub }

  let(:resource) do
    { 'date_field'    => '2014-09-02T13:43:01Z',
      'string_field'  => 'Hello I love strings',
      'boolean_field' => true,
      'uuid_field'    => '44724831-bf66-4bc2-865f-e2c4c2b14c78',
      'email_field'   => 'isaac@seymour.com' }
  end

  describe '#run' do
    subject(:run) { link.run(*params) }

    shared_examples_for 'GET requests' do
      let(:req_method) { :get }

      context "non paginated response" do
        context "without href params" do
          let(:link_name) { 'list' }
          let(:params) { nil }
          let(:req_path) { nil }
          let(:response_body) { { resources: [resource] } }
          it { is_expected.to eq([resource]) }
        end

        context 'with href params' do
          let(:link_name) { 'info' }
          let(:params) { ['44724831-bf66-4bc2-865f-e2c4c2b14c78'] }
          let(:req_path) { '/44724831-bf66-4bc2-865f-e2c4c2b14c78' }
          let(:response_body) { { resources: resource } }

          it { is_expected.to eq(resource) }
          it 'returns a hash with indifferent access' do
            expect(run[:date_field]).to eq(resource['date_field'])
          end
        end
      end

      context 'paginated response' do
        let(:link_name) { 'list' }
        let(:params) { [] }
        let(:req_path) { '' }
        let(:response_body) do
          { resources: (1..50).map { |_x| resource },
            meta: { limit: 50, cursors: { before: nil, after: 'afterID' } } }
        end

        let(:second_stub) do
          stub_request(req_method, "#{url}/resource#{req_path}")
            .with(query: hash_including(after: 'afterID'))
            .to_return(
              status: 200,
              body: { resources: (1..43).map { |_x| resource },
                      meta: { limit: 60,
                              cursors: { before: 'beforeID', after: 'afterID' }
                            }
                    }.to_json,
              headers: { 'Content-Type' => 'application/json' })
        end

        it 'returns 93 resources' do
          second_stub
          expect(run.count).to eq(93)
        end

        it 'only uses one call to fetch <= 50 resources' do
          expect(run.first(10).count).to eq(10)
          expect(run.take(50).last).to eq(resource)
        end

        context 'with href params' do
          pending 'this is also missing from the sample schema'
        end
      end

      context 'non JSON response' do
        let(:req_path) { '' }
        let(:link_name) { 'list' }
        let(:params) { [] }
        let(:stub) do
          stub_request(req_method, "#{url}/resource#{req_path}").to_return(
            status: 200,
            body: 'oh, this is plain text',
            headers: { 'Content-Type' => 'text/plain' })
        end

        it { is_expected.to eq('oh, this is plain text') }
      end
    end

    shared_examples_for 'POST requests' do
      let(:req_method) { :post }
      # Otherwise stub doesn't match :(
      let(:encoded_resource) { resource.merge(boolean_field: 'true') }

      pending 'should work'

      context "with a body" do
        let(:link_name) { 'create' }
        let(:params) { [{ resources: resource }] }
        let(:req_path) { '' }
        let(:req_body) { { resources: encoded_resource } }
        let(:response_body) { { resources: resource } }

        before { stub }

        it { is_expected.to eq(resource) }
      end

      context 'with a validation error' do
        let(:req_path) { '' }
        let(:link_name) { 'create' }
        let(:params) { [] }
        let(:response_status) { 422 }
        let(:response_body) do
          { error: {
            documentation_url: 'https://developer.gocardless.com/enterprise#validation_failed',
            message: 'Validation failed',
            code: 422,
            request_id: 'cf727ef-2414-26f3-78b3-89174bc275f40',
            errors: [{ message: 'must be a number', field: 'sort_code' },
                     { message: 'is the wrong length', field: 'sort_code' }]
          } }
        end

        it 'raises a ApiError' do
          expect { run }.to raise_error(Atum::ApiError)
        end
      end

<<<<<<< HEAD
      context 'non JSON response' do
        pending 'returns the raw response'
=======
      context "non JSON response" do
        let(:link_name) { 'create' }
        let(:params) { [{ resources: resource }] }
        let(:req_path) { '' }
        let(:req_body) { { resources: encoded_resource } }
        let(:response_body) { { resources: resource } }

        let(:stub) do
          stub_request(req_method, "#{url}/resource#{req_path}").to_return(
            status: 200,
            body: 'oh, this is plain text',
            headers: { 'Content-Type' => 'text/plain' })
        end

        it { is_expected.to eq('oh, this is plain text') }
>>>>>>> Spec a non JSON POST response
      end
    end

    context 'with invalid parameters' do
      let(:stub) { nil }
      context 'with additional params' do
        let(:link_name) { 'info' }
        let(:params) { ['44724831-bf66-4bc2-865f-e2c4c2b14c78', 'ooops'] }

        it 'raises ArgumentError' do
          expect { run }.to raise_error(ArgumentError)
        end
      end

      context 'with missing params' do
        let(:link_name) { 'info' }
        let(:params) { [] }

        it 'raises ArgumentError' do
          expect { run }.to raise_error(ArgumentError)
        end
      end

      context 'with extra params and a body' do
        let(:link_name) { 'create' }
        let(:params) { ['oooops', { resources: { im: 'a resource' } }] }

        it 'raises ArgumentError' do
          expect { run }.to raise_error(ArgumentError)
        end
      end

      context 'with missing params and a body' do
        let(:link_name) { 'update' }
        let(:params) { [{ resources: { im: 'a resource' } }] }

        it 'raises ArgumentError' do
          expect { run }.to raise_error(ArgumentError)
        end
      end
    end

    context 'on base domain' do
      it_behaves_like 'GET requests'
      it_behaves_like 'POST requests'
    end

    context 'on domain with path' do
      it_behaves_like 'GET requests'
      it_behaves_like 'POST requests'
    end
  end
end
