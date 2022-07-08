# frozen_string_literal: true

RSpec.describe Grumlin::Shortcuts::Upserts do
  describe "shortcut upsertV" do
    # Upserts using coalesce
    # https://stackoverflow.com/questions/49758417/cosmosdb-graph-upsert-query-pattern
    it "uses coalesce to upsert a vertex" do
      t = Grumlin::Shortcuts::Properties.shortcuts.__
      result = described_class.shortcuts[:upsertV].apply(t, "test", 1, { a: 1 }, { b: 2 })
      expect(result.bytecode.serialize).to eq({
                                                step:
                                                  [
                                                    [:V, 1],
                                                    [:fold],
                                                    [:coalesce, { :@type => "g:Bytecode", :@value => { step: [[:unfold]] } },
                                                     {
                                                       :@type => "g:Bytecode",
                                                       :@value => {
                                                         step: [
                                                           [:addV, "test"],
                                                           [:property, :a, 1],
                                                           [:property, { :@type => "g:T", :@value => :id }, 1]
                                                         ]
                                                       }
                                                     }],
                                                    [:property, :b, 2]
                                                  ]
                                              })
    end
  end

  it "uses coalesce to upsert an edge" do
    t = Grumlin::Shortcuts::Properties.shortcuts.__
    result = described_class.shortcuts[:upsertE].apply(t, "test", 1, 2, { a: 1 }, { b: 2 })
    expect(result.bytecode.serialize).to eq({
                                              step: [
                                                [:V, 1],
                                                [:outE, "test"],
                                                [:where, { :@type => "g:Bytecode", :@value => { step: [[:inV], [:hasId, 2]] } }],
                                                [:fold],
                                                [:coalesce, { :@type => "g:Bytecode", :@value => { step: [[:unfold]] } },
                                                 {
                                                   :@type => "g:Bytecode", :@value => {
                                                     step: [
                                                       [:addE, "test"],
                                                       [:from, { :@type => "g:Bytecode", :@value => { step: [[:V, 1]] } }],
                                                       [:to, { :@type => "g:Bytecode", :@value => { step: [[:V, 2]] } }],
                                                       [:property, :a, 1]
                                                     ]
                                                   }
                                                 }],
                                                [:property, :b, 2]
                                              ]
                                            })
  end
end
