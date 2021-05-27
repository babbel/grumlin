# frozen_string_literal: true

module Grumlin
  class TraversingContext
    ID = { :@type => "g:T", :@value => "id" }.freeze

    attr_reader :g

    def initialize(traversal)
      @g = traversal
    end

    def id
      ID
    end
  end
end
