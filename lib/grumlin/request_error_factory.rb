# frozen_string_literal: true

class Grumlin::RequestErrorFactory
  ERRORS = {
    499 => Grumlin::InvalidRequestArgumentsError,
    500 => Grumlin::ServerError,
    597 => Grumlin::ScriptEvaluationError,
    599 => Grumlin::ServerSerializationError,
    598 => Grumlin::ServerTimeoutError,

    401 => Grumlin::ClientSideError,
    407 => Grumlin::ClientSideError,
    498 => Grumlin::ClientSideError
  }.freeze

  # Neptune presumably returns message as a JSON string of format
  # {"detailedMessage":"",
  #  "requestId":"UUID",
  #  "code":"ConcurrentModificationException"}
  # Currently we simply search for substrings to identify the exact error
  # TODO: parse json and use `code` instead

  VERTEX_ALREADY_EXISTS = "Vertex with id already exists:"
  EDGE_ALREADY_EXISTS = "Edge with id already exists:"

  CONCURRENT_VERTEX_INSERT_FAILED = "Failed to complete Insert operation for a Vertex due to conflicting concurrent"

  CONCURRENT_VERTEX_PROPERTY_INSERT_FAILED =
    "Failed to complete Insert operation for a VertexProperty due to conflicting concurrent"
  CONCURRENT_EDGE_PROPERTY_INSERT_FAILED =
    "Failed to complete Insert operation for a EdgeProperty due to conflicting concurrent"

  CONCURRENT_EDGE_INSERT_FAILED = "Failed to complete Insert operation for an Edge due to conflicting concurrent"
  CONCURRENCT_MODIFICATION_FAILED = "Failed to complete operation due to conflicting concurrent"

  class << self
    def build(request, response)
      status = response[:status]
      query = request[:request]

      if (error = ERRORS[status[:code]])
        return (
          already_exists_error(status) ||
          concurrent_modification_error(status) ||
          error
        ).new(status, query)
      end

      return unless Grumlin::RequestDispatcher::SUCCESS[status[:code]].nil?

      Grumlin::UnknownResponseStatus.new(status)
    end

    def already_exists_error(status)
      return Grumlin::VertexAlreadyExistsError if status[:message]&.include?(VERTEX_ALREADY_EXISTS)
      return Grumlin::EdgeAlreadyExistsError if status[:message]&.include?(EDGE_ALREADY_EXISTS)
    end

    def concurrent_modification_error(status) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return Grumlin::ConcurrentVertexInsertFailedError if status[:message]&.include?(CONCURRENT_VERTEX_INSERT_FAILED)
      if status[:message]&.include?(CONCURRENT_VERTEX_PROPERTY_INSERT_FAILED)
        return Grumlin::ConcurrentVertexPropertyInsertFailedError
      end
      return Grumlin::ConcurrentEdgeInsertFailedError if status[:message]&.include?(CONCURRENT_EDGE_INSERT_FAILED)
      if status[:message]&.include?(CONCURRENT_EDGE_PROPERTY_INSERT_FAILED)
        return Grumlin::ConcurrentEdgePropertyInsertFailedError
      end
      return Grumlin::ConcurrentModificationError if status[:message]&.include?(CONCURRENCT_MODIFICATION_FAILED)
    end
  end
end
