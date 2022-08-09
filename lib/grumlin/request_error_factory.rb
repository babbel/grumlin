# frozen_string_literal: true

module Grumlin
  class RequestErrorFactory
    ERRORS = {
      499 => InvalidRequestArgumentsError,
      500 => ServerError,
      597 => ScriptEvaluationError,
      599 => ServerSerializationError,
      598 => ServerTimeoutError,

      401 => ClientSideError,
      407 => ClientSideError,
      498 => ClientSideError
    }.freeze

    # Neptune presumably returns message as a JSON string of format
    # {"detailedMessage":"",
    #  "requestId":"UUID",
    #  "code":"ConcurrentModificationException"}
    # Currencly we simply search for substings to identify the exact error
    # TODO: parse json and use `code` instead
    VERTEX_ALREADY_EXISTS = "Vertex with id already exists:"
    EDGE_ALREADY_EXISTS = "Edge with id already exists:"
    CONCURRENT_VERTEX_INSERT_FAILED = "Failed to complete Insert operation for a Vertex due to conflicting concurrent"
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

        return unless RequestDispatcher::SUCCESS[status[:code]].nil?

        UnknownResponseStatus.new(status)
      end

      def already_exists_error(status)
        return VertexAlreadyExistsError if status[:message]&.include?(VERTEX_ALREADY_EXISTS)
        return EdgeAlreadyExistsError if status[:message]&.include?(EDGE_ALREADY_EXISTS)
      end

      def concurrent_modification_error(status)
        return ConcurrentVertexInsertFailedError if status[:message]&.include?(CONCURRENT_VERTEX_INSERT_FAILED)
        return ConcurrentEdgeInsertFailedError if status[:message]&.include?(CONCURRENT_EDGE_INSERT_FAILED)
        return ConcurrentModificationError if status[:message]&.include?(CONCURRENCT_MODIFICATION_FAILED)
      end
    end
  end
end
