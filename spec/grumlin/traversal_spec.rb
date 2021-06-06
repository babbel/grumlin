# frozen_string_literal: true

RSpec.describe Grumlin::Traversal, clean_db: true do
  let(:url) { "ws://localhost:8182/gremlin" }
  let(:client) { Grumlin::Client.new(url) }
  let(:g) { described_class.new(client) }

  after do
    client.disconnect
  end

  describe "#V" do
    subject { g.V(*ids).toList }

    let(:ids) { [] }

    context "when the DB is empty" do
      context "with no arguments" do
        it "returns an empty array" do
          expect(subject).to eq([])
        end
      end

      context "with arguments" do
        let(:ids) { [1, 2, 3] }

        it "returns an empty array" do
          expect(subject).to eq([])
        end
      end
    end

    context "when the DB is not empty" do
      before do
        g.addV("test_vertex").property(Grumlin::T.id, 1)
         .addV("test_vertex").property(Grumlin::T.id, 2).iterate
      end

      context "with no arguments" do
        it "returns vertices" do
          expect(subject).to eq([build(:vertex, id: 1), build(:vertex, id: 2)])
        end
      end

      context "with arguments" do
        let(:ids) { [2] }

        it "returns vertices" do
          expect(subject).to eq([build(:vertex, id: 2)])
        end
      end
    end
  end
end
