
CASUS = %i[nominativus vocativus accusativus genitivus dativus ablativus]
GENERA = %i[m f n]
DECLINATIONES = [1, 2, 3, 4, 5]
NUMERI = %i[singularis pluralis]

DESINENTIAE = {
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
}.freeze

EXCEPTIONES = [
  "5ª decl. — diēs, merīdiēs são masculinos (apenas rēs tem plural comum).",
  "2ª decl. voc. sg. — puer, vir não recebem -e; fīlius → fīlī (não *fīlie).",
  "3ª decl. — nom./voc./acc. sg. apresentam desinências variáveis; daí as células vazias."
].freeze
