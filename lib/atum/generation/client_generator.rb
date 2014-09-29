module Atum
  module Generation
    class ClientGenerator
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

      # Returns a map from file name to contents
      def files
        base_files = {
          @module_name.underscore => generate_module,
          'client' => generate_client
        }

        resources.reduce(base_files) do |other_files, resource|
          other_files.merge(resource.name.underscore => generate_resource(resource))
        end
      end

      private

      class ErbContext < Erubis::Context
        def commentify(comment, tabs)
          starter = ("  " * tabs) + "# "
          max_line_length = 78 - (tabs * 2)
          comment.split("\n").
            map { |l| l.scan(/.{1,#{max_line_length}}/) }.
            flatten.map { |l| starter + l.strip }.join("\n")
        end

        def method(name, params)
          "#{name}" + (params.length > 0 ? "(#{params})" : "")
        end
      end

      def resources
        @schema.resources.map { |r| GeneratorResource.new(r) }
      end

      #############################
      # Generate individual files #
      #############################
      def generate_module
        module_template.evaluate(module_context)
      end

      def generate_client
        client_template.evaluate(client_context)
      end

      def generate_resource(resource)
        resource_template.evaluate(resource_context(resource))
      end

      #################################
      # Contexts for Erubis templates #
      #################################
      def shared_context
        c = ErbContext.new
        c[:module_name] = @module_name
        c
      end

      def module_context
        c = shared_context
        c[:default_headers] = @options.fetch(:default_headers, {})
        c[:schema] = JSON.dump(@schema.schema)
        c[:resources] = resources
        c
      end

      def client_context
        c = shared_context
        c[:description] = @schema.description
        c[:resources] = resources
        c
      end

      def resource_context(resource)
        c = shared_context
        c[:description] = resource.description
        c[:class_name] = resource.class_name
        c[:links] = resource.links
        c[:resource_name] = resource.name
        c
      end

      #####################
      # Template locators #
      #####################
      def module_template
        Erubis::Eruby.new(File.read(template_for('module')))
      end

      def client_template
        Erubis::Eruby.new(File.read(template_for('client')))
      end

      def resource_template
        @resource_template ||= Erubis::Eruby.new(
          File.read(template_for('resource')))
      end

      ##############################
      # Where templates are stored #
      ##############################
      def template_for(name)
        File.dirname(__FILE__) + "/views/#{name}.erb"
      end
    end
  end
end
