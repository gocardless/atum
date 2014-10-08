module Atum
  module Generation
    module Generators
      class ClientGenerator < BaseGenerator
        TEMPLATE_NAME = 'client'

        def context
          c = super
          c[:description] = @schema.description
          c[:resources] = resources
          c
        end
      end
    end
  end
end
