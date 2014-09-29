module Atum
  module Generation
    class GeneratorResource
      def initialize(resource_schema)
        @resource_schema = resource_schema
      end

      # The name of the resource, in snake case.
      def name
        @resource_schema.name.gsub('-', '_')
      end

      # Description of the resource.
      def description
        @resource_schema.description
      end

      # Links available on this resource.
      def links
        @links ||= @resource_schema.link_schemas.map do |link_schema|
          GeneratorLink.new(link_schema)
        end
      end

      # The name of the resource class in generated code.
      def class_name
        name.camelcase
      end
    end
  end
end
