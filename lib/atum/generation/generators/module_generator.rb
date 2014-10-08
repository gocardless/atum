module Atum
  module Generation
    module Generators
      class ModuleGenerator < BaseGenerator
        TEMPLATE_NAME = 'module'

        def context
          c = super
          c[:default_headers] = @options.fetch(:default_headers, {})
          c[:schema] = JSON.dump(@schema.schema)
          c[:resources] = resources
          c
        end
      end
    end
  end
end
