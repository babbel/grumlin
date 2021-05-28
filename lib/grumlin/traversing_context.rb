# frozen_string_literal: true

module Grumlin
  class TraversingContext
    def self.V(id) # rubocop:disable Naming/MethodName
      { "@type": "g:Bytecode", "@value": { step: [["V", { "@type": "g:Int32", "@value": id }]] } }
    end
  end
end
