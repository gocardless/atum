require 'spec_helper'

describe Atum::Generation::GeneratorService do
  let(:module_name) { 'Fruity' }
  let(:schema_file) do
    File.expand_path('../../fixtures/fruity_schema.json', File.dirname(__FILE__))
  end
  let(:url) { 'http://api.fruity.com' }
  let(:options) { { path: File.join(tmp_folder, 'client') } }
  let(:generator_service) do
    described_class.new(module_name, schema_file, url, options)
  end

  def test_client_file(*args)
    File.file?(File.join(options[:path], 'fruity', *args))
  end

  describe '#generate_files' do
    let(:tmp_folder) do
      File.expand_path(File.join('..', '..', '..', 'tmp'), File.dirname(__FILE__))
    end
    before { FileUtils.mkdir_p options[:path] }

    it 'should create the required folders' do
      generator_service.generate_files
      expect(File.directory?(File.join(options[:path], 'fruity'))).to be_truthy
      expect(File.directory?(File.join(options[:path], 'fruity/resources'))).to be_truthy
    end

    it 'should create a root client file' do
      generator_service.generate_files
      expect(File.file?(File.join(options[:path], 'fruity', 'client.rb'))).to be_truthy
    end

    it 'should create resource files' do
      generator_service.generate_files
      expect(test_client_file('resources', 'lemon.rb')).to be_truthy
      expect(test_client_file('resources', 'lime.rb')).to be_truthy
    end
  end
end
