module Atum
  module Generation
    module Generators
      class ResourceGenerator < BaseGenerator
        def initialize(resource, *args)
          super(*args)
          @resource = resource
        end

        def context
          c = super
          c[:description] = @resource.description
          c[:class_name] = @resource.class_name
          c[:links] = @resource.links
          c[:resource_name] = @resource.name
          c
        end

        def template_name
          'resource'
        end
      end
    end
  end
end
