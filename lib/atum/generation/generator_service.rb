require 'fileutils'

module Atum
  module Generation
    class GeneratorService
      def initialize(module_name, schema_file, url, options)
        @module_name = module_name
        @schema = schema_from_file(schema_file)
        @url = url
        @options = options
      end

      def generate_files
        generate_namespace_folder
        generated_files.each do |gf|
          File.open("#{gf.path}.rb", 'w') do |f|
            f.write(gf.generator.generate)
          end
        end
      end

      private

      def schema_from_file(file)
        Atum::Core::Schema::ApiSchema.new(JSON.parse(File.read(file)))
      end

      def generate_namespace_folder
        FileUtils.mkdir_p namespace_path
        FileUtils.mkdir_p File.join(namespace_path, 'resources')
      end

      def resources
        @schema.resource_schemas.map { |r| GeneratorResource.new(r) }
      end

      def generated_files
        files = []

        files << GeneratedFile.new(namespace_path,
                                   Generators::ModuleGenerator.new(*generator_args))

        files << GeneratedFile.new(File.join(namespace_path, 'client'),
                                   Generators::ClientGenerator.new(*generator_args))

        resources.each do |resource|
          files << GeneratedFile.new(
            File.join(namespace_path, 'resources', resource.name.underscore),
            Generators::ResourceGenerator.new(resource, *generator_args))
        end

        files
      end

      def namespace
        @module_name.downcase.underscore
      end

      def namespace_path
        s = []
        s << @options[:path] if @options.key?(:path)
        s << namespace
        File.join(*s)
      end

      def generator_args
        [@module_name, @schema, @url, @options]
      end

      class GeneratedFile < Struct.new(:path, :generator); end
    end
  end
end
