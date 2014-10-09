require 'spec_helper'

describe 'The Generated Client' do
  let(:name) { 'Fruity' }
  let(:schema_file) do
    File.expand_path('../fixtures/fruity_schema.json', File.dirname(__FILE__))
  end
  let(:url) { 'http://api.fruity.com/fruits' }
  let(:tmp_folder) do
    File.expand_path(File.join('..', '..', '..', 'tmp'), File.dirname(__FILE__))
  end
  let(:options) { { path: File.join(tmp_folder, 'client') } }
  let(:generator_service) do
    Atum::Generation::GeneratorService.new(name, schema_file, url, options)
  end

  before do
    generator_service.generate_files
    require File.join(options[:path], 'fruity')
    Fruity.connect('PASSWORD', user: 'USER_ID', url: url)
  end
  after { FileUtils.rm_rf(tmp_folder) }

  it 'should add Authorization headers' do
    stub = WebMock.stub_request(:get, "#{url}/lemon") do |args|
      expect(args[:headers]).to include('Authorization' => anything)
    end
    Fruity.lemon.list
    expect(stub).to have_been_requested
  end

  it 'can make get requests' do
    stub = WebMock.stub_request(:get, "#{url}/lemon")
    Fruity.lemon.list
    expect(stub).to have_been_requested
  end

  it 'can make get requests with url params' do
    lemon_id = 'MYLEMONID'
    stub = WebMock.stub_request(:get, "#{url}/lemon/#{lemon_id}")
    Fruity.lemon.info(lemon_id)
    expect(stub).to have_been_requested
  end

  it 'can make requests with custom headers' do
    headers = { 'Accept' => 'application/json', 'Api-Version' => '2014-09-01',
                'Content-Type' => 'application/json' }
    stub = WebMock.stub_request(:get, "#{url}/lemon") do |args|
      expect(args[:headers]).to include(headers)
    end
    Fruity.lemon.list(headers: headers)
    expect(stub).to have_been_requested
  end

  it 'passes through query params' do
    query = { 'size' => 'large' }
    stub = WebMock.stub_request(:get, "#{url}/lemon?size=large")
    Fruity.lemon.list(query: query)
    expect(stub).to have_been_requested
  end

  it 'can use href params and pass query params' do
    lemon_id = 'MYLEMONID'
    query = { 'size' => 'large' }
    stub = WebMock.stub_request(:get, "#{url}/lemon/#{lemon_id}?size=large")
    Fruity.lemon.info(lemon_id, query: query)
    expect(stub).to have_been_requested
  end

  it 'just returns non-json responses' do
    body = 'MYBODY'
    WebMock.stub_request(:get, "#{url}/lemon")
      .to_return(body: body, headers: { 'Content-Type' => 'application/text' })
    expect(Fruity.lemon.list).to eq(body)
  end

  it 'unenvelopes json api responses' do
    lemon_body = { 'lemon_uuid' => 'MYLEMONID' }
    lemon_id = 'MYLEMONID'
    WebMock.stub_request(:get, "#{url}/lemon/#{lemon_id}")
      .to_return(body: { 'lemons' => lemon_body }.to_json,
                 headers: { 'Content-Type' => 'application/json' })
    expect(Fruity.lemon.info(lemon_id)).to eq(lemon_body)
  end

  it 'can send raw POST bodies' do
    body = 'MYBODY'
    WebMock.stub_request(:post, "#{url}/lemon")
      .with(body: body)
    expect(Fruity.lemon.create(body: body))
  end

  it 'sends JSON when POST-ing a hash' do
    body = { size: 'large', is_ripe: true, date_picked: Time.now }
    WebMock.stub_request(:post, "#{url}/lemon")
      .with(body: body.to_json)
    expect(Fruity.lemon.create(body: body))
  end
end
