# frozen_string_literal: true

RSpec.describe "stress test", gremlin_server: true do
  let(:uuids) { Array.new(1000) { SecureRandom.uuid } }

  let(:concurrency) { 20 }

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

  def paginated_query
    vertices = g.V().limit(100).toList
    expect(vertices.count).to eq(100)
    expect(vertices.map(&:id).uniq.count).to eq(100)
  end

  def random_query
    [
      -> { find_query },
      -> { create_query },
      -> { error_query },
      -> { paginated_query }
    ].sample.call
    reactor.sleep(Float(rand(10)) / 100) if rand(3) == 0
  end

  context "when number of iterations is limited" do
    let(:iterations) { 100 }

    it "succeeds", timeout: 120 do
      barrier = Async::Barrier.new

      Array.new(concurrency) do
        barrier.async do
          iterations.times do
            random_query
          end
        end
      end

      barrier.wait
    end
  end

  context "when time is limited" do
    let(:duration) { 10 }

    it "succeeds", timeout: 20 do
      barrier = Async::Barrier.new(parent: reactor)

      concurrency.times do
        barrier.async do
          random_query
        end
      end

      reactor.sleep(duration)
      barrier.tasks.each(&:stop)
      barrier.wait
    end
  end

  context "when stopping during a long running query" do
    it "succeeds" do
      barrier = Async::Barrier.new

      concurrency.times do
        barrier.async do
          paginated_query
        end
      end

      barrier.tasks.each(&:stop)
      barrier.wait
    end
  end
end
