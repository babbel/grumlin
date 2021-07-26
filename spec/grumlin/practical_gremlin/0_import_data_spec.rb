# frozen_string_literal: true

RSpec.describe "Practical Gremlin: Import data", gremlin_server: true, timeout: 60 do # rubocop:disable RSpec/DescribeClass
  let(:graphml) { File.read("spec/fixtures/air_routes/air-routes.graphml") }
  let(:importer) { GraphMLImporter.new(graphml) }

  describe "#import!" do
    it "imports the dataset" do # rubocop:disable RSpec/MultipleExpectations
      g.V.drop.iterate
      importer.import!

      expect(g.V().count.toList[0]).to eq(3619)
      expect(g.E().count.toList[0]).to eq(50_148)
    end
  end
end
