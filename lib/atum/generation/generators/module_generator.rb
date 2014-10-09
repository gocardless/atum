module Atum
  module Generation
    module Generators
      class ModuleGenerator < BaseGenerator
        def context
          c = super
          c[:default_headers] = @options.fetch(:default_headers, {})
          c[:schema] = JSON.dump(@schema.schema)
          c[:resources] = resources
          c
        end

        def template_name
          'module'
        end
      end
    end
  end
end
