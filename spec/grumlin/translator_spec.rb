# frozen_string_literal: true

RSpec.describe Grumlin::Translator, gremlin_server: true do
  let(:url) { "ws://localhost:8182/gremlin" }
  let(:client) { Grumlin::Client.new(url) }
  let(:g) { Grumlin::Traversal.new(client) }

  describe ".to_string_query" do
    subject { described_class.to_string_query(steps) }

    let(:steps) do
      g.addV.as("first")
       .addV.as("second")
       .addV.as("third")
       .addE("follows").from("first").to("second")
       .addE("follows").from("second").to("third")
       .addE("follows").from("third").to("first").steps
    end

    it "returns query steps and corresponding bindings" do
      expect(subject).to eq(["g.addV().as(b_0).addV().as(b_1).addV().as(b_2).addE(b_3).from(b_4).to(b_5).addE(b_6).from(b_7).to(b_8).addE(b_9).from(b_a).to(b_b)", # rubocop:disable Layout/LineLength
                             { "b_0" => "first", "b_1" => "second", "b_2" => "third", "b_3" => "follows",
                               "b_4" => "first", "b_5" => "second", "b_6" => "follows", "b_7" => "second",
                               "b_8" => "third", "b_9" => "follows", "b_a" => "third", "b_b" => "first" }])
    end
  end

  describe "to_string" do
    subject { described_class.to_string(steps) }

    let(:steps) do
      g.addV.as("first")
       .addV.as("second")
       .addV.as("third")
       .addE("follows").from("first").to("second")
       .addE("follows").from("second").to("third")
       .addE("follows").from("third").to("first").steps
    end

    it "returns string represenation of the query" do
      expect(subject).to eq('g.addV().as("first").addV().as("second").addV().as("third").addE("follows").from("first").to("second").addE("follows").from("second").to("third").addE("follows").from("third").to("first")') # rubocop:disable Layout/LineLength
    end
  end
end
