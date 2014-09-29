module Atum
  module Core
    module Schema
      class LinkSchema
        attr_reader :resource_schema

        # @param api_schema [ApiSchema] The schema for the whole API
        # @param resource_schema [ResourceSchema] The schema of the resource this
        # link belongs to.
        # @param link_schema [Hash] The link's schema
        def initialize(api_schema, resource_schema, link_schema_hash)
          @api_schema = api_schema
          @resource_schema = resource_schema
          @link_schema_hash = link_schema_hash
        end

        def name
          @link_schema_hash['title'].downcase.gsub(' ', '_')
        end

        def description
          @link_schema_hash['description']
        end

        def method
          @link_schema_hash['method'].downcase.to_sym
        end

        def needs_request_body?
          @link_schema_hash.key?('schema')
        end

        # Get the parameters this link expects.
        #
        # @param parameters [Array] The names of the parameter definitions to
        #   convert to parameter names.
        # @return [Array<Parameter|ParameterChoice>] A list of parameter instances
        #   that represent parameters to be injected into the link URL.
        def parameters
          expected_params.map do |parameter|
            # URI decode parameters and strip the leading '{(' and trailing ')}'.
            parameter = URI.unescape(parameter[2..-3])
            generate_parameter(parameter)
          end
        end

        # Construct the URL and body for a call to this link
        #
        # @param params [Array] The list of parameters to inject into the
        #   path.
        # @raise [ArgumentError] Raised if either too many or too few parameters
        #   were provided.
        # @return [String,Object] A path and request body pair.  The body value is
        #   nil if a payload wasn't included in the list of parameters.
        def construct_path(*params)
          if expected_params.count != params.count
            raise ArgumentError, "Wrong number of arguments: #{params.count} " \
                                 "for #{expected_params.count}"
          end

          href.gsub(PARAMETER_REGEX) { |_match| format_parameter(params.shift) }
        end

        private

        # Match parameters in definition strings.
        PARAMETER_REGEX = /\{\([%\/a-zA-Z0-9_-]*\)\}/

        def href
          @link_schema_hash['href']
        end

        def expected_params
          href.scan(PARAMETER_REGEX)
        end

        # Unpack an 'anyOf' or 'oneOf' multi-parameter blob.
        #
        # @param parameters [Array<Hash>] An array of hashes containing '$ref'
        #   keys and definition values.
        # @return [Array<Parameter>] An array of parameters extracted from the
        #   blob.
        def unpack_multi_params(parameters)
          parameters.map { |info| generate_parameter(info['$ref']) }
        end

        def generate_parameter(param)
          path = param.split('/')[1..-1]
          name = path[-1]
          resource_name = path.size > 2 ? path[1] : nil
          info = @api_schema.lookup_path(*path)
          description = info['description']

          if info.key?('anyOf')
            ParameterChoice.new(resource_name, unpack_multi_params(info['anyOf']))
          elsif info.key?('oneOf')
            ParameterChoice.new(resource_name, unpack_multi_params(info['oneOf']))
          else
            Parameter.new(resource_name, name, description)
          end
        end

        # Convert a path parameter to a format suitable for use in a path.
        #
        # @param [Fixnum,String,TrueClass,FalseClass,Time] The parameter to format.
        # @return [String] The formatted parameter.
        def format_parameter(parameter)
          parameter.instance_of?(Time) ? iso_format(parameter) : parameter.to_s
        end

        # Convert a time to an ISO 8601 combined data and time format.
        #
        # @param time [Time] The time to convert to ISO 8601 format.
        # @return [String] An ISO 8601 date in `YYYY-MM-DDTHH:MM:SSZ` format.
        def iso_format(time)
          time.getutc.iso8601
        end
      end
    end
  end
end
