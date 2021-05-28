# frozen_string_literal: true

module Grumlin
  class Traversal
    attr_reader :connection

    def initialize(client_or_url)
      @client = if client_or_url.is_a?(String)
                  Grumlin::Client.new(client_or_url)
                else
                  client_or_url
                end
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
