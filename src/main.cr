require "scar"
require "./tileset"
require "./wfc"

class App < Scar::App
  include Scar

  def init
    Input.bind_digital(:Closed) { Input.key_pressed?(:Escape) }
    Input.bind_digital(:Closed) { Input.key_pressed?(:Q) }
    subscribe(Event::Closed) { exit }

    Assets.use "assets"
    Assets.load_all
    Assets.load "rules.yml", Assets::Text

    self << Scene.new(
      Space.new("main")
    )

    ts = Tileset.new(32, 24, 32, 32, Assets.texture("terrain.png"))

    scene["main"] << Entity.new("tiles", ts)
    scene["main"] << WFC.new(ts, WFCRules.from_yaml(Assets.text("rules.yml")))
  end

  def update(dt)
    broadcast(Event::Closed.new) if Input.active?(:Closed)
  end

  def render(dt)
    @window.clear(SF::Color::Cyan)
  end
end

window = SF::RenderWindow.new(SF::VideoMode.new(1024, 768), "Wave function collapse", SF::Style::Close)

app = App.new(window)
app.run
