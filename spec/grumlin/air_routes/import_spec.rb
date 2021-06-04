# frozen_string_literal: true

RSpec.describe "Import the air routes dataset", clean_db: true, timeout: 60 do # rubocop:disable RSpec/DescribeClass
  let(:url) { "ws://localhost:8182/gremlin" }
  let(:nodes) { CSV.new(File.read("spec/fixtures/air_routes/nodes.csv"), headers: true) }
  let(:edges) { CSV.new(File.read("spec/fixtures/air_routes/edges.csv"), headers: true) }
  let(:client) { Grumlin::Client.new(url) }
  let(:g) { Grumlin::Traversal.new(client) }

  after do
    client.disconnect
  end

  it "imports the dataset" do # rubocop:disable RSpec/MultipleExpectations
    importer = CSVImporter.new(client, nodes, edges)
    importer.import!

    expect(g.V().count.toList[0]).to eq(3741)
    expect(g.E().count.toList[0]).to eq(57_573)
  end
end
