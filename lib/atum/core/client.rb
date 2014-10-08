module Atum
  module Core
    class Client
      class << self
        # Create an HTTP client from a schema.
        #
        # @param schema [ApiSchema] The schema to build an HTTP client for.
        # @param url [String] The URL the generated client should use
        # @param options [Hash] Configuration for links. Possible keys include:
        #   - default_headers: Optionally, a set of headers to include in every
        #     request made by the client.  Default is no custom headers.
        # @return [Client] A client with resources and links from the schema
        def client_from_schema(api_schema, url, options = {})
          resources = {}
          api_schema.resource_schemas.each do |resource_schema|
            links_hash = {}
            resource_schema.link_schemas.each do |link_schema|
              links_hash[link_schema.name] = Link.new(url, link_schema, options)
            end
            resources[resource_schema.name] = Resource.new(links_hash)
          end

          new(resources, url)
        end
      end

      # @param resources [Hash<String,Resource>] Methods names -> Resources
      # @param url [String] The URL used by this client.
      def initialize(resources, url)
        @resources = resources
        @url = url
      end

      def method_missing(method)
        unless respond_to?(method)
          raise NoMethodError, "resource `#{method}' doesn't exist for #{self}"
        end

        get_resource(method.to_s)
      end

      def respond_to?(method)
        @resources.key?(method.to_s)
      end

      def inspect
        url = URI.parse(@url)
        url.password = 'REDACTED' unless url.password.nil?
        "#<Atum::Client url=\"#{url}\">"
      end

      alias_method :to_s, :inspect

      private

      # @param name [String] The name of the resource to find.
      # @raise [NoMethodError] Raised if the name doesn't match a known resource.
      # @return [Resource] The resource matching the name.
      def get_resource(name)
        @resources[name]
      end
    end
  end
end
