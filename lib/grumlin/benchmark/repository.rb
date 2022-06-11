# frozen_string_literal: true

module Grumlin
  module Benchmark
    class Repository
      extend Grumlin::Repository

      shortcut :simple_test do
        self.V
      end

      def simple_test
        g.V.bytecode.serialize
      end

      def simple_test_with_shortcut
        g.simple_test.bytecode.serialize
      end
    end
  end
end
