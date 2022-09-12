# frozen_string_literal: true

module Grumlin::Sugar
  def self.included(base)
    base.include(Grumlin::Expressions)
  end

  [:__, :g].each do |name|
    define_method name do |cuts = Grumlin::Shortcuts::Storage.empty|
      cuts.send(name)
    end
  end
end
