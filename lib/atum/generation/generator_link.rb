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
          if @link_schema.needs_request_body?
            params << BodyParameter.new
          else
            params << OptionsParameter.new
          end
          params
        end
      end

      # The list of parameters to render in generated source code for the method
      # signature for the link.
      def parameter_names_with_defaults
        parameters.map do |param|
          s = param.name
          s += " = #{param.default}" if param.respond_to?(:default)
          s
        end.join(", ")
      end

      def parameter_names
        parameters.map(&:name).join(", ")
      end
    end
  end
end
