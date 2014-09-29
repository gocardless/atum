module Atum
  module Schemas
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

      def description
        @definition['description']
      end

      def definitions
        @definition['definitions']
      end

      def properties
        @definition['properties']
      end

      # Get a schema for a named link.
      #
      # @param name [String] The name of the link.
      # @raise [SchemaError] Raised if an unknown link name is provided.
      def link_schema(name)
        schema = link_schemas[name]
        raise SchemaError.new("Unknown link '#{name}'.") unless schema
        schema
      end

      # The link schema children that are part of this resource schema.
      #
      # @return [Array<LinkSchema>] The link schema children.
      def links
        link_schemas.values
      end

      private

      def link_schemas
        @links ||=
          Hash[
            @definition['links'].map do |link|
              [link['title'].downcase.gsub(' ', '_'),
               LinkSchema.new(@schema, self, link)]
            end
          ]
      end
    end
  end
end
