# frozen_string_literal: true

module Grumlin
  class Action
    START_STEPS = Grumlin.definitions.dig(:steps, :start).map(&:to_sym).freeze
    CONFIGURATION_STEPS = Grumlin.definitions.dig(:steps, :configuration).map(&:to_sym).freeze
    REGULAR_STEPS = Grumlin.definitions.dig(:steps, :regular).map(&:to_sym).freeze

    ALL_STEPS = START_STEPS + CONFIGURATION_STEPS + REGULAR_STEPS

    attr_reader :name, :args, :params, :shortcuts, :next_step, :configuration_steps, :previous_step

    def initialize(name, args: [], params: {}, previous_step: nil, shortcuts: {}, pool: Grumlin.default_pool)
      @name = name.to_sym
      @args = args # TODO: add recursive validation: only json types or Action
      @params = params # TODO: add recursive validation: only json types
      @previous_step = previous_step
      @shortcuts = shortcuts
      @pool = pool
    end

    ALL_STEPS.each do |step|
      define_method step do |*args, **params|
        step(step, *args, **params)
      end
    end

    def step(name, *args, **params)
      Action.new(name, args: args, params: params, previous_step: self, shortcuts: @shortcuts, pool: @pool)
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

    def shortcut?
      @shortcuts.key?(@name)
    end

    def arguments
      @arguments ||= [*@args].tap do |args|
        args << @params if @params.any?
      end
    end

    def method_missing(name, *args, **params)
      return step(name, *args, **params) if @shortcuts.key?(name)

      super
    end

    def ==(other)
      self.class == other.class &&
        @name == other.name &&
        @args == other.args &&
        @params == other.params &&
        @previous_step == other.previous_step &&
        @shortcuts == other.shortcuts
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

    def respond_to_missing?(name, _include_private = false)
      @shortcuts.key?(name)
    end
  end
end
