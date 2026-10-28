
class Declinationes
  def self.deep_freeze(object)
    case object
    when Hash
      object.each_value { |value| deep_freeze(value) }
    when Array
      object.each { |value| deep_freeze(value) }
    end
    object.freeze
  end

  CASUS          = %i[nominativus vocativus accusativus genitivus dativus ablativus].freeze
  GENERA         = %i[m f n].freeze
  DECLINATIONES  = [1, 2, 3, 4, 5].freeze
  NUMERI         = %i[singularis pluralis].freeze

  DESINENTIAE = deep_freeze({
    nominativus: {
      singularis: {
        1 => { mf: %w[a] },
        2 => { mf: %w[us], n: %w[um] },   # -er/-ir (puer, vir): sem desinência
        3 => {},                          # desinências variáveis (civis/civēs)
        4 => { mf: %w[us], n: %w[ū] },
        5 => { f:  %w[ēs] }               # diēs, merīdiēs: m.
      },
      pluralis: {
        1 => { mf: %w[ae] },
        2 => { mf: %w[ī],  n: %w[a] },
        3 => { mf: %w[ēs], n: %w[a] },    # temas em -i: neutro -ia
        4 => { mf: %w[ūs], n: %w[ua] },
        5 => { f:  %w[ēs] }
      }
    },
    vocativus: {
      singularis: {
        1 => { mf: %w[a] },
        2 => { mf: %w[e ī],  n: %w[um] },   # -ius (fīlius) → ī; -er/-ir (puer, vir): sem -e
        3 => {},                          # igual ao nominativo
        4 => { mf: %w[us], n: %w[ū] },
        5 => { f:  %w[ēs] }
      },
      pluralis: {                         # sempre igual ao nominativo plural
        1 => { mf: %w[ae] },
        2 => { mf: %w[ī],  n: %w[a] },
        3 => { mf: %w[ēs], n: %w[a] },
        4 => { mf: %w[ūs], n: %w[ua] },
        5 => { f:  %w[ēs] }
      }
    },
    accusativus: {
      singularis: {
        1 => { mf: %w[am] },
        2 => { mf: %w[um], n: %w[um] },
        3 => { mf: %w[em] },              # neutro: igual ao nominativo
        4 => { mf: %w[um], n: %w[ū] },
        5 => { f:  %w[em] }
      },
      pluralis: {
        1 => { mf: %w[ās] },
        2 => { mf: %w[ōs], n: %w[a] },
        3 => { mf: %w[ēs īs], n: %w[a] }, # īs: variante dos temas em -i
        4 => { mf: %w[ūs], n: %w[ua] },
        5 => { f:  %w[ēs] }
      }
    },
    genitivus: {
      singularis: {
        1 => { mf: %w[ae] },
        2 => { mf: %w[ī],  n: %w[ī] },
        3 => { mf: %w[is], n: %w[is] },
        4 => { mf: %w[ūs], n: %w[ūs] },
        5 => { f:  %w[ēī eī] }            # ēī após vogal (diēī), eī após consoante (reī)
      },
      pluralis: {
        1 => { mf: %w[ārum] },
        2 => { mf: %w[ōrum], n: %w[ōrum] },
        3 => { mf: %w[um],   n: %w[um] }, # temas em -i: ium
        4 => { mf: %w[uum],  n: %w[uum] },
        5 => { f:  %w[ērum] }
      }
    },
    dativus: {
      singularis: {
        1 => { mf: %w[ae] },
        2 => { mf: %w[ō],  n: %w[ō] },
        3 => { mf: %w[ī],  n: %w[ī] },
        4 => { mf: %w[uī], n: %w[ū] },
        5 => { f:  %w[ēī eī] }
      },
      pluralis: {
        1 => { mf: %w[īs] },
        2 => { mf: %w[īs],   n: %w[īs] },
        3 => { mf: %w[ibus], n: %w[ibus] },
        4 => { mf: %w[ibus ubus], n: %w[ibus ubus] },  # ubus: arcubus, partubus...
        5 => { f:  %w[ēbus] }
      }
    },
    ablativus: {
      singularis: {
        1 => { mf: %w[ā] },
        2 => { mf: %w[ō],  n: %w[ō] },
        3 => { mf: %w[e ī],  n: %w[e ī] },    # temas em -i: ī (desinências variáveis)
        4 => { mf: %w[ū],  n: %w[ū] },
        5 => { f:  %w[ē] }
      },
      pluralis: {                         # sempre igual ao dativo plural
        1 => { mf: %w[īs] },
        2 => { mf: %w[īs],   n: %w[īs] },
        3 => { mf: %w[ibus], n: %w[ibus] },
        4 => { mf: %w[ibus ubus], n: %w[ibus ubus] },
        5 => { f:  %w[ēbus] }
      }
    }
  })

  NUMERI_ROMANI = %w[I II III IV V].freeze

  # Cada nota traz numero: a sua posição dentro do mesmo (declinatio, genus,
  # casus). Sem isso, notas com a mesma chave dependeriam de sort_by ser
  # estável, o que o Ruby não garante.
  NOTAE = deep_freeze([
    { declinatio: 5, genus: :m, casus: nil, numero: 1,
      text: "<em>diēs</em>, <em>merīdiēs</em> são masculinos (apenas <em>rēs</em> " \
            "tem plural comum)." },
    { declinatio: 2, genus: :m, casus: :vocativus, numero: 1,
      text: "voc. sg. — os nomes em -er/-ir não recebem -e: <em>puer</em> → <em>puer</em>, " \
            "<em>vir</em> → <em>vir</em>, <em>ager</em> → <em>ager</em>." },
    { declinatio: 2, genus: :m, casus: :vocativus, numero: 2,
      text: "voc. sg. — os nomes em -ius fazem -ī: <em>fīlius</em> → <em>fīlī</em> " \
            "(não *<em>fīlie</em>)." },
    { declinatio: 2, genus: :m, casus: :genitivus, numero: 1,
      text: "gen. sg. — os nomes em -ius fazem -ī, não -iī: <em>fīlius</em> → <em>fīlī</em>, " \
            "<em>genius</em> → <em>genī</em>; a tabela mostra apenas -ī." },
    { declinatio: 2, genus: :m, casus: :genitivus, numero: 2,
      text: "gen. pl. — os nomes em -ius/-ium fazem -ium, não -iōrum: <em>fīlius</em> → " \
            "<em>fīlium</em>, <em>Dēlius</em> → <em>Dēlium</em>; a tabela mostra apenas -ōrum." },
    { declinatio: 3, genus: nil, casus: nil, numero: 1,
      text: "nom./voc./acc. sg. apresentam desinências variáveis; daí as células vazias." },
    { declinatio: 3, genus: nil, casus: :genitivus, numero: 1,
      text: "gen. pl. — os temas em -i fazem -ium, além de -um: <em>cīvium</em> " \
            "(<em>cīvis</em>), <em>marīum</em> (<em>mare</em>); a tabela mostra apenas -um." },
    { declinatio: 3, genus: :n, casus: :nominativus, numero: 1,
      text: "nom./voc./acc. pl. neutro — os temas em -i fazem -ia, além de -a: " \
            "<em>maria</em> (<em>mare</em>), <em>animālia</em> (<em>animal</em>); " \
            "a tabela mostra apenas -a." },
    { declinatio: 3, genus: :mf, casus: :accusativus, numero: 1,
      text: "acc. sg. — em poucos nomes o -im substitui o -em: <em>sitim</em> " \
            "(<em>sitis</em>), <em>turrim</em> (<em>turris</em>); a tabela mostra apenas -em." },
    { declinatio: 4, genus: :f, casus: nil, numero: 1,
      text: "<em>domus</em> tem dois temas (u- e o-) e mistura as 4ª e 2ª declinações: " \
            "gen. sg. <em>domūs</em>, mas também <em>domī</em>, <em>domōrum</em>." }
  ])

  def initialize(desinentiae = DESINENTIAE)
    @desinentiae = self.class.deep_freeze(desinentiae)
  end

  def casus          = CASUS
  def genera         = GENERA
  def declinationes  = DECLINATIONES
  def numeri         = NUMERI

  def numerus_romanus(declinatio)
    NUMERI_ROMANI.fetch(declinatio - 1)
  end

  # As notas saem ordenadas por declinação, depois gênero, depois caso,
  # e prefixadas com o numeral romano da declinação.
  def notae
    @notae ||= sort_notae.map do |nota|
      "Decl. #{numerus_romanus(nota[:declinatio])} — #{nota[:text]}"
    end.freeze
  end

  def columnae
    DECLINATIONES.size * GENERA.size
  end

  def desinentiae(casus, numerus, declinatio)
    validate!(casus, CASUS, 'case')
    validate!(numerus, NUMERI, 'number')
    validate!(declinatio, DECLINATIONES, 'declension')

    @desinentiae.fetch(casus, {}).fetch(numerus, {}).fetch(declinatio, {})
  end

  # Uma entrada por célula: gêneros que compartilham a mesma desinência
  # (ex.: -ōrum no gen. pl. da 2ª, m./f./n.) contam uma única vez.
  def omnes_desinentiae
    @omnes_desinentiae ||= @desinentiae.each_value.flat_map do |per_numerus|
      per_numerus.each_value.flat_map do |per_declinationem|
        per_declinationem.each_value.flat_map { |per_genus| per_genus.values.flatten.uniq }
      end
    end.freeze
  end

  def unica?(desinentia)
    ending_counts.fetch(desinentia, 0) == 1
  end
  alias unique? unica?

  private

  # Notas sem gênero ou sem caso vêm primeiro dentro da sua declinação.
  # numero desempata notas com a mesma chave, para a ordem não depender da
  # estabilidade de sort_by.
  def sort_notae
    NOTAE.sort_by do |nota|
      [nota[:declinatio], ordine(GENERA, nota[:genus]), ordine(CASUS, nota[:casus]), nota[:numero]]
    end
  end

  # Posição de um gênero ou caso na ordem canônica; ausente vem antes de tudo.
  # :mf cobre as notas que valem para masculino e feminino ao mesmo tempo.
  def ordine(allowed, value)
    return -1 if value.nil?
    index = allowed.index(value)
    return index if index
    return allowed.index(:m) if value == :mf

    allowed.size
  end

  def ending_counts
    @ending_counts ||= omnes_desinentiae.tally
  end

  def validate!(value, allowed, label)
    return if allowed.include?(value)
    raise ArgumentError, "unknown #{label}: #{value.inspect} (valid: #{allowed.inspect})"
  end
end
