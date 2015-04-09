module Atum
  module Core
    class Response
      def initialize(response)
        @response = response
      end

      def body
        json? ? json_body : raw_body
      end

      def status
        @response.status
      end

      def headers
        @response.headers
      end

      def json?
        content_type = @response.headers['Content-Type'] ||
                       @response.headers['content-type'] || ''
        content_type =~ %r{application/.*json}
      end

      def error?
        @response.status >= 400
      end

      def meta
        unless json?
          raise ResponseError, 'Cannot fetch meta for non JSON response'
        end

        json_body.fetch('meta', {})
      end

      def limit
        meta.fetch('limit', nil)
      end

      private

      def json_body
        @json_body ||= JSON.parse(@response.body).with_indifferent_access
      end

      def raw_body
        @response.body
      end
    end
  end
end
