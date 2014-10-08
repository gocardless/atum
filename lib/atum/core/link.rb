require 'time'
require 'active_support/inflector'
require 'active_support/core_ext/hash/indifferent_access'

module Atum
  module Core
    # A link invokes requests with an HTTP server.
    class Link
      # The amount limit is increased on each successive fetch in pagination
      LIMIT_INCREMENT = 50

      # Instantiate a link.
      #
      # @param url [String] The URL to use when making requests.  Include the
      #   username and password to use with HTTP basic auth.
      # @param link_schema [LinkSchema] The schema for this link.
      # @param options [Hash] Configuration for the link.  Possible keys
      #   include:
      #   - default_headers: Optionally, a set of headers to include in every
      #     request made by the client.  Default is no custom headers.
      def initialize(url, link_schema, options = {})
        root_url, @path_prefix = unpack_url(url)
        @connection = Faraday.new(url: root_url)
        @link_schema = link_schema
        @headers = options[:default_headers] || {}
      end

      # Make a request to the server.
      #
      # @param parameters [Array] The list of parameters to inject into the
      #   path.  A request body can be passed as the final parameter and will
      #   always be converted to JSON before being transmitted.
      # @raise [ArgumentError] Raised if either too many or too few parameters
      #   were provided.
      # @return [String,Object,Enumerator] A string for text responses, an
      #   object for JSON responses, or an enumerator for list responses.
      def run(*parameters)
        options = parameters.pop
        raise ArgumentError, 'options must be a hash' unless options.is_a?(Hash)

        options = default_options.deep_merge(options)
        path = build_path(*parameters)
        Request.new(@connection, @link_schema.method, path, options).request
      end

      private

      def default_options
        {
          headers: @headers,
          envelope_name: @link_schema.resource_schema.name.pluralize
        }
      end

      def build_path(*parameters)
        path = @link_schema.construct_path(*parameters)
        path = "#{@path_prefix}#{path}" unless @path_prefix == '/'
        path
      end

      def apply_link_schema(hash)
        definitions = @link_schema.resource_schema.definitions
        hash.each do |k, v|
          next unless definitions.fetch(k, {}).fetch('format', nil)
          case definitions[k]['format']
          when 'date-time'
            hash[k] = Time.parse(v) unless v.nil?
          end
        end
        hash
      end

      def unpack_url(url)
        [URI.join(url, '/').to_s, URI.parse(url).path]
      end
    end
  end
end
