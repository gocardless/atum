module Atum
  module Generation
    class OptionsParameter
      attr_reader :name, :description, :default

      def initialize
        @name = 'options'
        @description = 'any query parameters in the form of a hash'
        @default = '{}'
      end
    end
  end
end
