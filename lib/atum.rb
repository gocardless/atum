require 'base64'
require 'erubis'
require 'faraday'
require 'json'
require 'uri'
require 'zlib'
require 'active_support/inflector'

# Atum is an HTTP client for an API described by a JSON schema.
module Atum
end

require 'atum/version'
require 'atum/errors'
require 'atum/naming'
require 'atum/link'
require 'atum/resource'
require 'atum/client'

require 'atum/schemas'
require 'atum/generation'
