# frozen_string_literal: true

class Grumlin::Step < Grumlin::Steppable
  attr_reader :name, :args, :params, :next_step, :configuration_steps, :previous_step, :shortcut

  # TODO: replace pool, session_id and middlewares with a context?
  def initialize(name, args: [], params: {}, previous_step: nil, pool: nil, session_id: nil, # rubocop:disable Metrics/ParameterLists
                 middlewares: Grumlin.default_middlewares)
    super(pool:, session_id:, middlewares:)

    @name = name.to_sym
    @args = args # TODO: add recursive validation: only json types or Step
    @params = params # TODO: add recursive validation: only json types
    @previous_step = previous_step
    @shortcut = shortcuts[@name]
  end

  def configuration_step?
    CONFIGURATION_STEPS.include?(@name) || name.to_sym == :tx
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
    @steps ||= Grumlin::Steps.from(self)
  end

  def to_s(**params)
    Grumlin::StepsSerializers::String.new(steps, **params).serialize
  end

  # TODO: add human readable mode
  def inspect
    conf_steps, regular_steps = Grumlin::StepsSerializers::HumanReadableBytecode.new(steps).serialize
    "#{conf_steps.any? ? conf_steps : nil}#{regular_steps}"
  end

  def bytecode(no_return: false)
    Grumlin::StepsSerializers::Bytecode.new(steps, no_return:)
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
    send_query(need_results: true)
  end

  def iterate
    send_query(need_results: false)
  end

  private

  def send_query(need_results:)
    @middlewares.call(traversal: self,
                      need_results:,
                      session_id: @session_id,
                      pool: @pool)
  end
end
