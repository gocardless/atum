module Atum
  module Core
    module Schema
      class ApiSchema
        attr_reader :schema

        def initialize(schema)
          @schema = schema
        end

        # Description of the API
        def description
          @schema['description']
        end

        # Get the schema for a resource.
        #
        # @param name [String] The name of the resource.
        # @raise [SchemaError] Raised if an unknown resource name is provided.
        # @return ResourceSchema The resource schema for resource called name
        def resource_schema_for(name)
          unless resource_schema_hash.key?(name)
            raise SchemaError, "Unknown resource '#{name}'."
          end

          resource_schema_hash[name]
        end

        # @return [Array<ResourceSchema>] The resource schemata in this API.
        def resource_schemas
          resource_schema_hash.values
        end

        # Get a simple human-readable representation of this client instance.
        def inspect
          "#<Atum::ApiSchema description=\"#{description}\">"
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

        private

        def resource_schema_hash
          @resource_schema_hash ||=
            @schema['definitions'].each_with_object({}) do |(key, value), memo|
              memo[key] = ResourceSchema.new(self, value, key)
            end
        end
      end
    end
  end
end
