require 'spec_helper'

describe Atum::Core::Resource do
  let(:method_name) { 'known_method' }
  let(:links) { { "#{method_name}" => nil } }
  let(:resource) { described_class.new(links) }
  let(:resource_schema) do
    Atum::Core::Schema::ApiSchema.new(SAMPLE_SCHEMA).resource_schema_for('resource')
  end

  describe '#respond_to?' do
    subject { resource.respond_to?(method_name) }

    context 'when a link for the method exists' do
      it { is_expected.to be_truthy }
    end

    context 'when a link is missing for the method' do
      let(:links) { {} }
      it { is_expected.to be_falsey }
    end
  end

  describe 'calling a method on the resource' do
    let(:args) { double }
    subject(:method) { -> { resource.send(method_name, args) } }

    context 'when a link for the method exists' do
      let(:link) { double(run: nil) }
      let(:links) { { "#{method_name}" => link } }

      it 'should send message :run to the link' do
        expect(link).to receive(:run).with(args)
        method.call
      end
    end

    context 'when a link is missing for the method' do
      let(:links) { {} }
      it { is_expected.to raise_error(NoMethodError) }
    end
  end

  # it 'raises on invalid link' do
  #   expect { resource.unknown }
  #     .to raise_error(NoMethodError,
  #                     "undefined method `unknown' for #<Atum::Core::Resource")
  # end

  # context 'when a link is available' do
  #   let(:link) do
  #     Atum::Core::Link.new('https://username:password@example.com',
  #                    schema_resource.link_schema('list'))
  #   end
  #   let(:params) { { 'list' => link } }
  #   let(:response_body) { { 'resources' => ['Hello, world!'] } }

  #   it 'gets the link' do
  #     stub_request(:get, 'https://username:password@example.com/resource')
  #       .to_return(status: 200, body: response_body.to_json,
  #                 headers: { 'Content-Type' => 'application/json' })

  #     expect(resource.list({})).to eq(['Hello, world!'])
  #   end
  # end
end
