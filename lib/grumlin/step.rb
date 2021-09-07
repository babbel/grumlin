# frozen_string_literal: true

module Grumlin
  class Step < AnonymousStep
    attr_reader :client

    def initialize(pool, name, *args, previous_step: nil)
      super(name, *args, previous_step: previous_step)
      @pool = pool
    end

    def next
      @enum ||= toList.to_enum
      @enum.next
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

    private

    def add_step(step_name, args)
      self.class.new(@pool, step_name, *args, previous_step: self)
    end
  end
end
