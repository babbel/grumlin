# frozen_string_literal: true

RSpec.describe Grumlin::Step, gremlin_server: true do
  let(:url) { "ws://localhost:8182/gremlin" }

  %i[string bytecode].each do |method|
    context "when method is #{method}" do
      let(:client) { Grumlin::Client.new(url, mode: method) }
      let(:g) { Grumlin::Traversal.new(client) }

      after do
        client.disconnect
      end

      describe "chaining" do
        it "builds a chain" do # rubocop:disable RSpec/MultipleExpectations
          g.addV.as("first")
           .addV.as("second")
           .addV.as("third")
           .addE("follows").from("first").to("second")
           .addE("follows").from("second").to("third")
           .addE("follows").from("third").to("first").toList

          expect(g.V().count.toList).to eq([3])
          expect(g.E().count.toList).to eq([3])
        end
      end
    end
  end
end
