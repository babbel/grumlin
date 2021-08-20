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
      g.V(3).out.limit(5).path.by(Grumlin::U.values("code", "city").fold).count.next
    ).to eq(5)
  end

  it "8" do
    expect(
      g.V(3).out.limit(5).path.by(Grumlin::U.out.count.fold).count.next
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

  xit "10" do
    # TODO: add support for hasNext
    expect(g.V().has("code", "AUS").out("route").has("code", "DFW").hasNext).to eq([])
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
              .by("code").by("region").by(Grumlin::U.out.count).count.next
    ).to eq(10)

    expect(
      g.V().has("type", "airport").limit(10)
            .project("a", "b", "c")
              .by("code").by("region").by(Grumlin::U.out.count).count.next
    ).to eq(10)
  end

  it "13" do
    expect(g.V(1).as("a").V(2).as("a").select("a").next).to eq(Grumlin::Vertex.new(label: "airport", id: 2))
    expect(g.V(1).as("a").V(2).as("a").select(Grumlin::Pop.first,
                                              "a").next).to eq(Grumlin::Vertex.new(label: "airport", id: 1))
    expect(g.V(1).as("a").V(2).as("a").select(Grumlin::Pop.last,
                                              "a").next).to eq(Grumlin::Vertex.new(label: "airport", id: 2))

    expect(g.V(1).as("a").V(2).as("a").select(Grumlin::Pop.all,
                                              "a").next).to eq([Grumlin::Vertex.new(label: "airport", id: 1),
                                                                Grumlin::Vertex.new(label: "airport", id: 2)])
  end

  it "14" do
    expect(
      g.V().has("code", "AUS").as("a")
    .out.as("a").limit(10)
    .select(Grumlin::Pop.last, "a").by("code").fold.next
    ).to eq(%w[YYZ LHR FRA MEX PIT PDX CLT
               CUN MEM CVG])

    expect(
      g.V().has("code", "AUS").as("a")
    .out.as("a").limit(10)
    .select(Grumlin::Pop.first, "a").by("code").fold.next
    ).to eq(%w[AUS AUS AUS AUS AUS AUS AUS
               AUS AUS AUS])

    expect(
      g.V().has("code", "AUS").as("a")
    .out.as("a").limit(10)
    .select(Grumlin::Pop.all, "a").unfold.values("code").fold.next
    ).to eq(%w[AUS AUS AUS AUS AUS AUS
               AUS AUS AUS AUS YYZ LHR FRA MEX PIT PDX CLT CUN MEM CVG])
  end
end
