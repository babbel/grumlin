# frozen_string_literal: true

module Grumlin
  module Typing
    TYPES = {
      "g:List" => ->(value) { value.map { |item| cast(item) } },
      "g:Map" => ->(value) { cast_map(value) },
      "g:Vertex" => ->(value) { cast_entity(Grumlin::Vertex, value) },
      "g:Edge" => ->(value) { cast_entity(Grumlin::Edge, value) },
      "g:Int64" => ->(value) { cast_int(value) },
      "g:Int32" => ->(value) { cast_int(value) },
      "g:Traverser" => ->(value) { cast(value[:value]) } # TODO: wtf is bulk?
    }.freeze

    CASTABLE_TYPES = [Hash, String, Integer].freeze

    class << self
      def cast(value)
        verify_type!(value)

        return value unless value.is_a?(Hash)

        type = TYPES[value[:@type]]

        verify_castable_hash!(value, type)

        type.call(value[:@value])
      end

      def to_bytecode(step)
        {
          "@type": "g:Bytecode",
          "@value": { step: step }
        }
      end

      private

      def castable_type?(value); end

      def verify_type!(value)
        raise TypeError, "#{value.inspect} cannot be casted" unless CASTABLE_TYPES.any? { |t| value.is_a?(t) }
      end

      def verify_castable_hash!(value, type)
        raise TypeError, "#{value} cannot be casted, @type is missing" if value[:@type].nil?
        raise(UnknownTypeError, value[:@type]) if type.nil?
        raise TypeError, "#{value} cannot be casted, @value is missing" if value[:@value].nil?
      end

      def cast_int(value)
        raise TypeError, "#{value} is not an Integer" unless value.is_a?(Integer)

        value
      end

      def cast_entity(entity, value)
        entity.new(**value)
      rescue ArgumentError, TypeError
        raise TypeError, "#{value} cannot be casted to #{entity.name}"
      end

      def cast_map(value)
        Hash[*value].transform_keys(&:to_sym).transform_values { |v| cast(v) }
      rescue ArgumentError
        raise TypeError, "#{value} cannot be casted to Hash"
      end

      def cast_traverser(value); end
    end
  end
end
