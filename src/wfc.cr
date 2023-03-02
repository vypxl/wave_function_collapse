require "scar"
require "./tileset"

class WFCRules
  include YAML::Serializable

  @[YAML::Field(key: "rules")]
  property rules : Hash(Int32, Array(Set(Int32)))
end

class WFC < Scar::System
  include Scar

  @wave : Array(Array(Set(Int32) | Nil | Int32))

  def initialize(@ts : Tileset, @rules : WFCRules)
    @width = @ts.width
    @height = @ts.height
    @wave = Array.new(@width) { Array(Set(Int32) | Nil | Int32).new(@height) { nil } }
    reset()
  end

  def init(app, space)
    app.subscribe(Event::KeyPressed) do |e|
      if e.code == SF::Keyboard::Key::R
        reset()
      elsif e.code == SF::Keyboard::Key::Space
        reset
        while generate_step
        end
      end
    end
  end

  def update(app, space, dt)
  end

  def reset
    @wave.each { |r| r.map! { nil } }
    @wave[1][1] = Set{98}
    @ts.clear
  end

  private def update_neighbors(x, y)
    return if x < 0 || y < 0 || x >= @width || y >= @height
    tile = @wave[x][y]
    return if tile.nil?

    [{0, -1}, {0, 1}, {-1, 0}, {1, 0}].each_with_index do |delta, dir|
      dx, dy = delta
      next if x + dx < 0 || y + dy < 0 || x + dx >= @width || y + dy >= @height
      neigh = @wave[x + dx][y + dy]
      next if neigh.is_a? Int32
      choices =
        if tile.is_a? Int32
          @rules.rules[tile][dir]
        else
          tmp = tile.map { |t| @rules.rules[t][dir] }

          # This is here to avoid the empty enumerable exception
          if tmp.size > 0
            tmp.reduce { |a, b| a | b }
          else
            Set(Int32).new
          end
        end

      should_update = true
      @wave[x + dx][y + dy] =
        if neigh.nil?
          choices
        else
          new = neigh & choices
          should_update = new.size != neigh.size
          new
        end
      update_neighbors(x + dx, y + dy) if should_update
    end
  end

  def generate_step
    min = @width * @height
    tile_choices = nil
    coords = {0, 0}
    @wave.each_with_index do |row, x|
      row.each_with_index do |cell, y|
        if cell.is_a? Set && cell.size < min && cell.size > 0
          min = cell.size
          tile_choices = cell
          coords = {x, y}
        end
      end
    end

    x, y = coords

    if tile_choices.nil?
      return false
    end

    choice = tile_choices.sample
    @wave[x][y] = choice

    update_neighbors(x, y)

    @ts.tiles[x][y] = choice
    @ts.update_tiles
    return true
  end
end
