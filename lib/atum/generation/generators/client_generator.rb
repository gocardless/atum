module Atum
  module Generation
    module Generators
      class ClientGenerator < BaseGenerator
        def context
          c = super
          c[:description] = @schema.description
          c[:resources] = resources
          c
        end

        def template_name
          'client'
        end
      end
    end
  end
end
