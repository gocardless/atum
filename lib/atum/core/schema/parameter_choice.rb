module Atum
  module Core
    module Schema
      class ParameterChoice
        attr_reader :resource_name, :parameters

        def initialize(resource_name, parameters)
          @resource_name = resource_name
          @parameters = parameters
        end

        def description
          @parameters.map(&:description).join(' or ')
        end

        def name
          @parameters.map do |parameter|
            if parameter.resource_name
              parameter.name
            else
              "#{@resource_name}_#{parameter.name}"
            end
          end.join('_or_')
        end
      end
    end
  end
end
