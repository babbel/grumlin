# frozen_string_literal: true

module Grumlin
  module Shortcuts
    module Upserts
      extend Grumlin::Shortcuts

      shortcut :upsertV do |label, id, create_properties, update_properties|
        self.V(id)
            .fold
            .coalesce( # TODO: extract upsert pattern to a shortcut
              __.unfold,
              __.addV(label).props(**create_properties.merge(T.id => id))
            ).props(**update_properties)
      end
    end
  end
end
