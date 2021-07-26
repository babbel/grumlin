# frozen_string_literal: true

module Grumlin
  class Step < AnonymousStep
    attr_reader :client

    def initialize(client, name, *args, previous_steps: [])
      super(name, *args, previous_steps: previous_steps)
      @client = client
    end

    def next
      @enum ||= toList.to_enum
      @enum.next
    end

    def toList # rubocop:disable Naming/MethodName
      @toList ||= @client.write(*steps) # rubocop:disable Naming/VariableName
    end

    def iterate
      @client.write(*(steps + [nil]))
    end

    private

    def add_step(step_name, args, previous_steps:)
      self.class.new(@client, step_name, *args, previous_steps: previous_steps)
    end
  end
end
