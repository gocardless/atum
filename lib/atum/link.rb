require 'active_support/inflector'
require 'active_support/core_ext/hash/indifferent_access'

module Atum
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
    #     Default is no caching.
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
      payload = @link_schema.needs_request_body? ? parameters.pop : {}

      path = @link_schema.construct_path(*parameters)
      path = "#{@path_prefix}#{path}" unless @path_prefix == '/'

      make_request(path, payload)
    end

    private

    def do_request(path, payload)
      @connection.send(@link_schema.method, path, payload, @headers)
    end

    def make_request(path, payload)
      # TODO: rip this function into a class, path as an instance variable
      response = do_request(path, payload)
      if response_is_error?(response)
        parse_error(response)
      elsif response_is_json?(response)
        body = parse_response_body(response)
        limit = body.fetch('meta', {}).fetch('limit', nil)
        if limit.nil?
          apply_link_schema(unenvelope(body))
        else
          pagination_enumerator(response, path, payload)
        end
      else
        response.body
      end
    end

    def pagination_enumerator(initial_response, path, payload)
      response = initial_response
      Enumerator.new do |yielder|
        loop do
          body = parse_response_body(response)
          meta = body.fetch('meta', {})
          limit = meta.fetch('limit', nil)

          body = unenvelope(body)
          body.each { |item| yielder << apply_link_schema(item) }

          break if body.count < limit

          response = do_request(path, payload.merge(
            after: meta['cursors']['after'],
            limit: limit + LIMIT_INCREMENT
          ))
        end
      end
    end

    def apply_link_schema(hash)
      definitions = @link_schema.resource_schema.definitions
      hash.each do |k, v|
        next unless definitions.key?(k) && definitions[k].key?('format')
        case definitions[k]['format']
        when 'date-time' then hash[k] = Time.parse(v)
        end
      end
      hash
    end

    def response_is_json?(response)
      response.headers.fetch('Content-Type', '').include?('application/json')
    end

    def response_is_error?(response)
      response.status >= 400
    end

    def parse_response_body(response)
      JSON.parse(response.body).with_indifferent_access
    end

    def parse_error(response)
      error = parse_response_body(response)['error']
      raise Atum::ApiError, error
    end

    def unenvelope(body)
      body[@link_schema.resource_name.pluralize] || body['data']
    end

    def unpack_url(url)
      uri = URI.parse(url)
      [url.gsub(uri.path, ''), uri.path]
    end
  end
end
