module Atum
  module Core
    # A resource with methods mapped to API links.
    class Resource
      # Instantiate a resource.
      #
      # @param links [Hash<String,Link>] A hash that maps method names to links.
      def initialize(links)
        links.each do |name, link|
          define_singleton_method(name) { |*args| link.run(*args) }
        end
      end
    end
  end
end
