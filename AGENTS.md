# Repository Guidelines

## Project Structure & Module Organization

This is a small Ruby project that renders Latin noun declension tables as static HTML.

- `latin.rb` defines `Declensions`, grammatical metadata, endings, exceptions, and lookup validation.
- `declinationes.html.slim` contains the Slim page template and inline CSS.
- `render.rb` loads the model and template, then writes HTML to standard output.
- `x.html` is the checked-in HTML output; regenerate it when intended output changes.
- `test/declensions_test.rb` contains model and rendering tests using Minitest.

Keep grammatical data in the Ruby model and presentation logic in the Slim template. There is no separate asset directory or application server.

## Build, Test, and Development Commands

Run commands from the repository root. Use Ruby with support for endless method definitions (Ruby 3.0 or newer).

- `gem install slim minitest` installs the required gems. The repository currently has no Gemfile or dependency lockfile.
- `ruby render.rb > /tmp/latin-preview.html` generates a preview to inspect in a browser.
- `ruby render.rb > x.html` refreshes the checked-in output.
- `ruby test/declensions_test.rb` runs the complete current test suite.
- `ruby -c latin.rb` and `ruby -c render.rb` check Ruby syntax.

## Coding Style & Naming Conventions

Use two spaces for Ruby indentation and consistent nesting in Slim. Use `snake_case` for methods and files, `CamelCase` for classes, and uppercase names for constants. Retain Latin grammatical keys such as `nominativus` and `singularis`, and preserve UTF-8 macrons in endings. Keep shared grammatical data deeply frozen. No formatter or linter is configured.

## Testing Guidelines

Name test files `test/*_test.rb` and test methods `test_<behavior>`. Add regression assertions for changed endings, invalid arguments, immutability, and rendered table structure. Preserve coverage of column spans and irregular empty cells. No numeric coverage threshold is configured. Run the suite and inspect an HTML preview for presentation changes.

## Commit & Pull Request Guidelines

The Git history currently contains only `v1`, so no established commit convention exists. Use concise, imperative messages describing the change, such as `Correct third-declension endings`. Pull requests should explain the change, report validation commands, link relevant issues, and include screenshots for visible table or styling changes.
