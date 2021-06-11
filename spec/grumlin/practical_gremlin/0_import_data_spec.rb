# frozen_string_literal: true

RSpec.describe "Practical Gremlin: Import data", gremlin_server: true, timeout: 60 do # rubocop:disable RSpec/DescribeClass
  let(:nodes) { CSV.new(File.read("spec/fixtures/air_routes/nodes.csv"), headers: true) }
  let(:edges) { CSV.new(File.read("spec/fixtures/air_routes/edges.csv"), headers: true) }
  let(:importer) { CSVImporter.new(client, nodes, edges) }

  describe "#import!" do
    xit "imports the dataset" do # rubocop:disable RSpec/MultipleExpectations
      g.V.drop.iterate
      importer.import!

      expect(g.V().count.toList[0]).to eq(3741)
      expect(g.E().count.toList[0]).to eq(57_573)
    end
  end
end
