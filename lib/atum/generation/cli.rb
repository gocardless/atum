require 'thor'
require 'yaml'
require 'fileutils'

# rubocop:disable Metrics/ClassLength
module Atum
  module Generation
    class CLI < Thor
      desc 'new <client_name>', 'create a new client gem'
      def new(client_name)
        # Generate a basic gem
        run_command("bundle gem #{client_name}")

        # Add atum to the gemspec file
        run_command("sed -i '$ d' #{client_name}/#{client_name}.gemspec")
        run_command("echo '\n  spec.add_runtime_dependency \"atum\", " \
                    "\"~> #{Atum::VERSION}\"' >> " \
                    "#{client_name}/#{client_name}.gemspec")
        run_command("echo 'end' >> #{client_name}/#{client_name}.gemspec")

        # Populate a .atum file in the root
        Dir.chdir(client_name) do
          File.open('.atum.yml', 'w') do |f|
            names = name_versions(client_name)
            f.puts "gem_name: #{client_name}"
            f.puts "constant_name: #{names[:constant_name]}"
          end
        end
      end

      desc 'generate', 'generate the atum client in a lib directory'
      option :default_headers,
             aliases: '-H',
             desc: 'A comma separated list of headers, ' \
                   'e.g. Api-Version: 2010-10-03, Accept-Language: Fr',
             type: 'array'
      option :constant_name, desc: 'e.g. FruityApi'
      option :file
      option :url
      option :gem_name
      option :commit, type: :boolean,
                      desc: 'Automatically commit the generated code'
      def generate
        config = options_from_atum_file.merge(options)
        validate_config(config)

        names = name_versions(config['gem_name'])
        config['constant_name'] ||= names[:constant_name]

        # Preserve the version file
        version_file = File.join('lib', names[:namespaced_path], 'version.rb')
        version_file_content = File.read(version_file)

        # Nuke everything in the lib folder
        FileUtils.rm_rf('lib/*')

        # Regenerate everything in the lib folder
        regenerate_lib_folder(config)

        # Re-write the version file
        File.open(version_file, 'w') { |f| f.write(version_file_content) }

        # Print advice
        print_closing_message
      end

      desc 'version', 'print Atum version'
      def version
        print Atum::VERSION, "\n"
      end

      no_commands do

        def options_from_atum_file
          File.file?('.atum.yml') ? YAML.load_file('.atum.yml') : {}
        end

        def validate_config(config)
          common = ' (either in .atum.yml or via cli options)'
          begin
            raise 'gem_name must be given' + common unless config.key?('gem_name')
            raise 'file must be given' + common unless config.key?('file')
            raise 'url must be given' + common unless config.key?('url')
          rescue => e
            message "Error: #{e.message}\n"
            help(:generate)
            exit
          end
        end

        def parse_headers(hs)
          Hash[hs.map { |header| header.split(':').map(&:strip) }]
        end

        def message(msg = nil)
          print "#{msg}\n"
        end

        def run_command(cmd)
          system(cmd)
        end

        def regenerate_lib_folder(config)
          Dir.chdir('lib') do
            Atum::Generation::GeneratorService.new(
              config['constant_name'], config['file'], config['url'],
              default_headers: parse_headers(config['default_headers'])
            ).generate_files
          end
        end

        def print_closing_message
          message "Successfully regenerated with atum v#{Atum::VERSION})\n"
          timestamp = Time.now.utc.iso8601
          cmd = "git add . -A && git commit -am 'Regenerated client on " \
                "#{timestamp} (atum v#{Atum::VERSION})'"

          if options['commit']
            message 'Staging files and committing changes...'
            system(cmd)
          else
            message "We suggest you now run:\n"
            message "\t#{cmd}\n"
            message 'Or, run the command with the --commit flag to do this automatically'
          end
        end

        def name_versions(name)
          constant_name = name.split('_').map { |p| p[0..0].upcase + p[1..-1] }.join
          if constant_name =~ /-/
            constant_name = constant_name
                            .split('-')
                            .map { |q| q[0..0].upcase + q[1..-1] }
                            .join('::')
          end

          { underscored_name: name.tr('-', '_'),
            namespaced_path: name.tr('-', '/'),
            constant_name: constant_name,
            constant_array: constant_name.split('::') }
        end
      end
    end
  end
end
