
require 'slim'

require_relative 'latin'


file = File.expand_path('declinationes.html.slim', __dir__)
html  = Slim::Template.new(file).render(nil, tabula: Declinationes.new)

puts html
