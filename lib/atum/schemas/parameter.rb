module Atum
  module Schemas
    class Parameter
      attr_reader :resource_name, :description

      def initialize(resource_name, name, description)
        @resource_name = resource_name
        @name = name
        @description = description || ''
      end

      # The name of the parameter, with the resource included, suitable for use
      # in a function signature.
      def name
        [@resource_name, @name].compact.join('_')
      end

      # A pretty representation of this instance.
      def inspect
        "Parameter(name=#{@name}, description=#{@description})"
      end
    end
  end
end
