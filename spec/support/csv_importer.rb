# frozen_string_literal: true

class CSVImporter
  TYPES = {
    "string" => :to_s,
    "int" => :to_i,
    "double" => :to_f
  }.freeze

  include Grumlin::U
  include Grumlin::T

  def initialize(client, nodes, edges)
    @client = client
    @nodes = nodes
    @edges = edges
  end

  def import!
    import_nodes!
    import_edges!
  end

  private

  def import_nodes!
    casted_nodes.each_slice(100) do |batch|
      t = g
      batch.each do |node|
        t = t.addV(node.delete("~label")).property(T.id, node.delete("~id"))
        node.compact.each do |k, v|
          t = t.property(k.split(":")[0], v)
        end
      end
      t.iterate
    end
  end

  def import_edges! # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    casted_edges.each_slice(100) do |batch|
      t = g
      batch.each do |edge|
        t = t.addE(edge.delete("~label")).property(T.id, edge.delete("~id"))
             .from(U.V(edge.delete("~from")))
             .to(U.V(edge.delete("~to")))
        edge.compact.each do |k, v|
          t = t.property(k.split(":")[0], v)
        end
      end
      t.iterate
    end
  end

  def g
    Grumlin::Traversal.new(@client)
  end

  def casted_nodes
    @nodes.each_with_index.map do |row, index|
      next if index.zero?

      row.each_with_object({}) do |(k, v), acc|
        k, v = cast_property(k, v)
        acc[k] = v
      end
    end.compact
  end

  def casted_edges
    @edges.each_with_index.map do |row, index|
      next if index.zero?

      row.each_with_object({}) do |(k, v), acc|
        k, v = cast_property(k, v)
        acc[k] = v
      end
    end.compact
  end

  def cast_property(name, value)
    return [name, value.to_s] if name == "~label"
    return [name, value.to_i] if ["~id", "~from", "~to"].include?(name)

    name, type = name.split(":")
    cast_method = TYPES[type]
    value = value.nil? ? value : value.send(cast_method)
    [name, value]
  end
end
