# frozen_string_literal: true

module Grumlin
  module Typing
    TYPES = {
      "g:List" => ->(value) { cast_list(value) },
      "g:Set" => ->(value) { cast_list(value).to_set },
      "g:Map" => ->(value) { cast_map(value) },
      "g:Vertex" => ->(value) { cast_entity(Grumlin::Vertex, value) },
      "g:Edge" => ->(value) { cast_entity(Grumlin::Edge, value) },
      "g:Path" => ->(value) { cast_entity(Grumlin::Path, value) },
      "g:Int64" => ->(value) { cast_int(value) },
      "g:Int32" => ->(value) { cast_int(value) },
      "g:Double" => ->(value) { cast_double(value) },
      "g:Traverser" => ->(value) { cast_traverser(value) },
      "g:Direction" => ->(value) { value },
      "g:Property" => ->(value) { { value[:key] => value[:value] } },
      # "g:VertexProperty"=> ->(value) { value }, # TODO: implement me
      "g:T" => ->(value) { value.to_sym }
    }.freeze

    class Traverser
      attr_reader :bulk, :value

      def initialize(bulk, value)
        @bulk = bulk || 1
        @value = value
      end
    end

    CASTABLE_TYPES = [Hash, String, Integer, TrueClass, FalseClass].freeze

    class << self
      def cast(value)
        verify_type!(value)

        return value unless value.is_a?(Hash)

        type = TYPES[value[:@type]]

        verify_castable_hash!(value, type)

        type.call(value[:@value])
      end

      private

      def verify_type!(value)
        raise TypeError, "#{value.inspect} cannot be casted" unless CASTABLE_TYPES.include?(value.class)
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

      def cast_double(value)
        raise TypeError, "#{value} is not a Double" unless value.is_a?(Float)

        value
      end

      def cast_entity(entity, value)
        entity.new(**value)
      rescue ArgumentError, TypeError
        raise TypeError, "#{value} cannot be casted to #{entity.name}"
      end

      def cast_map(value)
        Hash[*value].transform_keys do |key|
          next key.to_sym if key.respond_to?(:to_sym)
          next cast(key) if key[:@type]

          raise UnknownMapKey, key, value
        end.transform_values { |v| cast(v) }
      rescue ArgumentError
        raise TypeError, "#{value} cannot be casted to Hash"
      end

      def cast_list(value)
        value.each_with_object([]) do |item, result|
          casted_value = cast(item)
          next (result << casted_value) unless casted_value.instance_of?(Traverser)

          casted_value.bulk.times { result << casted_value.value }
        end
      end

      def cast_traverser(value)
        Traverser.new(value.dig(:bulk, :@value), cast(value[:value]))
      end
    end
  end
end
