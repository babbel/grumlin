# frozen_string_literal: true

require "grumlin"
require "benchmark/ips"

namespace :benchmark do
  desc "Run serialization benchmarks"
  task :serialization do
    repo = Grumlin::Benchmark::Repository.new

    Benchmark.ips do |x|
      x.time = 3
      x.report("Simple") { repo.simple_test }
      x.report("Simple shortcut") { repo.simple_test_with_shortcut }
    end
  end
end
