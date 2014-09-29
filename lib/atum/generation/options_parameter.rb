module Atum
  module Generation
    class OptionsParameter < Atum::Core::Schema::Parameter
      attr_reader :default

      def initialize
        super(nil, 'options', 'any query parameters in the form of a hash')
        @default = '{}'
      end
    end
  end
end
