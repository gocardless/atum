require 'stringio'
require 'webmock'
require 'webmock/rspec'
require 'pry'
require_relative '../lib/atum'
WebMock.disable_net_connect!(allow_localhost: true)

# A simple JSON schema for testing purposes.
schema_file = File.expand_path('./fixtures/sample_schema.json',
                               File.dirname(__FILE__))
SAMPLE_SCHEMA = JSON.load(File.open(schema_file))
