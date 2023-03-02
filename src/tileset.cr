require "scar"

class Tileset < Scar::Components::Drawable
  include Scar
  getter drawable : SF::VertexBuffer
  property tiles : Array(Int32)
  property width : Int32
  property height : Int32
  property tile_width : Int32
  property tile_height : Int32
  property tiles : Array(Array(Int32))

  def initialize(@tiles : Array(Array(Int32)), @tile_width, @tile_height, @texture)
    @drawable = SF::VertexBuffer.new(SF::PrimitiveType::Triangles, SF::VertexBuffer::Usage::Static)
    @width = tiles.size
    @height = tiles[0].size

    update_tiles
  end

  def initialize(width, height, tile_width, tile_height, texture)
    initialize(Array.new(width) { Array.new height, 0 }, tile_width, tile_height, texture)
  end

  # Sets all tiles to 0
  def clear
    @tiles.each { |row| row.map! { 0 } }
    update_tiles
  end

  def update_tiles
    verts = [] of SF::Vertex
    tw = tile_width
    th = tile_height
    tex_row_width_in_tiles = @texture.size.x // tw

    tiles.each_with_index do |row, i|
      row.each_with_index do |tile, j|
        next if tile == 0
        tile -= 1 # tiles are 1-indexed, but texture is 0-indexed

        x = i * tw
        y = j * th
        tx = (tile % tex_row_width_in_tiles) * tw
        ty = (tile // tex_row_width_in_tiles) * th

        verts << SF::Vertex.new({x, y}, {tx, ty})
        verts << SF::Vertex.new({x, y + th}, {tx, ty + th})
        verts << SF::Vertex.new({x + tw, y}, {tx + tw, ty})

        verts << SF::Vertex.new({x + tw, y}, {tx + tw, ty})
        verts << SF::Vertex.new({x, y + th}, {tx, ty + th})
        verts << SF::Vertex.new({x + tw, y + th}, {tx + tw, ty + th})
      end

      @drawable.create verts.size
      @drawable.update verts, 0
    end
  end
end
