# frozen_string_literal: true

require "csv"

require "async/rspec"
require "factory_bot"

require "simplecov"

SimpleCov.start do
  add_filter "spec"
end

require "grumlin"

require_relative "support/shared_examples"
require_relative "support/csv_importer"

RSpec.configure do |config|
  config.order = :random
  config.disable_monkey_patching!

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each, gremlin_server: true) do
    Grumlin::Traversal.new("ws://localhost:8182/gremlin").V().drop.iterate
  end

  config.include_context(Async::RSpec::Reactor, gremlin_server: true)
end
