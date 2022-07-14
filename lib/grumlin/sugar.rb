# frozen_string_literal: true

module Grumlin
  module Sugar
    def self.included(base)
      base.include(Grumlin::Expressions)
    end

    %i[__ g].each do |name|
      define_method name do |cuts = Shortcuts::Storage.empty|
        cuts.send(name)
      end
    end
  end
end
