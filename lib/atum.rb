require 'base64'
require 'erubis'
require 'faraday'
require 'json'
require 'uri'
require 'zlib'
require 'active_support/inflector'
require 'backports/2.0.0/enumerable/lazy.rb'

# Atum is an HTTP client for an API described by a JSON schema.
module Atum
end

require 'atum/version'
require 'atum/core'
require 'atum/generation'
