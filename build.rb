require 'fileutils'
require 'pathname'

require_relative 'page'

# The linked copy is for development: it points at the files in assets/, so
# editing them takes effect on reload. The inlined copy is the one to hand out:
# styles and script travel inside the single file.
OUTPUTS = {
  'build/declinationes.html' => :linked,
  'dist/declinationes.html' => :inlined
}.freeze

OUTPUTS.each do |path, mode|
  destination = File.expand_path(path, __dir__)
  prefix = Pathname.new(ASSETS).relative_path_from(Pathname.new(File.dirname(destination))).to_s
  FileUtils.mkdir_p(File.dirname(destination))
  File.write(destination, render_page(mode: mode, asset_prefix: prefix))
  warn "wrote #{path}"
end
