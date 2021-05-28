# frozen_string_literal: true

module Grumlin
  class Step < AnonymousStep
    attr_reader :client

    # TODO: add support for bytecode
    def initialize(client, name, *args, previous_steps: [])
      super(name, *args, previous_steps: previous_steps)
      @client = client
    end

    private

    def add_step(step_name, args, previous_steps:)
      self.class.new(@client, step_name, *args, previous_steps: previous_steps)
    end
  end
end
