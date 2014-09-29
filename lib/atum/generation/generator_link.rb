module Atum
  module Generation
    class GeneratorLink
      def initialize(link_schema)
        @link_schema = link_schema
      end

      def name
        @link_schema.name
      end

      def description
        @link_schema.description
      end

      def parameters
        @parameters ||= begin
          params = @link_schema.parameter_details
          params << BodyParameter.new if @link_schema.needs_request_body?
          params
        end
      end

      # The list of parameters to render in generated source code for the method
      # signature for the link.
      def parameter_names
        parameters.map(&:name).join(', ')
      end
    end
  end
end
