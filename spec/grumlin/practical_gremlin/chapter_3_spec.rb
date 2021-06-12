# frozen_string_literal: true

RSpec.describe "Practical Gremlin: Chapter 3 specs" do # rubocop:disable RSpec/DescribeClass
  it "1" do
    expect(g.V().hasLabel("airport").count.next).to eq(3374)
  end

  it "2" do
    expect(g.V().has("code", "DFW").count.next).to eq(1)
  end

  it "3" do # rubocop:disable RSpec/MultipleExpectations
    expect(g.V().hasLabel("airport").has("code", "DFW").count.next).to eq(1)
    expect(g.V().has("airport", "code", "DFW").count.next).to eq(1)
  end

  it "4" do
    expect(g.V().has("airport", "code",
                     "DFW").values.toList).to eq(["US", "DFW", 13_401, "Dallas", 607, "KDFW",
                                                  -97.0380020141602, "airport", "US-TX", 7, 32.896800994873,
                                                  "Dallas/Fort Worth International Airport"])
  end

  it "5" do
    expect(g.V().has("airport", "code", "DFW").values("city").toList).to eq(["Dallas"])
  end

  it "6" do
    expect(g.V().has("airport", "code", "DFW").values("runways", "icao").toList).to eq(["KDFW", 7])
  end

  it "7" do # rubocop:disable RSpec/MultipleExpectations
    expect(g.E().has("dist").count.next).to eq(43_400)
    expect(g.V().has("region").count.next).to eq(3374)
    expect(g.V().hasNot("region").count.next).to eq(245)
    expect(g.V().not(Grumlin::U.has("region")).count.next).to eq(245)
  end

  it "8" do
    expect(g.V().outE("route").count.next).to eq(43_400)
  end

  it "9" do
    expect(g.E().hasLabel("route").count.next).to eq(43_400)
  end

  it "10" do # rubocop:disable RSpec/MultipleExpectations
    result = { airport: 3374,
               continent: 7,
               country: 237,
               version: 1 }
    expect(g.V().groupCount.by(Grumlin::T.label).next).to eq(result)
    expect(g.V().label.groupCount.next).to eq(result)
    expect(g.V().group.by(Grumlin::T.label).by(Grumlin::U.count).next).to eq(result)
  end

  it "11" do # rubocop:disable RSpec/MultipleExpectations
    result = { contains: 6748, route: 43_400 }
    expect(g.E().groupCount.by(Grumlin::T.label).next).to eq(result)
    expect(g.E().label.groupCount.next).to eq(result)
  end
end
