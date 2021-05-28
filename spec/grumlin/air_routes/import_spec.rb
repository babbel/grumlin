# frozen_string_literal: true

RSpec.describe "Import the air routes dataset", gremlin_server: true, timeout: 60 do # rubocop:disable RSpec/DescribeClass,RSpec/MultipleMemoizedHelpers
  let(:url) { "ws://localhost:8182/gremlin" }
  let(:nodes) { File.read("spec/fixtures/air_routes/nodes.csv") }
  let(:edges) { File.read("spec/fixtures/air_routes/edges.csv") }
  let(:node_types) do
    {
      "~id" => :to_i,
      "~label" => :to_s,
      "type:string" => :to_s,
      "code:string" => :to_s,
      "icao:string" => :to_s,
      "desc:string" => :to_s,
      "region:string" => :to_s,
      "runways:int" => :to_i,
      "longest:int" => :to_i,
      "elev:int" => :to_i,
      "country:string" => :to_s,
      "city:string" => :to_s,
      "lat:double" => :to_f,
      "lon:double" => :to_f,
      "author:string" => :to_s,
      "date:string" => :to_s
    }
  end

  let(:edge_types) do
    {
      "~id" => :to_i,
      "~from" => :to_i,
      "~to" => :to_i,
      "~label" => :to_s,
      "dist:int" => :to_i
    }
  end

  let(:casted_nodes) do
    nodes_csv = CSV.new(nodes, headers: true)

    nodes_csv.each_with_index.map do |row, index|
      next if index.zero?

      row.each_with_object({}) do |(k, v), acc|
        acc[k] = v.nil? ? v : v.send(node_types[k])
      end
    end.compact
  end

  let(:casted_edges) do
    nodes_csv = CSV.new(edges, headers: true)

    nodes_csv.each_with_index.map do |row, index|
      next if index.zero?

      row.each_with_object({}) do |(k, v), acc|
        acc[k] = v.nil? ? v : v.send(edge_types[k])
      end
    end.compact
  end
  let(:client) { Grumlin::Client.new(url) }

  after do
    client.disconnect
  end

  it "imports the dataset" do # rubocop:disable RSpec/MultipleExpectations
    g = Grumlin::Traversal.new(client)
    casted_nodes.each do |node| # TODO: import in batches
      t = g.addV(node.delete("~label")).property(Grumlin::TraversingContext::T_ID, node.delete("~id"))
      node.each do |k, v|
        next if v.nil?

        t = t.property(k.split(":")[0], v)
      end
      t.toList
    end

    casted_edges.each do |node| # TODO: import in batches
      t = g.addE(node.delete("~label")).property(Grumlin::TraversingContext::T_ID,
                                                 node.delete("~id"))
           .from(Grumlin::TraversingContext.V(node.delete("~from")))
           .to(Grumlin::TraversingContext.V(node.delete("~to")))
      node.each do |k, v|
        next if v.nil?

        t = t.property(k.split(":")[0], v)
      end
      t.toList
    end

    expect(g.V().count.toList[0]).to eq(3741)
    expect(g.E().count.toList[0]).to eq(57_573)
  end
end
