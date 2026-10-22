require 'minitest/autorun'
require 'slim'

require_relative '../latin'
require_relative '../page'

class DeclinationesTest < Minitest::Test
  def setup
    @tabula = Declinationes.new
  end

  def test_metadata
    assert_equal 15, @tabula.columnae
    assert_equal %i[nominativus vocativus accusativus genitivus dativus ablativus], @tabula.casus
    assert_equal %i[m f n], @tabula.genera
    assert_equal [1, 2, 3, 4, 5], @tabula.declinationes
    assert_equal %i[singularis pluralis], @tabula.numeri
  end

  def test_desinentiae_lookup
    assert_equal({ mf: %w[ī], n: %w[ī] }, @tabula.desinentiae(:genitivus, :singularis, 2))
    assert_equal({ mf: %w[ibus ubus], n: %w[ibus ubus] }, @tabula.desinentiae(:dativus, :pluralis, 4))
    assert_equal({ f: %w[ēī eī] }, @tabula.desinentiae(:genitivus, :singularis, 5))
  end

  def test_irregular_cell_is_an_empty_hash
    assert_equal({}, @tabula.desinentiae(:nominativus, :singularis, 3))
    assert_equal({}, @tabula.desinentiae(:vocativus, :singularis, 3))
  end

  def test_every_combination_returns_a_hash_never_nil
    @tabula.casus.each do |casus|
      @tabula.numeri.each do |numerus|
        @tabula.declinationes.each do |declinatio|
          result = @tabula.desinentiae(casus, numerus, declinatio)
          assert_instance_of Hash, result, "#{casus}/#{numerus}/#{declinatio}"
        end
      end
    end
  end

  def test_unknown_arguments_raise_argument_error
    assert_raises(ArgumentError) { @tabula.desinentiae(:bogus, :singularis, 1) }
    assert_raises(ArgumentError) { @tabula.desinentiae(:nominativus, :bogus, 1) }
    assert_raises(ArgumentError) { @tabula.desinentiae(:nominativus, :singularis, 6) }
    assert_raises(ArgumentError) { @tabula.desinentiae(:bogus, :bogus, :bogus) }
  end

  def test_desinentiae_are_deeply_frozen
    assert Declinationes::DESINENTIAE.frozen?
    assert Declinationes::DESINENTIAE[:nominativus].frozen?
    assert Declinationes::DESINENTIAE[:nominativus][:singularis].frozen?
    assert Declinationes::DESINENTIAE[:nominativus][:singularis][1].frozen?
    assert Declinationes::DESINENTIAE[:nominativus][:singularis][1][:mf].frozen?

    assert_raises(FrozenError) { Declinationes::DESINENTIAE[:nominativus][:singularis][1][:mf] << 'x' }
    assert_raises(FrozenError) { Declinationes::EXCEPTIONES << 'nope' }
  end

  def test_custom_data_is_frozen_and_queried
    data = { nominativus: { singularis: { 1 => { mf: %w[x] } } } }
    tabula = Declinationes.new(data)

    assert data[:nominativus][:singularis][1][:mf].frozen?
    assert_equal({ mf: %w[x] }, tabula.desinentiae(:nominativus, :singularis, 1))
    assert_equal({}, tabula.desinentiae(:ablativus, :singularis, 1))
  end

  def test_exceptiones
    assert_equal 6, @tabula.exceptiones.size
    assert_equal Declinationes::EXCEPTIONES.sort_by(&:to_s), @tabula.exceptiones.sort_by(&:to_s),
                 'notes should be the declared notes, reordered'
  end

  # The table deliberately omits the third-declension i-stem forms. Each
  # omission must be documented in the notes, or the table silently misleads.
  def test_exceptiones_document_i_stem_gaps
    notas = @tabula.notae.join(' ')

    assert_includes notas, '-ium', 'gen. pl. i-stem (-ium) not documented'
    assert_includes notas, '-ia',  'neut. nom./acc. pl. i-stem (-ia) not documented'
    assert_includes notas, '-im',  'acc. sg. i-stem (-im) not documented'
  end

  def test_exceptiones_sorted
    ordine = @tabula.exceptiones.map { |nota| [nota[:declinatio], nota[:genus], nota[:casus]] }

    assert_equal ordine.sort_by { |d, _g, _c| d }, ordine, 'notes not grouped by declension'
    assert_equal 2, ordine.first[0], 'first note should be the second declension'
    assert_equal 5, ordine.last[0],  'last note should be the fifth declension'
  end

  def test_exceptiones_are_frozen_records
    @tabula.exceptiones.each do |nota|
      assert nota.frozen?, 'note record should be frozen'
      assert nota.key?(:text), 'note record should carry text'
    end
  end

  def test_notae_use_roman_numerals_and_render
    assert_equal %w[II III III III III V], @tabula.notae.map { |n| n[/Decl\. (\w+)/, 1] }
    assert @tabula.notae.all? { |nota| nota.start_with?('Decl. ') }
    assert_match %r{<h2>\s*Notae\s*</h2>}, render
  end

  def test_render_structure
    html = render

    assert_equal 2, html.scan('<table').size
    assert_equal 16, html.scan('<tr').size
    assert_includes html, '<caption>Singularis</caption>'
    assert_includes html, '<caption>Pluralis</caption>'
    assert_match %r{>\s*I\s*</th>}, html
    assert_match %r{>\s*IV\s*</th>}, html
    assert_match %r{>\s*V\s*</th>}, html
    assert_includes html, '<div class="notae">'
    assert_includes html, '<ol>'
    assert_includes html, 'tbody td {'
    assert_match %r{<td class="sep" colspan="3"[^>]*>\s*-ī\s*</td>}, html
    assert_match %r{<td class="sep" colspan="2"[^>]*>\s*-e / -ī\s*</td>}, html
    assert_match %r{<td[^>]*>\s*-ēī / -eī\s*</td>}, html
    assert_match %r{<th class="sep" scope="col">\s*m\.\s*</th>}, html
    assert_equal 10, html.scan(%r{<th class="sep" scope="col">\s*m\.\s*</th>}).size # every group, five per table
    refute_match %r{<th class="sep" scope="col">\s*f\.\s*</th>}, html # separator only between groups
    assert_match %r{<th scope="row">\s*Nominativus\s*</th>}, html
    assert_match %r{<th class="sep" colspan="3" scope="colgroup">\s*I\s*</th>}, html # line before the first group too
    assert_includes html, '<html lang="la">'
  end

  def test_ending_cells_expose_their_endings_for_highlighting
    html = render

    # every cell that shows an ending carries the machine-readable list
    assert_includes html, 'data-desinentiae="ibus ubus"'
    assert_includes html, 'data-desinentiae="e ī"'
    assert_includes html, 'data-desinentiae="ōrum"'
    # the script that highlights matching cells is present
    assert_includes html, 'desinentia-match'
    assert_includes html, 'data-desinentiae'
    assert_match %r{<script>.*?addEventListener}m, html
  end

  def test_every_row_span_sums_to_the_header_width
    expected = Declinationes::DECLINATIONES.size * Declinationes::GENERA.size + 1

    render.scan(/<tr.*?<\/tr>/m).each_with_index do |row, index|
      span = row.scan(/<(?:th|td)[^>]*>/).sum { |cell| (cell[/colspan="(\d+)"/, 1] || '1').to_i }
      assert_equal expected, span, "row #{index}: #{row[0, 80]}"
    end
  end

  def test_unique_endings_occur_only_once
    assert @tabula.unique?('am')    # acc. sg. 1st
    assert @tabula.unique?('uī')    # dat. sg. 4th (m./f.)
    assert @tabula.unique?('ārum')  # gen. pl. 1st
    assert @tabula.unique?('ōrum')  # gen. pl. 2nd (m./f./n. share the cell)
    assert @tabula.unique?('uum')   # gen. pl. 4th (m./f./n. share the cell)
    assert @tabula.unique?('is')    # gen. sg. 3rd (m./f./n. share the cell)
    assert @tabula.unique?('ērum')  # gen. pl. 5th

    refute @tabula.unique?('ae')    # nom./gen./dat. sg. and nom. pl. 1st
    refute @tabula.unique?('ī')     # gen./dat. sg. 2nd, dat. 3rd...
    refute @tabula.unique?('ibus')  # dat./abl. pl. 3rd and 4th
    refute @tabula.unique?('īs')    # dat./abl. pl. 1st and 2nd
    refute @tabula.unique?('um')    # acc./gen. pl. 2nd and 3rd, nom. sg. 2nd...
    refute @tabula.unique?('missing')
  end

  def test_uniqueness_uses_instance_data
    repeated = Declinationes.new({
      nominativus: { singularis: { 1 => { mf: %w[x] } } },
      vocativus:   { singularis: { 1 => { mf: %w[x] } } }
    })
    once = Declinationes.new({
      nominativus: { singularis: { 1 => { mf: %w[y] } } }
    })

    refute repeated.unique?('x')
    assert once.unique?('y')
  end

  def test_render_bolds_only_unique_endings
    html = render

    assert_includes html, '<strong>-am</strong>'
    assert_includes html, '<strong>-ārum</strong>'
    assert_includes html, '<strong>-ōrum</strong>'
    assert_includes html, '<strong>-uum</strong>'
    assert_includes html, '<strong>-is</strong>'
    assert_includes html, '<strong>-uī</strong>'
    assert_includes html, '<strong>-ōs</strong>'

    refute_includes html, '<strong>-ae</strong>'
    refute_includes html, '<strong>-ibus</strong>'
    refute_includes html, '<strong>-ī</strong>'
    refute_includes html, '<strong>-us</strong>'
    refute_includes html, '<strong>-um</strong>'
  end

  private

  def render
    page(mode: :inlined)
  end

  def page(mode:, asset_prefix: 'assets')
    render_page(mode: mode, asset_prefix: asset_prefix, tabula: @tabula)
  end
end
