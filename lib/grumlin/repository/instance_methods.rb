# frozen_string_literal: true

module Grumlin
  module Repository
    module InstanceMethods
      include Grumlin::Expressions

      UPSERT_RETRY_PARAMS = {
        on: [Grumlin::AlreadyExistsError, Grumlin::ConcurrentInsertFailedError],
        sleep_method: ->(n) { Async::Task.current.sleep(n) },
        tries: 3,
        sleep: ->(n) { (n**2) + 1 + rand }
      }.freeze

      def __
        @__ ||= TraversalStart.new(self.class.shortcuts)
      end

      def g
        @g ||= TraversalStart.new(self.class.shortcuts)
      end

      def drop_vertex(id)
        g.V(id).drop.iterate
      end

      def drop_edge(id = nil, from: nil, to: nil, label: nil) # rubocop:disable Metrics/AbcSize
        raise ArgumentError, "either id or from:, to: and label: must be passed" if [id, from, to, label].all?(&:nil?)
        return g.E(id).drop.iterate unless id.nil?

        raise ArgumentError, "from:, to: and label: must be passed" if [from, to, label].any?(&:nil?)

        g.V(from).outE(label).where(__.inV.hasId(to)).limit(1).drop.iterate
      end

      def add_vertex(label, id = nil, **properties)
        id ||= properties[T.id]
        properties = except(properties, T.id)

        t = g.addV(label)
        t = t.props(T.id => id) unless id.nil?
        t.props(**properties).next
      end

      def add_edge(label, id = nil, from:, to:, **properties)
        id ||= properties[T.id]
        properties = except(properties, T.label)
        properties[T.id] = id

        g.addE(label).from(__.V(from)).to(__.V(to)).props(**properties).next
      end

      def upsert_vertex(label, id, create_properties: {}, update_properties: {})
        create_properties, update_properties = cleanup_properties(create_properties, update_properties)

        g.upsertV(label, id, create_properties, update_properties).next
      end

      # vertices:
      # [["label", "id", {create: :properties}, {update: properties}]]
      # retry_params can override Retryable config from UPSERT_RETRY_PARAMS
      def upsert_vertices(vertices, batch_size: 100, retry_params: {})
        with_upsert_retry(retry_params) do
          vertices.each_slice(batch_size) do |slice|
            slice.reduce(g) do |t, (label, id, create_properties, update_properties)|
              create_properties, update_properties = cleanup_properties(create_properties, update_properties)

              t.upsertV(label, id, create_properties, update_properties)
            end.iterate
          end
        end
      end

      # Only from and to are used to find the existing edge, if one wants to assign an id to a created edge,
      # it must be passed as T.id in create_properties.
      def upsert_edge(label, from:, to:, create_properties: {}, update_properties: {})
        create_properties, update_properties = cleanup_properties(create_properties, update_properties, T.label)
        g.upsertE(label, from, to, create_properties, update_properties).next
      end

      # edges:
      # [["label", "id", {create: :properties}, {update: properties}]]
      # retry_params can override Retryable config from UPSERT_RETRY_PARAMS
      def upsert_edges(edges, batch_size: 100, retry_params: {})
        with_upsert_retry(retry_params) do
          edges.each_slice(batch_size) do |slice|
            slice.reduce(g) do |t, (label, from, to, create_properties, update_properties)|
              create_properties, update_properties = cleanup_properties(create_properties, update_properties, T.label)

              t.upsertE(label, from, to, create_properties, update_properties)
            end.iterate
          end
        end
      end

      private

      def with_upsert_retry(retry_params, &block)
        retry_params = UPSERT_RETRY_PARAMS.merge((retry_params))
        Retryable.retryable(**retry_params, &block)
      end

      # A polyfill for Hash#except for ruby 2.x environments without ActiveSupport
      # TODO: delete and use native Hash#except when after ruby 2.7 is deprecated.
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
  end
end
