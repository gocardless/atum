module Atum
  module Schemas
    class ParameterChoice
      attr_reader :resource_name, :parameters

      def initialize(resource_name, parameters)
        @resource_name = resource_name
        @parameters = parameters
      end

      # A name created by merging individual parameter descriptions, suitable
      # for use in a function signature.
      def name
        @parameters.map do |parameter|
          if parameter.resource_name
            parameter.name
          else
            "#{@resource_name}_#{parameter.name}"
          end
        end.join('_or_')
      end

      # A description created by merging individual parameter descriptions.
      def description
        @parameters.map { |parameter| parameter.description }.join(' or ')
      end

      # A pretty representation of this instance.
      def inspect
        "ParameterChoice(parameters=#{@parameters})"
      end
    end
  end
end
