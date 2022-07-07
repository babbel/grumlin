# frozen_string_literal: true

module Grumlin
  module Sugar
    def self.included(base)
      base.include(Grumlin::Expressions)
    end

    %i[__ g].each do |name|
      define_method name do |shortcuts = Grumlin::Shortcuts::Storage.new|
        shortcuts.send(name)
      end
    end
  end
end
