# frozen_string_literal: true

RSpec.describe "Import the air routes dataset", gremlin_server: true, timeout: 600 do # rubocop:disable RSpec/DescribeClass
  let(:graphml) { File.read("spec/fixtures/air_routes/air-routes.graphml") }

  it "imports the dataset" do # rubocop:disable RSpec/MultipleExpectations
    importer = GraphMLImporter.new(client, graphml)
    importer.import!

    expect(g.V().count.toList[0]).to eq(3618)
    expect(g.E().count.toList[0]).to eq(50_148)
  end
end
