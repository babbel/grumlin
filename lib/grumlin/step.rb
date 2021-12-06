# frozen_string_literal: true

module Grumlin
  class Step < AnonymousStep
    attr_reader :client

    def initialize(pool, name, *args, configuration_steps: [], previous_step: nil)
      super(name, *args, previous_step: previous_step, configuration_steps: configuration_steps)
      @pool = pool
    end

    def next
      to_enum.next
    end

    def hasNext # rubocop:disable Naming/MethodName
      to_enum.peek
      true
    rescue StopIteration
      false
    end

    def to_enum
      @to_enum ||= toList.to_enum
    end

    def toList
      @pool.acquire do |client|
        client.write(bytecode)
      end
    end

    def iterate
      @pool.acquire do |client|
        client.write(bytecode(no_return: true))
      end
    end

    def step(step_name, args)
      self.class.new(@pool, step_name, *args, previous_step: self, configuration_steps: @configuration_steps)
    end
  end
end
