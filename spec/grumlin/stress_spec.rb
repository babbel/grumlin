# frozen_string_literal: true

RSpec.describe "stress test", gremlin_server: true do # rubocop:disable RSpec/DescribeClass,RSpec/MultipleMemoizedHelpers
  let(:url) { "ws://localhost:8182/gremlin" }
  let(:client) { Grumlin::Client.new(url) }
  let(:g) { Grumlin::Traversal.new(client) }
  let(:uuids) { Array.new(1000) { SecureRandom.uuid } }

  let(:iterations) { 3000 }
  let(:concurrency) { 20 }

  after do
    client.disconnect
  end

  before do
    uuids.each_with_index do |uuid, i|
      g.addV("test_vertex").property(Grumlin::T.id, uuid).property("index", i).iterate
    end
  end

  def find_query
    uuid = uuids.sample
    result = g.V(uuid).toList[0]
    expect(result.id).to eq(uuid)
  end

  def create_query
    uuid = SecureRandom.uuid
    result = g.addV("test_vertex").property(Grumlin::T.id, uuid).toList
    expect(result[0].id).to eq(uuid)
  end

  def error_query
    expect do
      g.addE.iterate
    end.to raise_error(Grumlin::ServerSerializationError)
  end

  it "succeeds", timeout: 120 do # rubocop:disable RSpec/MultipleExpectations
    expect(client.requests).to be_empty

    tasks = Array.new(concurrency) do
      reactor.async do
        iterations.times do
          [
            -> { find_query },
            -> { create_query },
            -> { error_query }
          ].sample.call
          reactor.sleep(Float(rand(10)) / 100) if rand(3) == 0
        end
      end
    end

    tasks.each(&:wait)

    expect(client.requests).to be_empty
  end
end
