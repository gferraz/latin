
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

  EXCEPTIONES = deep_freeze([
    "5ª decl. — diēs, merīdiēs são masculinos (apenas rēs tem plural comum).",
    "2ª decl. voc. sg. — puer, vir não recebem -e; fīlius → fīlī (não *fīlie).",
    "3ª decl. — nom./voc./acc. sg. apresentam desinências variáveis; daí as células vazias."
  ])

  def initialize(desinentiae = DESINENTIAE)
    @desinentiae = self.class.deep_freeze(desinentiae)
  end

  def casus          = CASUS
  def genera         = GENERA
  def declinationes  = DECLINATIONES
  def numeri         = NUMERI
  def exceptiones    = EXCEPTIONES

  def columnae
    DECLINATIONES.size * GENERA.size
  end

  def desinentiae(casus, numerus, declinatio)
    validate!(casus, CASUS, 'case')
    validate!(numerus, NUMERI, 'number')
    validate!(declinatio, DECLINATIONES, 'declension')

    @desinentiae.fetch(casus, {}).fetch(numerus, {}).fetch(declinatio, {})
  end

  def omnes_desinentiae
    @omnes_desinentiae ||= @desinentiae.each_value.flat_map do |per_numerus|
      per_numerus.each_value.flat_map do |per_declinationem|
        per_declinationem.each_value.flat_map { |per_genus| per_genus.values.flatten }
      end
    end.freeze
  end

  def unique?(desinentia)
    ending_counts.fetch(desinentia, 0) == 1
  end

  private

  def ending_counts
    @ending_counts ||= omnes_desinentiae.tally
  end

  def validate!(value, allowed, label)
    return if allowed.include?(value)
    raise ArgumentError, "unknown #{label}: #{value.inspect} (valid: #{allowed.inspect})"
  end
end
