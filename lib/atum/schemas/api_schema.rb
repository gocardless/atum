module Atum
  module Schemas
    class ApiSchema
      attr_reader :schema

      def initialize(schema)
        @schema = schema
        @resources = {}
        @schema['definitions'].each do |key, value|
          @resources[key] = ResourceSchema.new(self, value, key)
        end
      end

      # Description of the API
      def description
        @schema['description']
      end

      # Get the schema for a resource.
      #
      # @param name [String] The name of the resource.
      # @raise [SchemaError] Raised if an unknown resource name is provided.
      def resource(name)
        raise SchemaError, "Unknown resource '#{name}'." unless @resources.key?(name)

        @resources[name]
      end

      # @return [Array<ResourceSchema>] The resource schemata in this API.
      def resources
        @resources.values
      end

      # Get a simple human-readable representation of this client instance.
      def inspect
        "#<Atum::Schema description=\"#{description}\">"
      end

      alias_method :to_s, :inspect

      # Lookup a path in this schema.
      #
      # @param path [Array<String>] Array of keys, one for each to look up in
      #   the schema
      # @return [Object] Value at the specifed path in this schema.
      def lookup_path(*path)
        path.reduce(@schema) { |a, e| a[e] }
      end
    end
  end
end
