# frozen_string_literal: true

module Grumlin
  class Action < Steppable
    attr_reader :name, :args, :params, :next_step, :configuration_steps, :previous_step, :shortcut

    # client is only used when a traversal is a part of transaction
    def initialize(name, args: [], params: {}, previous_step: nil, pool: Grumlin.default_pool, client: nil)
      super()
      @name = name.to_sym
      @args = args # TODO: add recursive validation: only json types or Action
      @params = params # TODO: add recursive validation: only json types
      @previous_step = previous_step
      @shortcut = shortcuts[@name]
      @pool = pool
      @client = client
    end

    def configuration_step?
      CONFIGURATION_STEPS.include?(@name)
    end

    def start_step?
      START_STEPS.include?(@name)
    end

    def regular_step?
      REGULAR_STEPS.include?(@name)
    end

    def supported_step?
      ALL_STEPS.include?(@name)
    end

    def ==(other)
      self.class == other.class &&
        @name == other.name &&
        @args == other.args &&
        @params == other.params &&
        @previous_step == other.previous_step &&
        shortcuts == other.shortcuts
    end

    def steps
      @steps ||= Steps.from(self)
    end

    def to_s(**params)
      StepsSerializers::String.new(steps, **params).serialize
    end

    # TODO: add human readable mode
    def inspect
      conf_steps, regular_steps = StepsSerializers::HumanReadableBytecode.new(steps).serialize
      "#{conf_steps.any? ? conf_steps : nil}#{regular_steps}"
    end

    def bytecode(no_return: false)
      StepsSerializers::Bytecode.new(steps, no_return: no_return)
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
      client_write(bytecode)
    end

    def iterate
      client_write(bytecode(no_return: true))
    end

    private

    def client_write(payload)
      with_client do |client|
        client.write(payload)
      end
    end

    def with_client(&block)
      return yield @client if @client

      @pool.acquire(&block)
    end
  end
end
