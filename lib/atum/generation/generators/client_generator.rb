module Atum
  module Generation
    module Generators
      class ClientGenerator < BaseGenerator
        def context_hash
          { description: @schema.description,
            resources: resources }
        end

        def template_name
          'client'
        end
      end
    end
  end
end
