module Atum
  module Generation
    class BodyParameter
      attr_reader :name, :description

      def initialize
        @name = 'body'
        @description = 'the object to pass as the request payload'
      end
    end
  end
end
