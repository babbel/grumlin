# frozen_string_literal: true

RSpec.describe Grumlin::Step, gremlin_server: true do
  let(:url) { "ws://localhost:8182/gremlin" }

  # TODO: fix string mode
  %i[bytecode].each do |method|
    context "when method is #{method}" do
      let(:client) { Grumlin::Client.new(url, mode: method) }
      let(:g) { Grumlin::Traversal.new(client) }

      after do
        client.disconnect
      end

      describe "chaining" do
        context "when using aliases" do
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

        context "when using anonymous queries" do
          it "builds a chain" do # rubocop:disable RSpec/MultipleExpectations
            g.addV.property(Grumlin::T.id, 1)
             .addV.property(Grumlin::T.id, 2)
             .addV.property(Grumlin::T.id, 3).toList

            t = g.addE("follows").from(Grumlin::U.V(1)).to(Grumlin::U.V(2))
                 .addE("follows").from(Grumlin::U.V(2)).to(Grumlin::U.V(3))
                 .addE("follows").from(Grumlin::U.V(3)).to(Grumlin::U.V(1))

            t.toList

            expect(g.V().count.toList).to eq([3])
            expect(g.E().count.toList).to eq([3])
          end
        end
      end
    end
  end
end
