# frozen_string_literal: true

ENV["ENV"] ||= "test"
ENV["GREMLIN_URL"] ||= "ws://localhost:8182/gremlin"

require "csv"

require "async/rspec"
require "factory_bot"
require "nokogiri"

require "simplecov"

SimpleCov.start do
  add_filter "spec"
end

require "grumlin"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| load(f) }

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
    Grumlin::Client.new("ws://localhost:8182/gremlin").tap do |client|
      Grumlin::Traversal.new(client).V().drop.iterate
    end.disconnect
  end

  config.include_context(Async::RSpec::Reactor, gremlin_server: true)
  config.include_context(RSpec::GremlinContext, gremlin_server: true)
end
