module Atum
  # A resource with methods mapped to API links.
  class Resource
    # Instantiate a resource.
    #
    # @param links [Hash<String,Link>] A hash that maps method names to links.
    def initialize(links)
      @links = links
    end

    def respond_to?(name)
      @links.key?(name.to_s)
    end

    private

    # Find a link and run it.
    #
    # @param name [String] The name of the method to invoke.
    # @param parameters [Array] The arguments to pass to the method.  This
    #   should always be a `Hash` mapping parameter names to values.
    # @raise [NoMethodError] Raised if the name doesn't match a known link.
    # @return [String,Array,Hash] The response received from the server.  JSON
    #   responses are automatically decoded into Ruby objects.
    def method_missing(name, *parameters)
      super unless respond_to?(name)

      @links[name.to_s].run(*parameters)
    end
  end
end
