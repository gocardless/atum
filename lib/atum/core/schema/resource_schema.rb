module Atum
  module Core
    module Schema
      class ResourceSchema
        attr_reader :name

        # Instantiate a resource schema.
        #
        # @param schema [ApiSchema] The whole document's schema
        # @param name [String] The name of the resource to identify in the schema.
        def initialize(schema, definition, name)
          @schema = schema
          @name = name
          @definition = definition
        end

        %w(description definitions properties).each do |key|
          define_method(key) { @definition[key] }
        end

        # Get a schema for a named link.
        #
        # @param name [String] The name of the link.
        # @raise [SchemaError] Raised if an unknown link name is provided.
        def link_schema_for(name)
          link_schema = link_schema_hash[name]
          raise SchemaError, "Unknown link '#{name}'." unless link_schema
          link_schema
        end

        # The link schema children that are part of this resource schema.
        #
        # @return [Array<LinkSchema>] The link schema children.
        def link_schemas
          link_schema_hash.values
        end

        private

        def link_schema_hash
          @link_schema_hash ||=
            @definition['links'].each_with_object({}) do |link, memo|
              memo[link['title'].downcase.gsub(' ', '_')] =
                LinkSchema.new(@schema, self, link)
            end
        end
      end
    end
  end
end
