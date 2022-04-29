# frozen_string_literal: true

RSpec.describe Grumlin::Shortcuts::Upserts do
  describe "shortcut upsertV" do
    # Upserts using coalesce
    # https://stackoverflow.com/questions/49758417/cosmosdb-graph-upsert-query-pattern
    it "uses coalesce to upsert a vertex" do
      t = Grumlin::TraversalStart.new(Grumlin::Shortcuts::Properties.shortcuts)
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
end
