# frozen_string_literal: true

RSpec.describe "Import the air routes dataset", gremlin_server: true, timeout: 60 do # rubocop:disable RSpec/DescribeClass
  let(:nodes) { CSV.new(File.read("spec/fixtures/air_routes/nodes.csv"), headers: true) }
  let(:edges) { CSV.new(File.read("spec/fixtures/air_routes/edges.csv"), headers: true) }

  it "imports the dataset" do # rubocop:disable RSpec/MultipleExpectations
    importer = CSVImporter.new(client, nodes, edges)
    importer.import!

    expect(g.V().count.toList[0]).to eq(3741)
    expect(g.E().count.toList[0]).to eq(57_573)
  end
end