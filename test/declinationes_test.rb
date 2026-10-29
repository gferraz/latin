require 'minitest/autorun'
require 'slim'
require 'open3'
require 'rbconfig'
require 'tmpdir'

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

  def test_declension_validation_uses_the_same_equality_as_hash_lookup
    [2.0, Rational(2, 1), '2'].each do |declinatio|
      error = assert_raises(ArgumentError) do
        @tabula.desinentiae(:genitivus, :singularis, declinatio)
      end
      assert_includes error.message, 'unknown declension:'
    end
    assert_equal({ mf: %w[ī], n: %w[ī] }, @tabula.desinentiae(:genitivus, :singularis, 2))
  end

  def test_desinentiae_are_deeply_frozen
    assert Declinationes::DESINENTIAE.frozen?
    assert Declinationes::DESINENTIAE[:nominativus].frozen?
    assert Declinationes::DESINENTIAE[:nominativus][:singularis].frozen?
    assert Declinationes::DESINENTIAE[:nominativus][:singularis][1].frozen?
    assert Declinationes::DESINENTIAE[:nominativus][:singularis][1][:mf].frozen?

    assert_raises(FrozenError) { Declinationes::DESINENTIAE[:nominativus][:singularis][1][:mf] << 'x' }
    assert_raises(FrozenError) { Declinationes::NOTAE << 'nope' }
  end

  def test_custom_data_is_frozen_and_queried
    data = { nominativus: { singularis: { 1 => { mf: %w[x] } } } }
    tabula = Declinationes.new(data)

    assert data[:nominativus][:singularis][1][:mf].frozen?
    assert_equal({ mf: %w[x] }, tabula.desinentiae(:nominativus, :singularis, 1))
    assert_equal({}, tabula.desinentiae(:ablativus, :singularis, 1))
  end

  def test_notae
    assert_equal 10, @tabula.notae.size
    assert_equal Declinationes::NOTAE.size, @tabula.notae.size
  end

  def test_notes_are_grouped_by_declension_in_both_layouts
    groups = @tabula.notae_per_declinationem
    assert_equal [2, 3, 4, 5], groups.keys
    assert_equal [4, 4, 1, 1], groups.values.map(&:size)
    assert groups.frozen?
    assert groups.values.all?(&:frozen?)
    assert groups.values.flatten.all?(&:frozen?)
    assert_equal @tabula.notae,
                 groups.flat_map { |declinatio, notes| notes.map { |note| "Decl. #{@tabula.numerus_romanus(declinatio)} — #{note}" } }

    %i[desktop mobile].each do |layout|
      html = page(mode: :inlined, layout: layout)
      notes = html[html.index('<div class="notae">')..]
      assert_equal %w[II III IV V], notes.scan(%r{<h3>\s*Declinatio (\w+)\s*</h3>}).flatten
      assert_equal 4, notes.scan('<section class="notae-declinatio">').size
      assert_equal 10, notes.scan('<li>').size
      refute_includes notes, '<ol>'
      refute_match %r{<li>\s*Decl\.}, notes
    end
  end

  def test_fifth_declension_note_covers_plural_paradigms_and_dies_gender
    nota = @tabula.notae.find { |text| text.start_with?('Decl. V —') }

    assert_includes nota, '<em>diēs</em> e <em>rēs</em> têm paradigmas completos no plural'
    assert_includes nota, 'geralmente masculino no singular (também pode ser feminino)'
    assert_includes nota, 'sempre masculino no plural'
    assert_includes nota, '<em>merīdiēs</em> é masculino'
    refute_includes nota, 'apenas <em>rēs</em>'
  end

  def test_ius_vocative_note_limits_the_rule_and_mentions_greek_exceptions
    nota = @tabula.notae.find { |text| text.include?('nomes próprios latinos em -ius') }

    refute_nil nota
    assert_includes nota, '<em>fīlius</em>'
    assert_includes nota, '<em>genius</em>'
    assert_includes nota, 'A regra não vale para todos os nomes em -ius'
    assert_includes nota, 'nomes gregos em -īus fazem -īe'
  end

  # The table deliberately omits the third-declension i-stem forms. Each
  # omission must be documented in the notes, or the table silently misleads.
  def test_notae_document_i_stem_gaps
    notas = @tabula.notae.join(' ')

    assert_includes notas, '-ium', 'gen. pl. i-stem (-ium) not documented'
    assert_includes notas, '-ia',  'neut. nom./acc. pl. i-stem (-ia) not documented'
    assert_includes notas, '-im',  'acc. sg. i-stem (-im) not documented'
  end

  # Distinguish historical singular contraction from exceptional plural forms.
  def test_notae_document_second_and_fourth_declension_gaps
    notas = @tabula.notae.join(' ')

    singular = @tabula.notae.find { |nota| nota.start_with?('Decl. II — gen. sg.') }
    plural = @tabula.notae.find { |nota| nota.start_with?('Decl. II — gen. pl.') }
    assert_includes singular, '<em>fīlī</em>'
    assert_includes singular, '<em>fīliī</em>'
    assert_includes singular, 'época de Augusto'
    assert_includes plural, '<em>fīliōrum</em>'
    assert_includes plural, '<em>ingeniōrum</em>'
    assert_includes plural, '<em>deum</em>'
    refute_includes plural, '<em>fīlium</em>'
    assert_includes notas, 'domōrum', 'domus mixed declension not documented'
  end

  # Latin terms in the notes are marked up so the stylesheet can italicise
  # them; the template must therefore render the notes unescaped.
  def test_notae_mark_latin_terms
    notas = @tabula.notae.join(' ')

    assert_includes notas, '<em>puer</em>',  'puer not italicised'
    assert_includes notas, '<em>domus</em>', 'domus not italicised'
    refute_match %r{<em>-\w+</em>}, notas, 'endings should not be italicised'
    assert_match %r{<li>\s*voc\. sg\. — .*?<em>puer</em>.*?</li>}m, render
  end

  def test_notae_sorted
    ordine = Declinationes::NOTAE.sort_by do |nota|
      [nota[:declinatio], %i[m f n].index(nota[:genus]) || -1]
    end

    assert_equal 2, ordine.first[:declinatio], 'first note should be the second declension'
    assert_equal 5, ordine.last[:declinatio],  'last note should be the fifth declension'
  end

  # Equal (declinatio, genus, casus) keys must keep their declared order, so
  # the rendered notes do not depend on sort_by being stable.
  def test_notae_order_is_deterministic
    assert_equal @tabula.notae, Declinationes.new.notae,
                 'note order should not vary between instances'
    assert_equal 4, @tabula.notae.count { |nota| nota.start_with?('Decl. II ') },
                 'the four second-declension notes should stay together'
  end

  def test_notae_are_frozen_records
    Declinationes::NOTAE.each do |nota|
      assert nota.frozen?, 'note record should be frozen'
      assert nota.key?(:text), 'note record should carry text'
      assert nota.key?(:numero), 'note record should carry its sequence number'
    end
  end

  def test_notae_use_roman_numerals_and_render
    assert_equal %w[II II II II III III III III IV V], @tabula.notae.map { |n| n[/Decl\. (\w+)/, 1] }
    assert @tabula.notae.all? { |nota| nota.start_with?('Decl. ') }
    assert_match %r{<h2>\s*Notae\s*</h2>}, render
  end

  def test_render_structure
    html = render

    assert_equal 2, html.scan('<table').size
    assert_equal 14, html.scan('<tr').size
    assert_includes html, '<caption>Singularis</caption>'
    assert_includes html, '<caption>Pluralis</caption>'
    assert_match %r{>\s*I\s*</th>}, html
    assert_match %r{>\s*IV\s*</th>}, html
    assert_match %r{>\s*V\s*</th>}, html
    assert_includes html, '<div class="notae">'
    assert_includes html, '<ul>'
    assert_includes html, 'tbody td {'
    assert_match %r{<td class="sep" colspan="3"[^>]*>\s*-ī\s*</td>}, html
    assert_match %r{<td class="sep" colspan="2"[^>]*>\s*-e / -ī\s*</td>}, html
    assert_match %r{<td[^>]*>\s*-ēī / -eī\s*</td>}, html
    assert_match %r{<th class="sep" scope="col">\s*m\.\s*</th>}, html
    assert_equal 10, html.scan(%r{<th class="sep" scope="col">\s*m\.\s*</th>}).size # every group, five per table
    refute_match %r{<th class="sep" scope="col">\s*f\.\s*</th>}, html # separator only between groups
    assert_match %r{<th scope="row">\s*Nominativus / Vocativus\s*</th>}, html
    assert_match %r{<th scope="row">\s*Dativus / Ablativus\s*</th>}, html
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
    assert @tabula.unica?('am')    # acc. sg. 1st
    assert @tabula.unica?('uī')    # dat. sg. 4th (m./f.)
    assert @tabula.unica?('ārum')  # gen. pl. 1st
    assert @tabula.unica?('ōrum')  # gen. pl. 2nd (m./f./n. share the cell)
    assert @tabula.unica?('uum')   # gen. pl. 4th (m./f./n. share the cell)
    assert @tabula.unica?('is')    # gen. sg. 3rd (m./f./n. share the cell)
    assert @tabula.unica?('ērum')  # gen. pl. 5th

    refute @tabula.unica?('ae')    # nom./gen./dat. sg. and nom. pl. 1st
    refute @tabula.unica?('ī')     # gen./dat. sg. 2nd, dat. 3rd...
    refute @tabula.unica?('ibus')  # dat./abl. pl. 3rd and 4th
    refute @tabula.unica?('īs')    # dat./abl. pl. 1st and 2nd
    refute @tabula.unica?('um')    # acc./gen. pl. 2nd and 3rd, nom. sg. 2nd...
    refute @tabula.unica?('missing')
    assert @tabula.unique?('am')
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

  def test_endings_are_bold_only_when_unique_on_the_mobile_page_too
    html = page(mode: :inlined, layout: :mobile)

    assert_includes html, '<strong>-am</strong>'
    assert_includes html, '<strong>-ārum</strong>'
    refute_includes html, '<strong>-ae</strong>'
    refute_includes html, '<strong>-ibus</strong>'
  end

  def test_mobile_layout_gives_each_declension_its_own_paradigm
    html = page(mode: :inlined, layout: :mobile)

    assert_equal 5, html.scan('<section class="paradigma">').size
    assert_equal 10, html.scan('<table').size
    assert_equal 10, html.scan('<caption>').size
    assert_includes html, 'Declinatio I'
    assert_includes html, 'Declinatio V'
    refute_includes html, 'scope="colgroup"', 'the sixteen-column header belongs to the desktop page'
  end

  def test_mobile_rows_span_the_four_mobile_columns
    rows = page(mode: :inlined, layout: :mobile).scan(/<tr.*?<\/tr>/m)

    refute_empty rows
    rows.each_with_index do |row, index|
      span = row.scan(/<(?:th|td)[^>]*>/).sum { |cell| (cell[/colspan="(\d+)"/, 1] || '1').to_i }
      assert_equal 4, span, "row #{index}: #{row[0, 80]}"
    end
  end

  def test_mobile_page_carries_its_own_stylesheet
    mobile = page(mode: :inlined, layout: :mobile)
    desktop = page(mode: :inlined)

    assert_includes mobile, 'max-width: 34rem;'
    refute_includes desktop, 'max-width: 34rem;'
  end

  def test_linked_mobile_page_points_at_its_stylesheet
    mobile = page(mode: :linked, layout: :mobile)
    desktop = page(mode: :linked)

    assert_includes mobile, 'href="assets/mobile.css"'
    refute_includes desktop, 'assets/mobile.css'
  end

  def test_pages_declare_a_viewport_and_link_to_each_other
    desktop = page(mode: :inlined)
    mobile = page(mode: :inlined, layout: :mobile)

    [desktop, mobile].each do |html|
      viewport = html.scan(/<meta[^>]*>/).find { |tag| tag.include?('name="viewport"') }
      assert viewport, 'page should declare a viewport'
      assert_includes viewport, 'content="width=device-width, initial-scale=1"'
    end
    assert_includes desktop, '<a href="mobile.html">Forma mobilis</a>'
    assert_includes mobile, '<a href="declinationes.html">Forma plena</a>'
  end

  def test_unknown_layout_raises
    assert_raises(ArgumentError) { render_page(layout: :bogus) }
  end

  def test_learning_legend_and_analyses_in_both_layouts
    %i[desktop mobile].each do |layout|
      html = page(mode: :inlined, layout: layout)
      assert_includes html, 'Como ler a tabela'
      assert_includes html, 'Genitivo em vermelho:'
      assert_includes html, 'genitivo singular distinguem as cinco declinações'
      assert_includes html, 'I -ae; II -ī; III -is; IV -ūs; V -ēī / -eī'
      assert_includes html, 'data-analysis="genitivus · singularis · decl. II · m. / f. / n."'
      assert_includes html, 'data-analysis="genitivus · singularis · decl. V · f."'
      cells = html.scan(/<td\b[^>]*data-desinentiae[^>]*>/)
      refute_empty cells
      assert cells.all? { |cell| cell.include?('data-analysis=') && cell.include?('tabindex="0"') }
      if layout == :desktop
        assert_includes html, 'data-analysis="nominativus / vocativus · pluralis · decl. I · m. / f."'
        assert_includes html, 'data-analysis="dativus / ablativus · pluralis · decl. II · m. / f. / n."'
      end
    end
  end

  def test_render_command_produces_a_portable_preview_from_another_directory
    script = File.expand_path('../render.rb', __dir__)
    html, errors, status = Open3.capture3(RbConfig.ruby, script, chdir: Dir.tmpdir)

    assert status.success?, errors
    assert_equal render_page(mode: :inlined), html
    refute_match %r{(?:href|src)="(?:\.?\.?/)*assets/}, html
  end

  private

  def render
    page(mode: :inlined)
  end

  def page(mode:, asset_prefix: 'assets', layout: :desktop)
    render_page(mode: mode, asset_prefix: asset_prefix, layout: layout, tabula: @tabula)
  end
end
