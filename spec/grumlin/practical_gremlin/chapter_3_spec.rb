# frozen_string_literal: true

RSpec.describe "Practical Gremlin: Chapter 3 specs" do # rubocop:disable RSpec/DescribeClass
  it "1" do
    expect(g.V().hasLabel("airport").count.next).to eq(3497)
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
    expect(g.E().has("dist").count.next).to eq(50_579)
    expect(g.V().has("region").count.next).to eq(3497)
    expect(g.V().hasNot("region").count.next).to eq(244)
    expect(g.V().not(Grumlin::U.has("region")).count.next).to eq(244)
  end
end
