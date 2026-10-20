# Latin declension tables

Renders a static HTML table of Latin noun declensions — all five declensions,
six cases, three genders, singular and plural — from a single Ruby data model.

Output: [`x.html`](x.html). Two tables — `Singularis` and `Pluralis` — with
5 × 3 = 15 ending columns plus the case column, and footnotes for the
general-rule exceptions.

## Requirements

- Ruby 3.0 or newer (the code uses endless method definitions)
- Slim and Minitest: `gem install slim minitest`

There is no Gemfile or lockfile.

## Usage

```sh
ruby render.rb > x.html      # refresh the checked-in output
ruby render.rb > /tmp/p.html # preview elsewhere, then open in a browser
```

`render.rb` works from any working directory.

## Tests

```sh
ruby test/declinationes_test.rb
```

Covers metadata, ending lookups, immutability, argument validation, and the
rendered table structure (row spans, empty cells, footnotes).

## Project layout

| File | Purpose |
| --- | --- |
| `latin.rb` | `Declinationes` class: grammatical metadata, endings, exceptions, validation |
| `declinationes.html.slim` | Slim page template and inline CSS |
| `render.rb` | Loads the model and template, writes HTML to stdout |
| `x.html` | Checked-in output; regenerate when intended output changes |
| `test/declinationes_test.rb` | Minitest suite |

Grammatical data lives in the Ruby model, presentation logic in the Slim
template.

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
tabula.exceptiones    # => [...] footnotes for the exceptions

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

Because the fonts come from Google Fonts, an offline viewer falls back to the
local serif stack. A `@media print` block removes the background tints so the
tables print cleanly.

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
footnotes instead (`Declinationes::EXCEPTIONES`) — for example *diēs* and
*merīdiēs* are masculine fifth-declension nouns, and *puer*/*vir* take no
vocative `-e`.
