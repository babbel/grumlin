# frozen_string_literal: true

module Grumlin
  module Repository
    RETURN_MODES = {
      list: :toList,
      none: :iterate,
      single: :next,
      traversal: :nil
    }.freeze

    module InstanceMethods
      def __
        TraversalStart.new(self.class.shortcuts)
      end

      def g
        TraversalStart.new(self.class.shortcuts)
      end
    end

    def self.extended(base)
      base.extend(Grumlin::Shortcuts)
      base.include(Grumlin::Expressions)
      base.include(InstanceMethods)

      base.shortcuts_from(Grumlin::Shortcuts::Properties)
    end

    def query(name, return_mode: :list, &block) # rubocop:disable Metrics/AbcSize
      validate_return_mode!(return_mode)

      define_method name do |*args, query_params: {}, **params|
        t = instance_exec(*args, **params, &block)
        raise WrongQueryResult, "queries must return traversals, given: #{t.class}" unless t.is_a?(Grumlin::Action)

        return t.profile.next if query_params[:profile] == true
        return t.profile(query_params[:profile]).next if query_params[:profile]

        return_mode = query_params[:return_mode] || return_mode

        self.class.validate_return_mode!(return_mode)

        return t if return_mode == :traversal

        return t.send(RETURN_MODES[return_mode])
      end
    end

    def validate_return_mode!(return_mode)
      return if RETURN_MODES.key?(return_mode)

      raise ArgumentError, "unsupported return mode #{return_mode}. Supported modes: #{RETURN_MODES.keys}"
    end
  end
end
