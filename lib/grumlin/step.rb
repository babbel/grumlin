# frozen_string_literal: true

module Grumlin
  class Step < AnonymousStep
    attr_reader :client

    def initialize(pool, name, *args, previous_steps: [])
      super(name, *args, previous_steps: previous_steps)
      @pool = pool
    end

    def next
      @enum ||= toList.to_enum
      @enum.next
    end

    def toList # rubocop:disable Naming/MethodName
      @pool.acquire do |res|
        res.client.write(*steps)
      end
    end

    def iterate
      @pool.acquire do |res|
        res.client.write(*(steps + [nil]))
      end
    end

    private

    def add_step(step_name, args, previous_steps:)
      self.class.new(@pool, step_name, *args, previous_steps: previous_steps)
    end
  end
end
