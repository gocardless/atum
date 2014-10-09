module Atum
  module Generation
    module Generators
      class ModuleGenerator < BaseGenerator
        def context_hash
          { default_headers: @options.fetch(:default_headers, {}),
            schema: JSON.dump(@schema.schema),
            resources: resources }
        end

        def template_name
          'module'
        end
      end
    end
  end
end
