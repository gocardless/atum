module Atum
  module Generation
    module Generators
      class ResourceGenerator < BaseGenerator
        def initialize(resource, *args)
          super(*args)
          @resource = resource
        end

        def context_hash
          { description: @resource.description,
            class_name: @resource.class_name,
            links: @resource.links,
            resource_name: @resource.name }
        end

        def template_name
          'resource'
        end
      end
    end
  end
end
