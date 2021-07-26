# frozen_string_literal: true

module Grumlin
  class Traversal
    attr_reader :connection

    def initialize(client = Grumlin.config.default_client)
      @client = client
    end

    # TODO: add other start steps
    %w[addV addE V E].each do |step|
      define_method step do |*args|
        Step.new(@client, step, *args)
      end
    end

    alias addVertex addV
    alias addEdge addE
  end
end
