# frozen_string_literal: true

module Grumlin::Repository::InstanceMethods # rubocop:disable Metrics/ModuleLength
  include Grumlin::Expressions

  extend Forwardable

  def_delegator "self.class", :shortcuts
  def_delegator :self, :__, :g

  UPSERT_RETRY_PARAMS = {
    on: [Grumlin::AlreadyExistsError, Grumlin::ConcurrentModificationError],
    sleep_method: ->(n) { Async::Task.current.sleep(n) },
    tries: 5,
    sleep: ->(n) { (n**2) + 1 + rand }
  }.freeze

  DEFAULT_ERROR_HANDLING_STRATEGY = Grumlin::Repository::ErrorHandlingStrategy.new(mode: :retry, **UPSERT_RETRY_PARAMS)

  def __
    shortcuts.traversal_start_class.new(pool: Grumlin.default_pool, middlewares: self.class.middlewares)
  end

  def drop_vertex(id, start: g)
    start.V(id).drop.iterate
  end

  def drop_in_batches(traversal, batch_size: 10_000) # rubocop:disable Metrics/AbcSize
    total_count = traversal.count.next

    batches = (total_count / batch_size) + 1

    Console.logger.info(self) do
      "drop_in_batches: total_count: #{total_count}, batch_size: #{batch_size}, batches: #{batches}"
    end

    batches.times do |batch|
      Console.logger.info(self) { "drop_in_batches: deleting batch #{batch + 1}/#{batches}..." }
      traversal.limit(batch_size).drop.iterate
      Console.logger.info(self) { "drop_in_batches: batch #{batch + 1}/#{batches} deleted" }
    end

    return if traversal.count.next.zero?

    drop_in_batches(traversal, batch_size: batch_size)

    Console.logger.info(self) { "drop_in_batches: finished." }
  end

  def drop_edge(id = nil, from: nil, to: nil, label: nil, start: g) # rubocop:disable Metrics/AbcSize
    raise ArgumentError, "either id or from:, to: and label: must be passed" if [id, from, to, label].all?(&:nil?)
    return start.E(id).drop.iterate unless id.nil?

    raise ArgumentError, "from:, to: and label: must be passed" if [from, to, label].any?(&:nil?)

    start.V(from).outE(label).where(__.inV.hasId(to)).limit(1).drop.iterate
  end

  def add_vertex(label, id = nil, start: g, **properties)
    id ||= properties[T.id]
    properties = except(properties, T.id)

    t = start.addV(label)
    t = t.props(T.id => id) unless id.nil?
    t.props(**properties).next
  end

  def add_edge(label, id = nil, from:, to:, start: g, **properties)
    id ||= properties[T.id]
    properties = except(properties, T.label)
    properties[T.id] = id

    start.addE(label).from(__.V(from)).to(__.V(to)).props(**properties).next
  end

  def upsert_vertex(label, id, create_properties: {}, update_properties: {}, on_failure: :retry, start: g, **params) # rubocop:disable Metrics/ParameterLists
    with_upsert_error_handling(on_failure, params) do
      create_properties, update_properties = cleanup_properties(create_properties, update_properties)

      start.upsertV(label, id, create_properties, update_properties).id.next
    end
  end

  # vertices:
  # [["label", "id", {create: :properties}, {update: properties}]]
  # params can override Retryable config from UPSERT_RETRY_PARAMS
  def upsert_vertices(vertices, batch_size: 100, on_failure: :retry, start: g, **params)
    vertices.each_slice(batch_size) do |slice|
      with_upsert_error_handling(on_failure, params) do
        slice.reduce(start) do |t, (label, id, create_properties, update_properties)|
          create_properties, update_properties = cleanup_properties(create_properties, update_properties)

          t.upsertV(label, id, create_properties, update_properties)
        end.id.iterate
      end
    end
  end

  # Only from and to are used to find the existing edge, if one wants to assign an id to a created edge,
  # it must be passed as T.id in create_properties.
  def upsert_edge(label, from:, to:, create_properties: {}, update_properties: {}, # rubocop:disable Metrics/ParameterLists
                  on_failure: :retry, start: g, **params)
    with_upsert_error_handling(on_failure, params) do
      create_properties, update_properties = cleanup_properties(create_properties, update_properties, T.label)
      start.upsertE(label, from, to, create_properties, update_properties).id.next
    end
  end

  # edges:
  # [["label", "from", "to", {create: :properties}, {update: properties}]]
  # params can override Retryable config from UPSERT_RETRY_PARAMS
  def upsert_edges(edges, batch_size: 100, on_failure: :retry, start: g, **params)
    edges.each_slice(batch_size) do |slice|
      with_upsert_error_handling(on_failure, params) do
        slice.reduce(start) do |t, (label, from, to, create_properties, update_properties)|
          create_properties, update_properties = cleanup_properties(create_properties, update_properties, T.label)

          t.upsertE(label, from, to, create_properties, update_properties)
        end.id.iterate
      end
    end
  end

  private

  def with_upsert_error_handling(on_failure, params, &block)
    if params.any?
      ErrorHandlingStrategy.new(mode: on_failure, **UPSERT_RETRY_PARAMS.merge(params))
    else
      DEFAULT_ERROR_HANDLING_STRATEGY
    end.apply!(&block)
  end

  def with_upsert_retry(retry_params, &block)
    retry_params = UPSERT_RETRY_PARAMS.merge((retry_params))
    Retryable.retryable(**retry_params, &block)
  end

  # A polyfill for Hash#except for ruby 2.x environments without ActiveSupport
  # TODO: delete and use native Hash#except after ruby 2.7 is deprecated.
  def except(hash, *keys)
    return hash.except(*keys) if hash.respond_to?(:except)

    hash.each_with_object({}) do |(k, v), res|
      res[k] = v unless keys.include?(k)
    end
  end

  def cleanup_properties(create_properties, update_properties, *props_to_cleanup)
    props_to_cleanup = [T.id, T.label] if props_to_cleanup.empty?
    [create_properties, update_properties].map do |props|
      except(props, props_to_cleanup)
    end
  end
end
