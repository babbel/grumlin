# frozen_string_literal: true

module Grumlin
  module Shortcuts
    module Upserts
      extend Grumlin::Shortcuts

      shortcut :upsertV do |label, id, create_properties = {}, update_properties = {}|
        self.V(id)
            .fold
            .coalesce(
              __.unfold,
              __.addV(label).props(**create_properties.merge(T.id => id))
            ).props(**update_properties)
      end

      shortcut :upsertE do |label, from, to, create_properties = {}, update_properties = {}|
        id = Grumlin.fake_uuid_from("#{label}/#{from}/#{to}")

        self.V(from)
            .outE(label).where(__.hasId(id).and.or.inV.hasId(to))
            .fold
            .coalesce(
              __.unfold,
              __.V(from).addE(label).to(__.V(to)).props(**create_properties.merge(T.id => id))
            ).props(**update_properties)
      end
    end
  end
end
