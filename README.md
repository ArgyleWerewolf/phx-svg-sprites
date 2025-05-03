# Phoenix SVG Sprites

![SVG Sprites Example](preview.png?raw=true)

Easily combine all of your SVG assets into a single file and display them individually in your Phoenix LiveView project.

## Features

- 🛠 **Mix Task** - Automatically combines SVGs into a sprite sheet
- 📦 **Zero Dependencies** - Pure Elixir/Phoenix solution
- 🎨 **LiveView Component** - Simple syntax for using sprites in templates
- 🏷 **ID Prefixing** - Namespace support for multiple sprite sheets
- 🧩 **Flexible Styling** - Works with Tailwind, arbitrary CSS, and `currentColor`

## Installation

Add to your `mix.exs`:

```elixir
def deps do
  [
    {:phoenix_svg_sprites, git: "https://github.com/ArgyleWerewolf/phx-svg-sprites.git"}
  ]
end
```

## Usage

### 1. Generate Sprite Sheet

Run the mix task to process your SVGs:

```bash
mix phoenix_svg_sprites \
  --dirs "assets/svg_sprites,assets/custom_icons" \
  --output-dir "priv/static/assets/" \
  --id-prefix "custom" \
  --verbose
```

#### Options

`--dirs`: Comma-separated directories to search (default: assets/svg_sprites)

`--output-dir`: Output directory (default: priv/static/assets/)

`--output-file`: Output filename (default: sprites.svg)

`--id-prefix`: Prefix for namespacing IDs and filename (default: none)

`--verbose`: Show detailed processing info

### 2. Use in LiveView

Import the component and use it in your HEEX templates:

```elixir
# In your_web.ex's html_helpers
import PhoenixSvgSprites.Sprite

# In templates
<.sprite icon="user" />
<.sprite icon="alert" dimensions="h-8 w-8" class="text-red-400 hover:scale-110 transition-transform" />
<.sprite icon="illustration" title="An illustration of a mountainous landscape at sunset" class="object-cover" />
```

## Advanced Usage

### Multiple Sprite Sheets

Use different prefixes for separate sprite sheets:

```bash
# Generate
mix phoenix_svg_sprites --id-prefix "social"

# Use
<.sprite icon="twitter" id_prefix="social">
```

### Dynamic Attributes

Pass any valid SVG attributes, including Phoenix DOM element bindings and data attributes:

```Elixir
<.sprite
  icon="checkmark"
  phx-click="confirm"
  data-confirm="Are you sure?"
/>
```

## Development

To contribute:

```bash
cd phx-svg-sprites
mix deps.get
mix test
```

## Acknowledgements

- Transforms and extends SVG-merging work done by [@markolson](https://github.com/markolson) and I [a few years ago](https://github.com/Allovue/phoenix-sprite-sheet). 🥔🤝🐺
- Sample SVGs in the screenshot are licensed from Satria Arnata's [Nature & Eco-Friendly icon set](https://thenounproject.com/browse/collection-icon/nature-eco-friendly-solid-276616/) from Noun Project.

## License
MIT © 2025 ArgyleWerewolf
