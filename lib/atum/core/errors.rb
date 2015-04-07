module Atum
  module Core
    class SchemaError < StandardError; end

    class ResponseError < StandardError; end

    class ApiError < StandardError
      attr_reader :request, :response

      def initialize(request: request, response: response)
        @request = request
        @response = response
        @error = error
      end

      def error
        @error ||=
          if response.json?
            response.body['error']
          else
            {
              'message' => "Something went wrong with this raw request\n" \
              "status: #{response.status}\n" \
              "headers: #{response.headers}\n" \
              "body: #{response.body}"
            }
          end
      end

      def message
        return "Unknown error: #{response.body}" unless error
        if error.key?('documentation_url')
          "#{error['message']}, see #{error['documentation_url']}"
        else
          "#{error['message']}"
        end
      end
    end
  end
end
