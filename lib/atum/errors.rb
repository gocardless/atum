module Atum
  # Raised when a schema has an error that prevents it from being parsed
  # correctly.
  class SchemaError < StandardError
  end

  class ApiError < StandardError
    attr_reader :error

    def initialize(error)
      @error = error
    end
  end
end
