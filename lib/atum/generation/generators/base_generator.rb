module Atum
  module Generation
    module Generators
      class BaseGenerator
        TEMPLATE_NAME = nil

        # Generate a static client that uses Atum under the hood.  This is a good
        # option if you want to ship a gem or generate API documentation using Yard.
        #
        # @param module_name [String] The name of the module, as rendered in a Ruby
        #   source file, to use for the generated client.
        # @param schema [Schema] The schema instance to generate the client from.
        # @param url [String] The URL for the API service.
        # @param options [Hash] Configuration for links.  Possible keys include:
        #   - default_headers: Optionally, a set of headers to include in every
        #     request made by the client.  Default is no custom headers.
        def initialize(module_name, schema, url, options)
          @module_name = module_name
          @schema = schema
          @url = url
          @options = options
        end

        def context
          ErbContext.new(context_hash.merge(module_name: @module_name))
        end

        def context_hash
          raise NotImplementedError, 'Subclasses must define context_hash'
        end

        def template
          @template ||= Erubis::Eruby.new(File.read(template_path))
        end

        def generate
          template.evaluate(context)
        end

        def resources
          @schema.resource_schemas.map { |r| GeneratorResource.new(r) }
        end

        private

        def template_path
          File.expand_path(File.join(File.dirname(__FILE__), 'views',
                                     "#{template_name}.erb"))
        end

        def template_name
          raise NotImplementedError, 'Subclasses must define template_name'
        end
      end
    end
  end
end
