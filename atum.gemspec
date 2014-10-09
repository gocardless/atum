# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'atum/version'

Gem::Specification.new do |spec|
  spec.name          = 'atum'
  spec.version       = Atum::VERSION
  spec.authors       = %w(isaacseymour petehamilton)
  spec.email         = ['i.seymour@oxon.org', 'peterejhamilton@gmail.com']
  spec.description   = 'A Ruby client generator for JSON APIs described with a JSON schema'
  spec.summary       = 'A Ruby client generator for JSON APIs described with a JSON schema'
  spec.homepage      = 'https://github.com/gocardless/atum'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep('^(test|spec|features)/')
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'rubocop', '~> 0.26'
  spec.add_development_dependency 'guard', '~> 2.6'
  spec.add_development_dependency 'guard-rspec', '~> 4.3'
  spec.add_development_dependency 'guard-rubocop', '~> 1.1'
  spec.add_development_dependency 'webmock', '~> 1.18'
  spec.add_development_dependency 'pry-nav', '~> 0.2'
  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'appraisal', '~> 1.0.2'

  spec.add_dependency 'erubis', '~> 2.7'
  spec.add_dependency 'faraday', '>= 0.8.9'
  spec.add_dependency 'activesupport', '~> 4.1'
end
