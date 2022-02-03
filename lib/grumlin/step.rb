# frozen_string_literal: true

module Grumlin
  class Step < AnonymousStep
    attr_reader :client

    def initialize(pool, name, *args, configuration_steps: [], first_step: nil, **params)
      super(name, *args, first_step: first_step, configuration_steps: configuration_steps, **params)
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

    def step(step_name, *args, **params)
      @next_step = self.class.new(@pool, step_name, *args, first_step: @first_step, **params)
    end
  end
end
