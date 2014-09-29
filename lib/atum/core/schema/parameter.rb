module Atum
  module Core
    module Schema
      class Parameter
        attr_reader :resource_name

        def initialize(resource_name, name, description)
          @resource_name = resource_name
          @name = name
          @description = description
        end

        def name
          [@resource_name, @name].compact.join('_')
        end

        def description
          @description || ''
        end

        def inspect
          "Parameter(name=#{name}, description=#{description})"
        end
      end
    end
  end
end
