# Latin declension tables

<p align="center">
  <a href="https://gferraz.github.io/latin/">
    <img src="https://img.shields.io/badge/View_the_tables-GitHub_Pages-8a2b1e?style=for-the-badge&labelColor=2a2118" alt="View the tables on GitHub Pages">
  </a>
</p>

Renders a static HTML table of Latin noun declensions — all five declensions,
six cases, three genders, singular and plural — from a single Ruby data model.

Output: [`dist/declinationes.html`](dist/declinationes.html). Two tables —
`Singularis` and `Pluralis` — with 5 × 3 = 15 ending columns plus the case
column, and footnotes for the general-rule exceptions.

## Requirements

- Ruby 3.0 or newer (the code uses endless method definitions)
- Slim and Minitest: `gem install slim minitest`

There is no Gemfile or lockfile.

## Usage

```sh
bin/build      # or: ruby build.rb
```

That produces two files from the same template:

| Output                     | Mode    | Use                                                                                                          |
| -------------------------- | ------- | ------------------------------------------------------------------------------------------------------------ |
| `build/declinationes.html` | linked  | Development. `<link>`s and a `<script src>` point at `assets/`, so edits to the CSS or JS show up on reload. |
| `dist/declinationes.html`  | inlined | Distribution. The CSS and JS are embedded, so the single file works on its own.                              |

For a one-off preview to stdout:

```sh
ruby render.rb > /tmp/p.html   # embeds CSS and JS; can be saved anywhere
```

Both scripts work from any working directory.

## Tests

```sh
ruby test/declinationes_test.rb
```

Covers metadata, ending lookups, immutability, argument validation, and the
rendered table structure (row spans, empty cells, footnotes). The suite renders
the template directly in `:inlined` mode, so it exercises what `dist/` ships.

## Project layout

| File                         | Purpose                                                                      |
| ---------------------------- | ---------------------------------------------------------------------------- |
| `latin.rb`                   | `Declinationes` class: grammatical metadata, endings, exceptions, validation |
| `declinationes.html.slim`    | Slim page template (markup and the inline/linked switch)                     |
| `assets/screen.css`          | Screen styles                                                                |
| `assets/print.css`           | `@media print` block                                                         |
| `assets/desinentiae.js`      | Ending-highlight script                                                      |
| `page.rb`                    | Renders the template; loads `assets/` and exposes `render_page`              |
| `build.rb`                   | Calls `render_page` twice: linked into `build/`, inlined into `dist/`        |
| `bin/build`                  | Shell wrapper so the build runs without naming `ruby`                        |
| `render.rb`                  | Calls `render_page` once, to stdout                                          |
| `build/declinationes.html`   | Generated; linked to `assets/`                                               |
| `dist/declinationes.html`    | Generated; self-contained, the one to distribute                             |
| `test/declinationes_test.rb` | Minitest suite                                                               |

Grammatical data lives in the Ruby model, markup in the Slim template, and
styling and behaviour in `assets/`. The template takes a `mode` (`:linked` or
`:inlined`) and an `asset_prefix`, and `page.rb` supplies the asset text — so
`assets/` is the only copy of the CSS and JS. The template decides where they
go, never what they contain.

## API

```ruby
require_relative 'latin'

tabula = Declinationes.new

tabula.casus          # => [:nominativus, :vocativus, :accusativus,
                      #     :genitivus, :dativus, :ablativus]
tabula.genera         # => [:m, :f, :n]
tabula.declinationes  # => [1, 2, 3, 4, 5]
tabula.numeri         # => [:singularis, :pluralis]
tabula.columnae       # => 15   (declensions × genders)
tabula.notae          # => [...] footnotes, sorted by declension, gender, case

tabula.omnes_desinentiae
# => ["a", "us", "um", ...]   every ending, counted once per table cell

tabula.unique?("ōrum")        # => true   (appears in only one cell)
tabula.unique?("ae")          # => false  (many cases and declensions)

tabula.desinentiae(:genitivus, :singularis, 2)
# => { mf: ["ī"], n: ["ī"] }

tabula.desinentiae(:nominativus, :singularis, 3)
# => {}   # third declension endings vary, so the cell is left blank
```

`desinentiae` never returns `nil` — an absent entry yields `{}`. It raises
`ArgumentError` for an unknown case, number, or declension, so a typo fails
loudly instead of blanking a cell.

Data can be injected for testing or experimentation:

```ruby
Declinationes.new(nominativus: { singularis: { 1 => { mf: %w[x] } } })
```

## Data model

`Declinationes::DESINENTIAE` is nested as
`case → number → declension → gender → [endings]`:

- `mf` — one ending shared by masculine and feminine (first through fourth
  declensions)
- `f` — feminine only, used by the fifth declension: the masculine and neuter
  columns stay blank
- `n` — neuter

Endings are stored without the leading hyphen; the template adds it. Multiple
variants are joined for display, e.g. `ēs īs` renders as `-ēs / -īs`. The
stored hash is deeply frozen, and so is any data passed to `new`.

`omnes_desinentiae` lists every ending once per cell, and `unique?` is true when
an ending occurs in exactly one cell — so endings shared by m./f./n. inside a
single cell (e.g. `-ōrum`) still count as unique, while those repeated across
cases (e.g. `-ae`, `-ibus`) do not.

## Styling

The page is set as a classical textbook: parchment background, Cardo from Google
Fonts (with a Georgia/Times serif fallback) for text and headings, small-caps case
names and captions, Roman-numeral declension headings, zebra striping, thin
vertical rules on the content cells, and the genitive row picked out in a warm
accent. Endings that are unique across the whole table are rendered in bold.

Each declension group is closed off by a heavier mid-tone separator, including a
line before the first group so the endings are fenced off from the case-name
column. The same mid-tone draws the horizontal rule under the gender headings.

Cardo is the only webfont, used for body text and headings alike. EB Garamond was
tried first but was dropped: its `u` is easily mistaken for `v` at table size.

Hovering an ending cell highlights every cell that shares an ending with it. Each
ending cell carries a `data-desinentiae` attribute listing its endings, and a
small script toggles the `desinentia-match` class on the matches. Cells that offer
alternatives (such as `-ibus / -ubus`) match on any of their endings.
Matching ignores macrons and counts each cell once. The detail panel lists the
represented cases, numbers, declensions, and genders, sorted by case and
declension while preserving the exact spellings. It also opens on keyboard
focus or tap; Escape closes it.
A Portuguese legend explains bold endings, shared gender cells, blank cells for
genders absent from the regular paradigm, macrons, and why an ending alone does
not determine a noun's analysis. The legend also prints.

Because the fonts come from Google Fonts, an offline viewer falls back to the
local serif stack. `assets/print.css` carries the `@media print` block, which
sets up the landscape page, hides the background tints, and keeps the tables
from breaking across pages.

## Conventions

- Latin for anything carrying grammatical meaning: class and method names
  (`casus`, `genera`, `desinentiae`), constants (`DESINENTIAE`, `CASUS`), and
  data keys (`:nominativus`, `:singularis`). English for plain behaviour
  (`initialize`, `validate!`, `deep_freeze`).
- Preserve UTF-8 macrons (`ā ē ī ō ū`) — they distinguish the endings.
- Two-space indentation, `snake_case` files, `CamelCase` classes.
- No formatter or linter is configured.

## Scope

The table is a **general rule, not a comprehensive paradigm**: irregular nouns
and rare variants are deliberately excluded from the cells and listed as
footnotes instead (`Declinationes::NOTAE`) — for example _diēs_ and
_merīdiēs_ are masculine fifth-declension nouns, and nouns in _-er_/_-ir_
take no vocative `-e`.
