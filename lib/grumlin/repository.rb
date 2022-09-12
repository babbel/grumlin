# frozen_string_literal: true

module Grumlin::Repository
  RETURN_MODES = {
    list: :toList,
    none: :iterate,
    single: :next,
    traversal: :nil
  }.freeze

  def self.extended(base)
    super
    base.extend(Grumlin::Shortcuts)
    base.include(Grumlin::Repository::InstanceMethods)

    base.shortcuts_from(Grumlin::Shortcuts::Properties)
    base.shortcuts_from(Grumlin::Shortcuts::Upserts)
  end

  def self.new
    @repository ||= Class.new do # rubocop:disable Naming/MemoizedInstanceVariableName
      extend Grumlin::Repository
    end.new
  end

  def inherited(subclass)
    super
    subclass.middlewares = Grumlin::Middlewares::Builder.new do |b|
      b.use(middlewares)
    end
  end

  def read_only!
    middlewares do |b|
      b.insert_after Grumlin::Middlewares::ApplyShortcuts, Grumlin::Middlewares::FindMutatingSteps
    end
  end

  def middlewares
    @middlewares ||= Grumlin::Middlewares::Builder.new do |b|
      b.use(Grumlin.default_middlewares)
    end

    yield(@middlewares) if block_given?
    @middlewares
  end

  def query(name, return_mode: :list, postprocess_with: nil, &query_block) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return_mode = validate_return_mode!(return_mode)
    postprocess_with = validate_postprocess_with!(postprocess_with)

    define_method name do |*args, query_params: {}, **params, &block|
      t = instance_exec(*args, **params, &query_block)
      return t if t.nil? || (t.respond_to?(:empty?) && t.empty?)

      unless t.is_a?(Grumlin::Step)
        raise Grumlin::WrongQueryResult,
              "queries must return #{Grumlin::Step}, nil or an empty collection. Given: #{t.class}"
      end

      return block.call(t) unless block.nil?

      return t.profile.next if query_params[:profile] == true

      return_mode = self.class.validate_return_mode!(query_params[:return_mode] || return_mode)

      return t if return_mode == :traversal

      t.public_send(RETURN_MODES[return_mode]).tap do |result|
        return postprocess_with.call(result) if postprocess_with.respond_to?(:call)
        return send(postprocess_with, result) unless postprocess_with.nil?
      end
    end
  end

  def default_vertex_properties(&block)
    shortcut :addV, override: true do |*args|
      super(*args).props(**block.call(*args)) # rubocop:disable Performance/RedundantBlockCall
    end
  end

  def default_edge_properties(&block)
    shortcut :addE, override: true do |*args|
      super(*args).props(**block.call(*args))  # rubocop:disable Performance/RedundantBlockCall
    end
  end

  def validate_return_mode!(return_mode)
    return return_mode if RETURN_MODES.include?(return_mode)

    raise ArgumentError, "unsupported return mode #{return_mode}. Supported modes: #{RETURN_MODES.keys}"
  end

  def validate_postprocess_with!(postprocess_with)
    if postprocess_with.nil? || postprocess_with.is_a?(Symbol) ||
       postprocess_with.is_a?(String) || postprocess_with.respond_to?(:call)
      return postprocess_with
    end

    raise ArgumentError,
          "postprocess_with must be a String, Symbol or a callable object, given: #{postprocess_with.class}"
  end

  protected

  attr_writer :middlewares
end
