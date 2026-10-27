require 'fileutils'
require 'pathname'

require_relative 'page'

# The linked copies are for development: they point at the files in assets/, so
# editing them takes effect on reload. The inlined copies are the ones to hand
# out: styles and script travel inside each single file. The desktop page puts
# every declension side by side; the mobile page gives each its own paradigm so
# the table fits a narrow screen.
OUTPUTS = {
  'build/declinationes.html' => { mode: :linked, layout: :desktop },
  'build/mobile.html' => { mode: :linked, layout: :mobile },
  'dist/declinationes.html' => { mode: :inlined, layout: :desktop },
  'dist/mobile.html' => { mode: :inlined, layout: :mobile }
}.freeze

OUTPUTS.each do |path, options|
  destination = File.expand_path(path, __dir__)
  prefix = Pathname.new(ASSETS).relative_path_from(Pathname.new(File.dirname(destination))).to_s
  FileUtils.mkdir_p(File.dirname(destination))
  File.write(destination, render_page(asset_prefix: prefix, **options))
  warn "wrote #{path}"
end
