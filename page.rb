require 'slim'

require_relative 'latin'

TEMPLATE = File.expand_path('declinationes.html.slim', __dir__)
ASSETS = File.expand_path('assets', __dir__)
LAYOUTS = %i[desktop mobile].freeze

# Reads the styles and script that the template embeds in :inlined mode.
def asset_text
  {
    screen_css: File.read(File.join(ASSETS, 'screen.css')),
    mobile_css: File.read(File.join(ASSETS, 'mobile.css')),
    print_css: File.read(File.join(ASSETS, 'print.css')),
    desinentiae_js: File.read(File.join(ASSETS, 'desinentiae.js'))
  }
end

def render_counts(tabula, layout)
  counts = Hash.new(0)
  tabula.numeri.each do |numerus|
    tabula.casus.each do |casus|
      if layout == :desktop && numerus == :pluralis && %i[vocativus ablativus].include?(casus)
        next
      end
      tabula.declinationes.each do |declinatio|
        desinentiae = tabula.desinentiae(casus, numerus, declinatio)
        next if desinentiae.empty?
        if desinentiae[:mf] && desinentiae[:mf] == desinentiae[:n]
          Array(desinentiae[:mf]).uniq.each { |desinentia| counts[desinentia] += 1 }
        else
          Array(desinentiae[:mf]).uniq.each { |desinentia| counts[desinentia] += 1 } if desinentiae[:mf]
          Array(desinentiae[:f]).uniq.each { |desinentia| counts[desinentia] += 1 } if desinentiae[:f]
          Array(desinentiae[:n]).uniq.each { |desinentia| counts[desinentia] += 1 } if desinentiae[:n]
        end
      end
    end
  end
  counts
end

# Renders the page. `mode` is :linked (points at assets/) or :inlined (carries
# them). `asset_prefix` is where the linked mode finds assets/, relative to the
# file being written. `layout` is :desktop (all declensions side by side) or
# :mobile (one paradigm per declension). `tabula` allows a caller to pass its
# own model.
def render_page(mode: :linked, asset_prefix: 'assets', layout: :desktop, tabula: Declinationes.new)
  raise ArgumentError, "unknown layout: #{layout.inspect} (valid: #{LAYOUTS.inspect})" unless LAYOUTS.include?(layout)

  html = Slim::Template.new(TEMPLATE, pretty: true).render(
    nil, tabula: tabula, mode: mode, layout: layout, asset_prefix: asset_prefix, render_counts: render_counts(tabula, layout), **asset_text
  )
  "#{html}\n"
end
