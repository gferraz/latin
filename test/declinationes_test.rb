require 'minitest/autorun'
require 'slim'

require_relative '../latin'

class DeclinationesTest < Minitest::Test
  TEMPLATE = File.expand_path('../declinationes.html.slim', __dir__)

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
    assert_equal 3, Declinationes::EXCEPTIONES.size
    assert_equal Declinationes::EXCEPTIONES, @tabula.exceptiones
  end

  def test_render_structure
    html = render

    assert_equal 2, html.scan('<table').size
    assert_equal 18, html.scan('<tr').size
    assert_includes html, '<div class="notae"><ol>'
    assert_includes html, '<td colspan="3">-ī</td>'
    assert_includes html, '<td colspan="2">-e / -ī</td>'
    assert_includes html, '<td>-ēī / -eī</td>'
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
    Slim::Template.new(TEMPLATE).render(nil, tabula: @tabula)
  end
end
