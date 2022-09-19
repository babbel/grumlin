# frozen_string_literal: true

RSpec.describe "Practical Gramlin: walking" do
  it "1" do
    expect(g.V().has("airport", "code", "AUS").out.values("code").fold.next).to eq(%w[YYZ
                                                                                      LHR
                                                                                      FRA
                                                                                      MEX
                                                                                      PIT
                                                                                      PDX
                                                                                      CLT
                                                                                      CUN
                                                                                      MEM
                                                                                      CVG
                                                                                      IND
                                                                                      MCI
                                                                                      DAL
                                                                                      STL
                                                                                      ABQ
                                                                                      MDW
                                                                                      LBB
                                                                                      HRL
                                                                                      GDL
                                                                                      PNS
                                                                                      VPS
                                                                                      SFB
                                                                                      BKG
                                                                                      PIE
                                                                                      ATL
                                                                                      BNA
                                                                                      BOS
                                                                                      BWI
                                                                                      DCA
                                                                                      DFW
                                                                                      FLL
                                                                                      IAD
                                                                                      IAH
                                                                                      JFK
                                                                                      LAX
                                                                                      MCO
                                                                                      MIA
                                                                                      MSP
                                                                                      ORD
                                                                                      PHX
                                                                                      RDU
                                                                                      SEA
                                                                                      SFO
                                                                                      SJC
                                                                                      TPA
                                                                                      SAN
                                                                                      LGB
                                                                                      SNA
                                                                                      SLC
                                                                                      LAS
                                                                                      DEN
                                                                                      MSY
                                                                                      EWR
                                                                                      HOU
                                                                                      ELP
                                                                                      CLE
                                                                                      OAK
                                                                                      PHL
                                                                                      DTW])
  end

  it "2" do
    expect(g.V().has("airport", "code", "AUS").out("route").out("route").values("code").count.next).to eq(5942)
  end

  it "3" do
    expect(g.V().has("airport", "code", "LCY").in("route").values("code").toList).to eq(%w[IBZ
                                                                                           AGP
                                                                                           PMI
                                                                                           JSI
                                                                                           AMS
                                                                                           MAH
                                                                                           BRN
                                                                                           DRS
                                                                                           EDI
                                                                                           CDG
                                                                                           ARN
                                                                                           ABZ
                                                                                           RTM
                                                                                           IOM
                                                                                           CWL
                                                                                           BSL
                                                                                           ORY
                                                                                           FRA
                                                                                           DOL
                                                                                           BVE
                                                                                           ZRH
                                                                                           NCE
                                                                                           BLL
                                                                                           MAN
                                                                                           VCE
                                                                                           GRX
                                                                                           GVA
                                                                                           BES
                                                                                           JFK
                                                                                           LIN
                                                                                           DUS
                                                                                           LUX
                                                                                           JER
                                                                                           FCO
                                                                                           NTE
                                                                                           ANR
                                                                                           DUB
                                                                                           FLR
                                                                                           CMF
                                                                                           MAD
                                                                                           BHD
                                                                                           GLA
                                                                                           BRE])
  end

  it "4" do
    expect(g.V().has("code", "LHR").out("route").has("country",
                                                     "US").values("code").toList).to eq(%w[PDX CLT ATL AUS BOS BWI DFW
                                                                                           IAD IAH JFK LAX MIA MSP ORD
                                                                                           PHX RDU SEA SFO SJC SAN SLC
                                                                                           LAS DEN MSY EWR PHL DTW])
  end

  it "5" do
    expect(g.V().has("airport", "code", "LCY").outE.inV.path.count.next).to eq(42)
  end

  it "6" do
    expect(
      g.V().has("airport", "code", "LCY").outE.inV
            .path.by("code").by("dist").count.next
    ).to eq(42)

    expect(
      g.V().has("airport", "code", "LCY").outE.inV
            .path.by("code").by("dist").by("code").count.next
    ).to eq(42)

    expect(
      g.V().has("airport", "code", "LCY").outE.inV.path.by("code").by("dist").by("city").count.next
    ).to eq(42)

    expect(
      g.V().has("airport", "code", "LCY").outE.inV
      .path.by("code").by("dist").by("city").count.next
    ).to eq(42)
  end

  it "7" do
    expect(
      g.V(3).out.limit(5).path.by(__.values("code", "city").fold).count.next
    ).to eq(5)
  end

  it "8" do
    expect(
      g.V(3).out.limit(5).path.by(__.out.count.fold).count.next
    ).to eq(5)
  end

  it "9" do
    expect(
      g.V().has("airport", "code", "AUS").out.out.path.by("code").limit(10).count.next
    ).to eq(10)
    expect(
      g.V().has("airport", "code", "AUS").out.as("a").out
            .path.by("code").from("a").limit(10).count.next
    ).to eq(10)

    expect(
      g.V().has("airport", "code", "AUS").out.out.out
            .path.by("code").limit(10).count.next
    ).to eq(10)

    expect(
      g.V().has("airport", "code", "AUS").out.as("a").out.as("b").out
      .path.by("code").from("a").to("b").limit(10).count.next
    ).to eq(10)

    expect(
      g.V().has("airport", "code", "AUS").out.out.as("b").out
      .path.by("code").to("b").limit(10).count.next
    ).to eq(10)

    expect(
      g.V().has("airport", "code", "AUS").as("a").out.out.as("b").out
      .path.by("code").to("b").limit(10).dedup.count.next
    ).to eq(1)
  end

  it "10" do
    expect(g.V().has("code", "AUS").out("route").has("code", "DFW").hasNext).to be_truthy
    expect(g.V().has("code", "AUS").out("route").has("code", "SYD").hasNext).to be_falsey
  end

  it "11" do
    expect(
      g.V().has("code", "DFW").as("from").out
            .has("region", "US-CA").as("to")
            .select("from", "to").count.next
    ).to eq(11)

    expect(
      g.V().has("code", "DFW").as("from").out
            .has("region", "US-CA").as("to")
            .select("from", "to").by("code").count.next
    ).to eq(11)

    expect(
      g.V().has("code", "DFW").out
            .has("region", "US-CA")
            .path.by("code").count.next
    ).to eq(11)
  end

  it "12" do
    expect(
      g.V().has("type", "airport").limit(10).as("a", "b", "c")
            .select("a", "b", "c")
              .by("code").by("region").by(__.out.count).count.next
    ).to eq(10)

    expect(
      g.V().has("type", "airport").limit(10)
            .project("a", "b", "c")
              .by("code").by("region").by(__.out.count).count.next
    ).to eq(10)
  end

  it "13" do
    expect(g.V(1).as("a").V(2).as("a").select("a").next).to eq(Grumlin::Vertex.new(label: "airport", id: 2))
    expect(g.V(1).as("a").V(2).as("a").select(Pop.first, "a").next).to eq(Grumlin::Vertex.new(label: "airport", id: 1))
    expect(g.V(1).as("a").V(2).as("a").select(Pop.last, "a").next).to eq(Grumlin::Vertex.new(label:  "airport", id: 2))

    expect(g.V(1).as("a").V(2).as("a").select(Pop.all, "a").next).to eq([Grumlin::Vertex.new(label:  "airport", id: 1),
                                                                         Grumlin::Vertex.new(label:  "airport", id: 2)])
  end

  it "14" do
    expect(
      g.V().has("code", "AUS").as("a")
    .out.as("a").limit(10)
    .select(Pop.last, "a").by("code").fold.next
    ).to eq(%w[YYZ LHR FRA MEX PIT PDX CLT
               CUN MEM CVG])

    expect(
      g.V().has("code", "AUS").as("a")
    .out.as("a").limit(10)
    .select(Pop.first, "a").by("code").fold.next
    ).to eq(%w[AUS AUS AUS AUS AUS AUS AUS
               AUS AUS AUS])

    expect(
      g.V().has("code", "AUS").as("a")
    .out.as("a").limit(10)
    .select(Pop.all, "a").unfold.values("code").fold.next
    ).to eq(%w[AUS AUS AUS AUS AUS AUS
               AUS AUS AUS AUS YYZ LHR FRA MEX PIT PDX CLT CUN MEM CVG])
  end

  it "15" do
    expect(
      g.V().has("code", "LAX")
      .out
      .out
      .out
      .out
      .out
      .limit(1)
      .path.by("code").next.objects
    ).to eq(%w[LAX YYC BNA BWI YYZ ZRH])

    expect(
      g.V().has("code", "LAX")
      .out.as("stop")
      .out
      .out.as("stop")
      .out
      .out.as("stop")
      .limit(1)
      .select(Pop.all, "stop")
      .unfold
      .values("code").fold.next
    ).to eq(%w[YYC BWI ZRH])
  end

  it "16" do
    expect(g.V().has("code", "MIA").outE.as("e").inV.has("code", "DFW").select("e").next.inspect).to eq("e[4123][16-route->8]")
    expect(
      g.V().has("code", "MIA").outE.as("e")
        .inV.has("code", "DFW").select("e").values("dist").next
    ).to eq(1120)
  end

  it "17" do
    expect(g.V().hasLabel("airport").values("code").limit(20).toList.count).to eq(20)
    expect(g.V().hasLabel("airport").values("code").tail(20).toList.count).to eq(20)
    expect(g.V().hasLabel("airport").limit(20).values("code").toList.count).to eq(20)
    expect(g.V().hasLabel("airport").range(0, 20).values("code").toList.count).to eq(20)

    expect(g.V().has("airport", "code", "AUS")
      .repeat(__.timeLimit(10).out).until(__.has("code", "LHR")).path.by("code").toList.count).not_to eq(0)
  end

  it "18" do
    expect(g.V().hasLabel("airport").range(0, 2).toList.count).to eq(2)
    expect(g.V().hasLabel("airport").range(3, 6).toList.count).to eq(3)
    expect(g.V().range(3500, -1).toList.count).to eq(119)
    expect(g.V().hasLabel("country").range(0, 2).toList.count).to eq(2)
    expect(g.V().has("region", "US-TX").skip(5).fold.toList[0].count).to eq(21)
    expect(g.V().has("region", "US-TX").range(5, -1).fold.toList[0].count).to eq(21)
    expect(g.V().has("region", "US-TX").fold.skip(Scope.local, 3).toList[0].count).to eq(23)
  end

  it "19" do
    expect(g.V().has("region", "GB-ENG").values("runways").fold.toList[0]).to eq([2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 2, 2, 1, 3, 1, 3, 3, 4, 1, 1])
    expect(g.V().has("region", "GB-ENG").values("runways").dedup.fold.toList[0]).to eq([2, 1, 3, 4])
    expect(g.V().has("region", "GB-ENG").dedup.by("runways")
      .values("code", "runways").fold.toList[0]).to eq(["LHR", 2, "LCY", 1, "BLK", 3, "LEQ", 4])

    expect(g.V(3).as("a").V(4).as("c").both.as("b").limit(10)
      .select("a", "b", "c").toList.count).to eq(10)
    expect(g.V(3).as("a").V(4).as("c").both.as("b").limit(10)
      .dedup("a", "c").select("a", "b", "c").toList.count).to eq(1)
  end

  it "20" do
    expect(g.V().has("code", "AUS").valueMap.unfold.toList).to eq([{ country: ["US"] },
                                                                   { code: ["AUS"] },
                                                                   { longest: [12_250] },
                                                                   { city: ["Austin"] },
                                                                   { elev: [542] },
                                                                   { icao: ["KAUS"] },
                                                                   { lon: [-97.6698989868164] },
                                                                   { type: ["airport"] },
                                                                   { region: ["US-TX"] },
                                                                   { runways: [2] },
                                                                   { lat: [30.1944999694824] },
                                                                   { desc: ["Austin Bergstrom International Airport"] }])
    expect(g.V().has("code", "AUS").valueMap(true).unfold.toList).to eq([{ T.id => 3 },
                                                                         { T.label => "airport" },
                                                                         { country: ["US"] },
                                                                         { code: ["AUS"] },
                                                                         { longest: [12_250] },
                                                                         { city: ["Austin"] },
                                                                         { elev: [542] },
                                                                         { icao: ["KAUS"] },
                                                                         { lon: [-97.6698989868164] },
                                                                         { type: ["airport"] },
                                                                         { region: ["US-TX"] },
                                                                         { runways: [2] },
                                                                         { lat: [30.1944999694824] },
                                                                         { desc: ["Austin Bergstrom International Airport"] }])
    expect(g.V().has("code", "AUS").valueMap(true, "region").next).to eq({ T.id => 3, T.label => "airport", region: ["US-TX"] })
    expect(g.V().has("code", "AUS").valueMap.select("code", "icao", "desc").next).to eq({ code: ["AUS"], desc: ["Austin Bergstrom International Airport"], icao: ["KAUS"] })
    expect(g.V().has("code", "AUS").valueMap(true, "code", "icao", "desc", "city").unfold.toList).to eq([{ T.id => 3 },
                                                                                                         { T.label => "airport" },
                                                                                                         { code: ["AUS"] },
                                                                                                         { city: ["Austin"] },
                                                                                                         { icao: ["KAUS"] },
                                                                                                         { desc: ["Austin Bergstrom International Airport"] }])
    expect(g.E(5161).valueMap(true).next).to eq({ dist: 1357, T.id => 5161, T.label => "route" })
    expect(g.V().has("code", "SFO").valueMap.with(WithOptions.tokens).unfold.toList).to eq([{ T.id => 23 },
                                                                                            { T.label => "airport" },
                                                                                            { country: ["US"] },
                                                                                            { code: ["SFO"] },
                                                                                            { longest: [11_870] },
                                                                                            { city: ["San Francisco"] },
                                                                                            { elev: [13] },
                                                                                            { icao: ["KSFO"] },
                                                                                            { lon: [-122.375] },
                                                                                            { type: ["airport"] },
                                                                                            { region: ["US-CA"] },
                                                                                            { runways: [4] },
                                                                                            { lat: [37.6189994812012] },
                                                                                            { desc: ["San Francisco International Airport"] }])
    expect(g.V().has("code", "SFO").valueMap("code").with(WithOptions.tokens).unfold.toList).to eq([{ T.id => 23 }, { T.label => "airport" }, { code: ["SFO"] }])
    expect(g.V().has("code", "SFO")
      .valueMap("code").with(WithOptions.tokens, WithOptions.labels)
      .unfold.toList).to eq([{ T.label => "airport" }, { code: ["SFO"] }])
    expect(g.V().has("code", "SFO")
      .valueMap("code").with(WithOptions.tokens, WithOptions.ids)
      .unfold.toList).to eq([{ T.id => 23 }, { code: ["SFO"] }])
    expect(g.V().has("code", "SFO").valueMap.by(__.unfold).unfold.toList).to eq([{ country: "US" },
                                                                                 { code: "SFO" },
                                                                                 { longest: 11_870 },
                                                                                 { city: "San Francisco" },
                                                                                 { elev: 13 },
                                                                                 { icao: "KSFO" },
                                                                                 { lon: -122.375 },
                                                                                 { type: "airport" },
                                                                                 { region: "US-CA" },
                                                                                 { runways: 4 },
                                                                                 { lat: 37.6189994812012 },
                                                                                 { desc: "San Francisco International Airport" }])
  end

  it "21" do
    expect(g.V().has("code", "AUS").elementMap.unfold.toList).to eq([{ T.id => 3 },
                                                                     { T.label => "airport" },
                                                                     { country: "US" },
                                                                     { code: "AUS" },
                                                                     { longest: 12_250 },
                                                                     { city: "Austin" },
                                                                     { elev: 542 },
                                                                     { icao: "KAUS" },
                                                                     { lon: -97.6698989868164 },
                                                                     { type: "airport" },
                                                                     { region: "US-TX" },
                                                                     { runways: 2 },
                                                                     { lat: 30.1944999694824 },
                                                                     { desc: "Austin Bergstrom International Airport" }])

    expect(g.V().has("code", "AUS").elementMap("city").toList).to eq([{ city: "Austin", T.id => 3, T.label => "airport" }])
    expect(g.V(3).outE.limit(1).elementMap.toList).to eq([{ :IN => { T.id => 47, T.label =>  "airport" },
                                                            :OUT => { T.id => 3, T.label =>  "airport" },
                                                            :dist => 1357,
                                                            T.id => 5161,
                                                            T.label => "route" }])
    expect(g.E(5161).project("v", "IN", "OUT")
      .by(__.valueMap(true))
      .by(__.inV.union(__.id, __.label).fold)
      .by(__.outV.union(__.id, __.label).fold).toList).to eq([{ IN: [47, "airport"],
                                                                OUT: [3, "airport"],
                                                                v: { dist: 1357, T.id => 5161, T.label => "route" } }])

    expect(
      g.E(5161).project("v", "IN", "OUT")
                  .by(__.valueMap(true))
                  .by(__.project("id", "label")
                    .by(__.inV.id)
                    .by(__.inV.label))
                  .by(__.project("id", "label")
                    .by(__.outV.id)
                    .by(__.outV.label))
                  .unfold.toList
    ).to eq([{ v: { dist: 1357, T.id => 5161, T.label => "route" } },
             { IN: { id: 47, label: "airport" } },
             { OUT: { id: 3, label: "airport" } }])
  end
end
