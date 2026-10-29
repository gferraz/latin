# Repository Guidelines

## Project Structure & Module Organization

This is a small Ruby project that renders Latin noun declension tables as static HTML.

- `latin.rb` defines `Declinationes`, grammatical metadata, endings, exceptions, and lookup validation.
- `declinationes.html.slim` contains the Slim page template and the inline/linked switch.
- `assets/screen.css`, `assets/print.css`, and `assets/desinentiae.js` hold the styles and the ending-highlight script; they are the only copy.
- `page.rb` loads `assets/` and exposes `render_page`, the single render entry point.
- `build.rb` calls `render_page` twice: linked into `build/`, inlined into `dist/`.
- `bin/build` is a shell wrapper around `build.rb`, so the build runs without naming `ruby`.
- `render.rb` calls `render_page` once, to standard output.
- `build/declinationes.html` is the generated linked copy; `dist/declinationes.html` is the generated self-contained copy to distribute.
- `test/declinationes_test.rb` contains model and rendering tests using Minitest.

Keep grammatical data in the Ruby model, markup in the Slim template, and styling and behaviour in `assets/`. There is no application server.

## Build, Test, and Development Commands

Run commands from the repository root. Use Ruby with support for endless method definitions (Ruby 3.0 or newer).

- `gem install slim minitest` installs the required gems. The repository currently has no Gemfile or dependency lockfile.
- `bin/build` regenerates both `build/declinationes.html` (linked) and `dist/declinationes.html` (inlined). It is a thin shell wrapper around `build.rb`, and works from any directory; `ruby build.rb` is equivalent.
- `ruby render.rb > /tmp/latin-preview.html` generates an inlined preview to inspect in a browser; CSS and JavaScript work regardless of where it is saved.
- `ruby test/declinationes_test.rb` runs the complete current test suite.
- `ruby -c latin.rb`, `ruby -c page.rb`, `ruby -c render.rb`, and `ruby -c build.rb` check Ruby syntax.

## Coding Style & Naming Conventions

Use two spaces for Ruby indentation and consistent nesting in Slim. Use `snake_case` for methods and files, `CamelCase` for classes, and uppercase names for constants. Retain Latin grammatical keys such as `nominativus` and `singularis`, and preserve UTF-8 macrons in endings. Keep shared grammatical data deeply frozen. No formatter or linter is configured.

## Testing Guidelines

Name test files `test/*_test.rb` and test methods `test_<behavior>`. Add regression assertions for changed endings, invalid arguments, immutability, and rendered table structure. Preserve coverage of column spans and irregular empty cells. No numeric coverage threshold is configured. Run the suite and inspect an HTML preview for presentation changes.

## Commit & Pull Request Guidelines

The Git history currently contains only `v1`, so no established commit convention exists. Use concise, imperative messages describing the change, such as `Correct third-declension endings`. Pull requests should explain the change, report validation commands, link relevant issues, and include screenshots for visible table or styling changes.
