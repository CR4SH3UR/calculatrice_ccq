import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/ccq_data.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/metier_picker.dart';

const double _m2PerFt2 = 0.09290304;
const double _m3PerFt3 = 0.0283168;

// ═════════════════════════════════════════════════════════════════════════
//  CALCULATRICE STANDARD
// ═════════════════════════════════════════════════════════════════════════
class CalculatriceScreen extends StatefulWidget {
  const CalculatriceScreen({super.key});
  @override
  State<CalculatriceScreen> createState() => _CalculatriceScreenState();
}

class _CalculatriceScreenState extends State<CalculatriceScreen> {
  String _affiche = '0';
  double? _accum;
  String? _op;
  bool _neuf = true; // prochaine touche démarre un nouveau nombre

  void _chiffre(String c) {
    setState(() {
      if (_neuf) {
        _affiche = c == ',' ? '0,' : c;
        _neuf = false;
      } else {
        if (c == ',' && _affiche.contains(',')) return;
        _affiche += c;
      }
    });
  }

  double get _valeur =>
      double.tryParse(_affiche.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;

  void _appliquer() {
    final v = _valeur;
    if (_accum == null || _op == null) {
      _accum = v;
    } else {
      switch (_op) {
        case '+':
          _accum = _accum! + v;
          break;
        case '−':
          _accum = _accum! - v;
          break;
        case '×':
          _accum = _accum! * v;
          break;
        case '÷':
          _accum = v == 0 ? double.nan : _accum! / v;
          break;
      }
    }
  }

  void _operation(String op) {
    setState(() {
      if (!_neuf) _appliquer();
      _op = op;
      _neuf = true;
      _affiche = _fmt(_accum ?? _valeur);
    });
  }

  void _egale() {
    setState(() {
      _appliquer();
      _op = null;
      _neuf = true;
      _affiche = _fmt(_accum ?? 0);
    });
  }

  void _effacer() {
    setState(() {
      _affiche = '0';
      _accum = null;
      _op = null;
      _neuf = true;
    });
  }

  void _pourcent() {
    setState(() {
      _affiche = _fmt(_valeur / 100);
      _neuf = true;
    });
  }

  void _signe() {
    setState(() => _affiche = _fmt(-_valeur));
  }

  String _fmt(double v) {
    if (v.isNaN || v.isInfinite) return 'Erreur';
    return Fmt.trim(v, maxDecimals: 8);
  }

  @override
  Widget build(BuildContext context) {
    final onSurf = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(title: const Text('Calculatrice')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: FittedBox(
                  child: Text(_affiche,
                      style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          color: onSurf)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _rangee(['C', '±', '%', '÷']),
                  _rangee(['7', '8', '9', '×']),
                  _rangee(['4', '5', '6', '−']),
                  _rangee(['1', '2', '3', '+']),
                  _rangee(['0', ',', '=']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rangee(List<String> t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            for (final c in t)
              Expanded(
                flex: c == '0' ? 2 : 1,
                child: _touche(c),
              ),
          ],
        ),
      );

  Widget _touche(String c) {
    final op = ['÷', '×', '−', '+', '='].contains(c);
    final fonction = ['C', '±', '%'].contains(c);
    final Color bg = op
        ? AppColors.accent
        : fonction
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surfaceContainerHigh;
    final Color fg = op
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.selectionClick();
            if (c == 'C') {
              _effacer();
            } else if (c == '=') {
              _egale();
            } else if (c == '±') {
              _signe();
            } else if (c == '%') {
              _pourcent();
            } else if (['÷', '×', '−', '+'].contains(c)) {
              _operation(c);
            } else {
              _chiffre(c);
            }
          },
          child: SizedBox(
            height: 68,
            child: Center(
              child: Text(c,
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w600, color: fg)),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  CONVERTISSEUR AVANCÉ (multi-catégories)
// ═════════════════════════════════════════════════════════════════════════
class ConvertisseurAvanceScreen extends StatefulWidget {
  const ConvertisseurAvanceScreen({super.key});
  @override
  State<ConvertisseurAvanceScreen> createState() =>
      _ConvertisseurAvanceScreenState();
}

class _ConvertisseurAvanceScreenState extends State<ConvertisseurAvanceScreen> {
  // Chaque unité : facteur vers l'unité de base de la catégorie.
  static const Map<String, Map<String, double>> _cats = {
    'Longueur': {'mm': 0.001, 'cm': 0.01, 'm': 1, 'po': 0.0254, 'pi': 0.3048, 'vg': 0.9144},
    'Poids': {'g': 0.001, 'kg': 1, 'lb': 0.453592, 'tonne': 1000},
    'Volume': {'L': 1, 'gal US': 3.78541, 'm³': 1000, 'pi³': 28.3168},
    'Pression': {'kPa': 1, 'psi': 6.89476, 'bar': 100},
  };
  final _ctrl = TextEditingController(text: '1');
  String _cat = 'Longueur';
  late String _unite = _cats[_cat]!.keys.first;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Température est gérée à part (pas dans _cats) : map vide et valeurs
    // protégées pour ne jamais faire de « null check » sur null.
    final Map<String, double> units = _cats[_cat] ?? const {};
    final double val = parseNum(_ctrl.text) ?? 0;
    final double enBase = val * (units[_unite] ?? 1);
    return ToolScaffold(
      title: 'Convertisseur avancé',
      children: [
        DropdownButtonFormField<String>(
          initialValue: _cat,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Catégorie'),
          items: [
            for (final k in _cats.keys) DropdownMenuItem(value: k, child: Text(k)),
            const DropdownMenuItem(value: 'Température', child: Text('Température')),
          ],
          onChanged: (v) => setState(() {
            _cat = v!;
            if (_cat != 'Température') _unite = _cats[_cat]!.keys.first;
          }),
        ),
        const SizedBox(height: 14),
        if (_cat == 'Température')
          const _TemperatureConv()
        else ...[
          NumberField(
              controller: _ctrl,
              label: 'Valeur',
              allowNegative: true,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          ChoiceSegments(
            options: units.keys.toList(),
            selected: _unite,
            onChanged: (v) => setState(() => _unite = v),
          ),
          const SizedBox(height: 22),
          ResultCard(
            label: 'Équivalences',
            value: '${Fmt.trim(val)} $_unite',
            color: AppColors.chantier,
            icon: Icons.swap_horiz,
            details: [
              for (final u in units.keys)
                if (u != _unite)
                  ResultLine(u, Fmt.number(enBase / units[u]!, decimals: 4)),
            ],
          ),
        ],
      ],
    );
  }
}

class _TemperatureConv extends StatefulWidget {
  const _TemperatureConv();
  @override
  State<_TemperatureConv> createState() => _TemperatureConvState();
}

class _TemperatureConvState extends State<_TemperatureConv> {
  final _ctrl = TextEditingController(text: '20');
  bool _celsius = true;
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = parseNum(_ctrl.text) ?? 0;
    final c = _celsius ? v : (v - 32) * 5 / 9;
    final f = _celsius ? v * 9 / 5 + 32 : v;
    return Column(
      children: [
        NumberField(
            controller: _ctrl,
            label: 'Température',
            suffix: _celsius ? '°C' : '°F',
            allowNegative: true,
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        ChoiceSegments(
          options: const ['°C', '°F'],
          selected: _celsius ? '°C' : '°F',
          onChanged: (x) => setState(() => _celsius = x == '°C'),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Conversion',
          value: _celsius
              ? '${Fmt.number(f, decimals: 1)} °F'
              : '${Fmt.number(c, decimals: 1)} °C',
          color: AppColors.chantier,
          icon: Icons.thermostat,
          details: [
            ResultLine('Celsius', '${Fmt.number(c, decimals: 1)} °C'),
            ResultLine('Fahrenheit', '${Fmt.number(f, decimals: 1)} °F'),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  Petit cadre réutilisable pour les estimateurs simples
// ═════════════════════════════════════════════════════════════════════════
class _SurfaceInput extends StatelessWidget {
  const _SurfaceInput({
    required this.ctrl,
    required this.m2,
    required this.onUnit,
    required this.onChanged,
    this.label = 'Surface',
  });
  final TextEditingController ctrl;
  final bool m2;
  final ValueChanged<bool> onUnit;
  final VoidCallback onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          const Text('Unité : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: const ['m²', 'pi²'],
              selected: m2 ? 'm²' : 'pi²',
              onChanged: (v) => onUnit(v == 'm²'),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        NumberField(
            controller: ctrl,
            label: label,
            suffix: m2 ? 'm²' : 'pi²',
            onChanged: (_) => onChanged()),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  BARDEAUX (toiture)
// ═════════════════════════════════════════════════════════════════════════
class BardeauxScreen extends StatefulWidget {
  const BardeauxScreen({super.key});
  @override
  State<BardeauxScreen> createState() => _BardeauxScreenState();
}

class _BardeauxScreenState extends State<BardeauxScreen> {
  final _surfCtrl = TextEditingController();
  final _perteCtrl = TextEditingController(text: '10');
  bool _m2 = true;

  @override
  void dispose() {
    _surfCtrl.dispose();
    _perteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surf = parseNum(_surfCtrl.text) ?? 0;
    final perte = parseNum(_perteCtrl.text) ?? 0;
    final surfFt2 = _m2 ? surf / _m2PerFt2 : surf;
    // 1 carré = 100 pi² ; 3 paquets par carré (bardeaux d'asphalte typiques).
    final avecPerte = surfFt2 * (1 + perte / 100);
    final carres = avecPerte / 100;
    final paquets = (carres * 3).ceil();

    return ToolScaffold(
      title: 'Bardeaux',
      children: [
        const InfoBanner(
          text:
              'Estimation pour bardeaux d\'asphalte : 1 carré = 100 pi², '
              '3 paquets par carré. Entre la surface de toit RÉELLE (pente '
              'comprise). Ajuste la perte pour les noues et coupes.',
          icon: Icons.roofing,
          color: AppColors.materiaux,
        ),
        const SizedBox(height: 16),
        _SurfaceInput(
            ctrl: _surfCtrl,
            m2: _m2,
            label: 'Surface du toit',
            onUnit: (v) => setState(() => _m2 = v),
            onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        NumberField(
            controller: _perteCtrl,
            label: 'Perte',
            suffix: '%',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Bardeaux nécessaires',
          value: '$paquets paquets',
          color: AppColors.materiaux,
          icon: Icons.roofing,
          details: [
            ResultLine('Surface', '${Fmt.number(surfFt2, decimals: 0)} pi²'),
            ResultLine('Carrés (avec perte)',
                Fmt.number(carres, decimals: 2)),
            ResultLine('Paquets (3/carré)', '$paquets', strong: true),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  GRAVIER / REMBLAI (volume → tonnes)
// ═════════════════════════════════════════════════════════════════════════
class GravierScreen extends StatefulWidget {
  const GravierScreen({super.key});
  @override
  State<GravierScreen> createState() => _GravierScreenState();
}

class _GravierScreenState extends State<GravierScreen> {
  static const Map<String, double> _densite = {
    'Gravier / pierre': 1.6,
    'Sable': 1.6,
    'Terre / remblai': 1.4,
    'Asphalte': 2.3,
    'Pierre concassée 0-¾': 1.7,
  };
  final _lCtrl = TextEditingController();
  final _wCtrl = TextEditingController();
  final _epCtrl = TextEditingController();
  String _mat = 'Gravier / pierre';
  bool _metrique = true;

  @override
  void dispose() {
    _lCtrl.dispose();
    _wCtrl.dispose();
    _epCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = parseNum(_lCtrl.text) ?? 0;
    final w = parseNum(_wCtrl.text) ?? 0;
    final ep = parseNum(_epCtrl.text) ?? 0;
    final double volM3;
    if (_metrique) {
      volM3 = l * w * (ep / 100); // m × m × cm
    } else {
      volM3 = (l * w * (ep / 12)) * _m3PerFt3; // pi × pi × po
    }
    final densite = _densite[_mat]!; // t/m³
    final tonnes = volM3 * densite;

    final uBig = _metrique ? 'm' : 'pi';
    final uSmall = _metrique ? 'cm' : 'po';

    return ToolScaffold(
      title: 'Gravier & remblai',
      children: [
        const InfoBanner(
          text:
              'Volume à recouvrir → tonnes de matériau. Les densités sont '
              'approximatives (varient avec l\'humidité et le compactage).',
          icon: Icons.landscape,
          color: AppColors.materiaux,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _mat,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Matériau'),
          items: _densite.keys
              .map((k) => DropdownMenuItem(
                  value: k, child: Text('$k  (${Fmt.trim(_densite[k]!)} t/m³)')))
              .toList(),
          onChanged: (v) => setState(() => _mat = v ?? _mat),
        ),
        const SizedBox(height: 12),
        Row(children: [
          const Text('Unités : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: const ['Métrique', 'Impérial'],
              selected: _metrique ? 'Métrique' : 'Impérial',
              onChanged: (v) => setState(() => _metrique = v == 'Métrique'),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: NumberField(
                  controller: _lCtrl,
                  label: 'Longueur',
                  suffix: uBig,
                  onChanged: (_) => setState(() {}))),
          const SizedBox(width: 10),
          Expanded(
              child: NumberField(
                  controller: _wCtrl,
                  label: 'Largeur',
                  suffix: uBig,
                  onChanged: (_) => setState(() {}))),
        ]),
        const SizedBox(height: 12),
        NumberField(
            controller: _epCtrl,
            label: 'Épaisseur',
            suffix: uSmall,
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Matériau requis',
          value: '${Fmt.number(tonnes, decimals: 2)} t',
          color: AppColors.materiaux,
          icon: Icons.landscape,
          details: [
            ResultLine('Volume', '${Fmt.number(volM3, decimals: 2)} m³'),
            ResultLine('Densité', '${Fmt.trim(densite)} t/m³'),
            ResultLine('Tonnes', '${Fmt.number(tonnes, decimals: 2)} t',
                strong: true),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  CÉRAMIQUE / TUILES
// ═════════════════════════════════════════════════════════════════════════
class CeramiqueScreen extends StatefulWidget {
  const CeramiqueScreen({super.key});
  @override
  State<CeramiqueScreen> createState() => _CeramiqueScreenState();
}

class _CeramiqueScreenState extends State<CeramiqueScreen> {
  final _surfCtrl = TextEditingController();
  final _tuileCtrl = TextEditingController(text: '30'); // cm (côté)
  final _perteCtrl = TextEditingController(text: '10');
  bool _m2 = true;

  @override
  void dispose() {
    _surfCtrl.dispose();
    _tuileCtrl.dispose();
    _perteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surf = parseNum(_surfCtrl.text) ?? 0;
    final cote = parseNum(_tuileCtrl.text) ?? 30; // cm
    final perte = parseNum(_perteCtrl.text) ?? 0;
    final surfM2 = _m2 ? surf : surf * _m2PerFt2;
    final aireTuile = (cote / 100) * (cote / 100); // m²
    final nb = aireTuile > 0
        ? (surfM2 / aireTuile * (1 + perte / 100)).ceil()
        : 0;
    final boites = (nb / 10).ceil(); // ~10 tuiles/boîte (indicatif)

    return ToolScaffold(
      title: 'Céramique',
      children: [
        const InfoBanner(
          text:
              'Nombre de tuiles selon la surface et le format (tuiles carrées). '
              'Prévois de la perte pour les coupes.',
          icon: Icons.dashboard,
          color: AppColors.materiaux,
        ),
        const SizedBox(height: 16),
        _SurfaceInput(
            ctrl: _surfCtrl,
            m2: _m2,
            label: 'Surface à couvrir',
            onUnit: (v) => setState(() => _m2 = v),
            onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: NumberField(
                  controller: _tuileCtrl,
                  label: 'Côté de la tuile',
                  suffix: 'cm',
                  onChanged: (_) => setState(() {}))),
          const SizedBox(width: 10),
          Expanded(
              child: NumberField(
                  controller: _perteCtrl,
                  label: 'Perte',
                  suffix: '%',
                  onChanged: (_) => setState(() {}))),
        ]),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Tuiles nécessaires',
          value: '$nb tuiles',
          color: AppColors.materiaux,
          icon: Icons.grid_on,
          details: [
            ResultLine('Surface', '${Fmt.number(surfM2, decimals: 2)} m²'),
            ResultLine('Format', '${Fmt.trim(cote)} × ${Fmt.trim(cote)} cm'),
            ResultLine('Tuiles (avec perte)', '$nb', strong: true),
            ResultLine('Boîtes (~10/boîte)', '$boites'),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  PENTE DE TUYAU (plomberie)
// ═════════════════════════════════════════════════════════════════════════
class PenteTuyauScreen extends StatefulWidget {
  const PenteTuyauScreen({super.key});
  @override
  State<PenteTuyauScreen> createState() => _PenteTuyauScreenState();
}

class _PenteTuyauScreenState extends State<PenteTuyauScreen> {
  final _longCtrl = TextEditingController();
  final _penteCtrl = TextEditingController(text: '0.25'); // po/pi (1/4")
  bool _metres = false;

  @override
  void dispose() {
    _longCtrl.dispose();
    _penteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final long = parseNum(_longCtrl.text) ?? 0;
    final pente = parseNum(_penteCtrl.text) ?? 0; // po par pi
    final longPi = _metres ? long / 0.3048 : long;
    final chutePo = longPi * pente;
    final chuteMm = chutePo * 25.4;
    final pct = pente / 12 * 100;

    return ToolScaffold(
      title: 'Pente de tuyau',
      children: [
        const InfoBanner(
          text:
              'Chute totale d\'un tuyau selon sa longueur et sa pente. Repère '
              'courant pour le drainage : 1/4 po par pied (≈ 2 %).',
          icon: Icons.plumbing,
          color: AppColors.chantier,
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Text('Longueur en : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: const ['pi', 'm'],
              selected: _metres ? 'm' : 'pi',
              onChanged: (v) => setState(() => _metres = v == 'm'),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        NumberField(
            controller: _longCtrl,
            label: 'Longueur du tuyau',
            suffix: _metres ? 'm' : 'pi',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(
            controller: _penteCtrl,
            label: 'Pente',
            suffix: 'po/pi',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Chute totale',
          value: Fmt.inchesToFraction(chutePo),
          color: AppColors.chantier,
          icon: Icons.trending_down,
          details: [
            ResultLine('Chute (décimal)',
                '${Fmt.number(chutePo, decimals: 2)} po'),
            ResultLine('Millimètres', '${Fmt.number(chuteMm, decimals: 0)} mm'),
            ResultLine('Pourcentage', Fmt.percent(pct), strong: true),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  ÉCHELLE SÉCURITAIRE (règle 4:1)
// ═════════════════════════════════════════════════════════════════════════
class EchelleScreen extends StatefulWidget {
  const EchelleScreen({super.key});
  @override
  State<EchelleScreen> createState() => _EchelleScreenState();
}

class _EchelleScreenState extends State<EchelleScreen> {
  final _hCtrl = TextEditingController();
  bool _metres = true;

  @override
  void dispose() {
    _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = parseNum(_hCtrl.text) ?? 0; // hauteur du point d'appui
    final recul = h / 4; // règle 4:1
    final longueur =
        (h * h + recul * recul); // au carré → racine ci-dessous
    final longEchelle = longueur > 0 ? _sqrt(longueur) : 0.0;
    final u = _metres ? 'm' : 'pi';

    return ToolScaffold(
      title: 'Échelle sécuritaire',
      children: [
        const InfoBanner(
          text:
              'Règle 4:1 (75°) : pour chaque 4 unités de hauteur, éloigne la '
              'base de 1 unité du mur. Une échelle d\'appui doit dépasser le '
              'palier d\'environ 1 m (3 pi).',
          icon: Icons.stairs,
          color: AppColors.chantier,
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Text('Unités : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: const ['m', 'pi'],
              selected: _metres ? 'm' : 'pi',
              onChanged: (v) => setState(() => _metres = v == 'm'),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        NumberField(
            controller: _hCtrl,
            label: 'Hauteur du point d\'appui',
            suffix: u,
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Recul de la base',
          value: '${Fmt.number(recul, decimals: 2)} $u',
          color: AppColors.chantier,
          icon: Icons.architecture,
          details: [
            ResultLine('Hauteur', '${Fmt.trim(h)} $u'),
            ResultLine('Recul (¼ de la hauteur)',
                '${Fmt.number(recul, decimals: 2)} $u', strong: true),
            ResultLine('Longueur d\'échelle min.',
                '${Fmt.number(longEchelle, decimals: 2)} $u'),
          ],
        ),
      ],
    );
  }

  double _sqrt(double x) {
    double g = x;
    for (int i = 0; i < 40; i++) {
      g = (g + x / g) / 2;
    }
    return g;
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  SOLIVES / POUTRELLES
// ═════════════════════════════════════════════════════════════════════════
class SolivesScreen extends StatefulWidget {
  const SolivesScreen({super.key});
  @override
  State<SolivesScreen> createState() => _SolivesScreenState();
}

class _SolivesScreenState extends State<SolivesScreen> {
  final _longCtrl = TextEditingController();
  bool _metres = false;
  int _entraxe = 16; // pouces

  @override
  void dispose() {
    _longCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final long = parseNum(_longCtrl.text) ?? 0;
    final longPo = _metres ? long * 1000 / 25.4 : long * 12;
    final nb = longPo > 0 ? (longPo / _entraxe).ceil() + 1 : 0;

    return ToolScaffold(
      title: 'Solives / poutrelles',
      children: [
        const InfoBanner(
          text:
              'Nombre de solives pour un plancher ou un plafond selon la '
              'longueur du mur porteur et l\'entraxe. Ajoute le doublage aux '
              'extrémités et sous les cloisons.',
          icon: Icons.view_week,
          color: AppColors.charpente,
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Text('Longueur en : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: const ['pi', 'm'],
              selected: _metres ? 'm' : 'pi',
              onChanged: (v) => setState(() => _metres = v == 'm'),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        NumberField(
            controller: _longCtrl,
            label: 'Longueur (mur porteur)',
            suffix: _metres ? 'm' : 'pi',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 14),
        Text('Entraxe (centre à centre)',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        ChoiceSegments(
          options: const ['12', '16', '19,2', '24'],
          selected: _entraxe == 12
              ? '12'
              : _entraxe == 16
                  ? '16'
                  : _entraxe == 24
                      ? '24'
                      : '19,2',
          onChanged: (v) => setState(() => _entraxe = v == '12'
              ? 12
              : v == '16'
                  ? 16
                  : v == '24'
                      ? 24
                      : 19),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Solives nécessaires',
          value: '$nb',
          color: AppColors.charpente,
          icon: Icons.view_week,
          details: [
            ResultLine('Entraxe', '$_entraxe po c/c'),
            ResultLine('(longueur ÷ entraxe) + 1', '$nb', strong: true),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  COMPARATEUR DE GRILLES (même métier, 5 conventions)
// ═════════════════════════════════════════════════════════════════════════
class ComparateurScreen extends StatefulWidget {
  const ComparateurScreen({super.key});
  @override
  State<ComparateurScreen> createState() => _ComparateurScreenState();
}

class _ComparateurScreenState extends State<ComparateurScreen> {
  Metier _metier = CcqData.metiers.firstWhere((m) => m.nom == 'Électricien',
      orElse: () => CcqData.metiers.first);

  @override
  Widget build(BuildContext context) {
    final taux = {
      for (final s in Secteur.values) s: CcqData.tauxCompagnon(_metier, s)
    };
    final maxTaux = taux.values.fold(0.0, (m, v) => v > m ? v : m);
    final onSurf = Theme.of(context).colorScheme.onSurface;

    return ToolScaffold(
      title: 'Comparateur de grilles',
      children: [
        const InfoBanner(
          text:
              'Le même métier (compagnon) payé selon les 5 conventions. '
              'En vigueur le 26 avril 2026 — à valider sur ccq.org.',
          icon: Icons.compare_arrows,
          color: AppColors.paie,
        ),
        const SizedBox(height: 16),
        MetierField(
          metier: _metier,
          color: AppColors.paie,
          onChanged: (m) => setState(() => _metier = m),
        ),
        const SizedBox(height: 18),
        for (final s in Secteur.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(s.nom,
                          style: TextStyle(
                              fontSize: 13,
                              color: onSurf.withValues(alpha: 0.8))),
                    ),
                    Text('${Fmt.money(taux[s]!)}/h',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.paie)),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: maxTaux > 0 ? taux[s]! / maxTaux : 0,
                    minHeight: 9,
                    backgroundColor: AppColors.paie.withValues(alpha: 0.10),
                    valueColor: const AlwaysStoppedAnimation(AppColors.paie),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  SALAIRE HORAIRE -> ANNUEL
// ═════════════════════════════════════════════════════════════════════════
class SalaireAnnuelScreen extends StatefulWidget {
  const SalaireAnnuelScreen({super.key});
  @override
  State<SalaireAnnuelScreen> createState() => _SalaireAnnuelScreenState();
}

class _SalaireAnnuelScreenState extends State<SalaireAnnuelScreen> {
  final _tauxCtrl = TextEditingController(text: '43.90');
  final _hSemCtrl = TextEditingController(text: '40');
  final _semCtrl = TextEditingController(text: '50');

  @override
  void dispose() {
    _tauxCtrl.dispose();
    _hSemCtrl.dispose();
    _semCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taux = parseNum(_tauxCtrl.text) ?? 0;
    final hSem = parseNum(_hSemCtrl.text) ?? 0;
    final sem = parseNum(_semCtrl.text) ?? 0;
    final hebdo = taux * hSem;
    final annuel = hebdo * sem;

    return ToolScaffold(
      title: 'Salaire annuel',
      children: [
        const InfoBanner(
          text:
              'Estime ton revenu annuel selon ton taux, tes heures par semaine '
              'et le nombre de semaines travaillées (la construction est '
              'saisonnière — souvent moins de 52 semaines).',
          icon: Icons.calendar_month,
          color: AppColors.paie,
        ),
        const SizedBox(height: 16),
        NumberField(
            controller: _tauxCtrl,
            label: 'Taux horaire',
            suffix: '\$/h',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: NumberField(
                  controller: _hSemCtrl,
                  label: 'Heures / semaine',
                  suffix: 'h',
                  onChanged: (_) => setState(() {}))),
          const SizedBox(width: 10),
          Expanded(
              child: NumberField(
                  controller: _semCtrl,
                  label: 'Semaines / an',
                  onChanged: (_) => setState(() {}))),
        ]),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Revenu annuel (brut)',
          value: Fmt.money(annuel),
          color: AppColors.paie,
          icon: Icons.savings,
          details: [
            ResultLine('Par semaine', Fmt.money(hebdo)),
            ResultLine('Annuel (${Fmt.trim(sem)} sem.)', Fmt.money(annuel),
                strong: true),
            ResultLine('Avec congés 13 %', Fmt.money(annuel * 1.13)),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  AIRES COMPLEXES (trapèze, forme en L)
// ═════════════════════════════════════════════════════════════════════════
class AiresScreen extends StatefulWidget {
  const AiresScreen({super.key});
  @override
  State<AiresScreen> createState() => _AiresScreenState();
}

class _AiresScreenState extends State<AiresScreen> {
  String _forme = 'Trapèze';
  final _aCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  final _cCtrl = TextEditingController();
  final _dCtrl = TextEditingController();
  bool _m = true;

  @override
  void dispose() {
    _aCtrl.dispose();
    _bCtrl.dispose();
    _cCtrl.dispose();
    _dCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = parseNum(_aCtrl.text) ?? 0;
    final b = parseNum(_bCtrl.text) ?? 0;
    final c = parseNum(_cCtrl.text) ?? 0;
    final d = parseNum(_dCtrl.text) ?? 0;
    final double aire =
        _forme == 'Trapèze' ? (a + b) / 2 * c : a * b - c * d;
    final aireM2 = _m ? aire : aire * _m2PerFt2;
    final aireFt2 = _m ? aire / _m2PerFt2 : aire;
    final u = _m ? 'm' : 'pi';

    return ToolScaffold(
      title: 'Aires complexes',
      children: [
        ChoiceSegments(
          options: const ['Trapèze', 'Forme en L'],
          selected: _forme,
          onChanged: (v) => setState(() => _forme = v),
        ),
        const SizedBox(height: 12),
        Row(children: [
          const Text('Unité : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: const ['m', 'pi'],
              selected: _m ? 'm' : 'pi',
              onChanged: (v) => setState(() => _m = v == 'm'),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        if (_forme == 'Trapèze') ...[
          Row(children: [
            Expanded(
                child: NumberField(
                    controller: _aCtrl,
                    label: 'Base 1',
                    suffix: u,
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(
                child: NumberField(
                    controller: _bCtrl,
                    label: 'Base 2',
                    suffix: u,
                    onChanged: (_) => setState(() {}))),
          ]),
          const SizedBox(height: 12),
          NumberField(
              controller: _cCtrl,
              label: 'Hauteur',
              suffix: u,
              onChanged: (_) => setState(() {})),
        ] else ...[
          const _LigneTitre('Rectangle total'),
          Row(children: [
            Expanded(
                child: NumberField(
                    controller: _aCtrl,
                    label: 'Longueur',
                    suffix: u,
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(
                child: NumberField(
                    controller: _bCtrl,
                    label: 'Largeur',
                    suffix: u,
                    onChanged: (_) => setState(() {}))),
          ]),
          const SizedBox(height: 12),
          const _LigneTitre('Encoche à retrancher'),
          Row(children: [
            Expanded(
                child: NumberField(
                    controller: _cCtrl,
                    label: 'Longueur',
                    suffix: u,
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(
                child: NumberField(
                    controller: _dCtrl,
                    label: 'Largeur',
                    suffix: u,
                    onChanged: (_) => setState(() {}))),
          ]),
        ],
        const SizedBox(height: 22),
        ResultCard(
          label: 'Aire',
          value: '${Fmt.number(aireM2, decimals: 2)} m²',
          color: AppColors.chantier,
          icon: Icons.crop_free,
          details: [
            ResultLine('Pieds carrés', '${Fmt.number(aireFt2, decimals: 2)} pi²'),
            ResultLine('Mètres carrés', '${Fmt.number(aireM2, decimals: 2)} m²',
                strong: true),
          ],
        ),
      ],
    );
  }
}

class _LigneTitre extends StatelessWidget {
  const _LigneTitre(this.t);
  final String t;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7))),
      );
}

// ═════════════════════════════════════════════════════════════════════════
//  SCELLANT / CALFEUTRANT
// ═════════════════════════════════════════════════════════════════════════
class ScellantScreen extends StatefulWidget {
  const ScellantScreen({super.key});
  @override
  State<ScellantScreen> createState() => _ScellantScreenState();
}

class _ScellantScreenState extends State<ScellantScreen> {
  final _longCtrl = TextEditingController();
  final _rendCtrl = TextEditingController(text: '12');
  bool _metres = true;

  @override
  void dispose() {
    _longCtrl.dispose();
    _rendCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final long = parseNum(_longCtrl.text) ?? 0;
    final rend = parseNum(_rendCtrl.text) ?? 12;
    final longM = _metres ? long : long * 0.3048;
    final tubes = rend > 0 ? (longM / rend).ceil() : 0;

    return ToolScaffold(
      title: 'Scellant',
      children: [
        const InfoBanner(
          text:
              'Nombre de tubes de scellant selon la longueur de joint. Un tube '
              'de 300 mL fait environ 12 m pour un joint de 6 mm (varie selon '
              'la taille du joint).',
          icon: Icons.water_drop,
          color: AppColors.materiaux,
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Text('Longueur en : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: const ['m', 'pi'],
              selected: _metres ? 'm' : 'pi',
              onChanged: (v) => setState(() => _metres = v == 'm'),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        NumberField(
            controller: _longCtrl,
            label: 'Longueur de joint',
            suffix: _metres ? 'm' : 'pi',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(
            controller: _rendCtrl,
            label: 'Rendement d\'un tube',
            suffix: 'm/tube',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Tubes nécessaires',
          value: '$tubes tubes',
          color: AppColors.materiaux,
          icon: Icons.water_drop,
          details: [
            ResultLine('Longueur', '${Fmt.number(longM, decimals: 1)} m'),
            ResultLine('Rendement', '${Fmt.trim(rend)} m/tube'),
            ResultLine('Tubes (300 mL)', '$tubes', strong: true),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  FRACTIONS AVANCÉES (additionner / soustraire)
// ═════════════════════════════════════════════════════════════════════════
const List<String> _seiziemes = [
  '0', '1/16', '1/8', '3/16', '1/4', '5/16', '3/8', '7/16',
  '1/2', '9/16', '5/8', '11/16', '3/4', '13/16', '7/8', '15/16'
];

class FractionsAvanceesScreen extends StatefulWidget {
  const FractionsAvanceesScreen({super.key});
  @override
  State<FractionsAvanceesScreen> createState() =>
      _FractionsAvanceesScreenState();
}

class _FractionsAvanceesScreenState extends State<FractionsAvanceesScreen> {
  final _piA = TextEditingController();
  final _poA = TextEditingController();
  final _piB = TextEditingController();
  final _poB = TextEditingController();
  int _fA = 0;
  int _fB = 0;
  String _op = '+';

  @override
  void dispose() {
    _piA.dispose();
    _poA.dispose();
    _piB.dispose();
    _poB.dispose();
    super.dispose();
  }

  double _mesure(TextEditingController pi, TextEditingController po, int f) =>
      (parseNum(pi.text) ?? 0) * 12 + (parseNum(po.text) ?? 0) + f / 16;

  @override
  Widget build(BuildContext context) {
    final a = _mesure(_piA, _poA, _fA);
    final b = _mesure(_piB, _poB, _fB);
    final res = _op == '+' ? a + b : a - b;

    return ToolScaffold(
      title: 'Fractions avancées',
      children: [
        const InfoBanner(
          text:
              'Additionne ou soustrais deux mesures en pieds, pouces et '
              'fraction (au 1/16).',
          icon: Icons.calculate,
          color: AppColors.chantier,
        ),
        const SizedBox(height: 16),
        _mesureInput('Mesure A', _piA, _poA, _fA, (v) => setState(() => _fA = v)),
        const SizedBox(height: 12),
        ChoiceSegments(
          options: const ['+', '−'],
          selected: _op,
          onChanged: (v) => setState(() => _op = v),
        ),
        const SizedBox(height: 12),
        _mesureInput('Mesure B', _piB, _poB, _fB, (v) => setState(() => _fB = v)),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Résultat',
          value: Fmt.inchesToFeetInches(res),
          color: AppColors.chantier,
          icon: Icons.functions,
          details: [
            ResultLine('En pouces', '${Fmt.trim(res)} po'),
            ResultLine('Fraction', Fmt.inchesToFraction(res)),
            ResultLine('Millimètres',
                '${Fmt.number(res * 25.4, decimals: 0)} mm', strong: true),
          ],
        ),
      ],
    );
  }

  Widget _mesureInput(String titre, TextEditingController pi,
      TextEditingController po, int f, ValueChanged<int> onF) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titre,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: NumberField(
                  controller: pi,
                  label: 'Pieds',
                  suffix: 'pi',
                  onChanged: (_) => setState(() {}))),
          const SizedBox(width: 8),
          Expanded(
              child: NumberField(
                  controller: po,
                  label: 'Pouces',
                  suffix: 'po',
                  onChanged: (_) => setState(() {}))),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: f,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Fract.'),
              items: [
                for (int i = 0; i < _seiziemes.length; i++)
                  DropdownMenuItem(value: i, child: Text(_seiziemes[i])),
              ],
              onChanged: (v) => onF(v ?? 0),
            ),
          ),
        ]),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  CONVERTISSEUR DE PENTE (% ↔ x/12 ↔ degrés)
// ═════════════════════════════════════════════════════════════════════════
class PenteConvScreen extends StatefulWidget {
  const PenteConvScreen({super.key});
  @override
  State<PenteConvScreen> createState() => _PenteConvScreenState();
}

class _PenteConvScreenState extends State<PenteConvScreen> {
  final _ctrl = TextEditingController(text: '6');
  String _mode = 'x/12';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = parseNum(_ctrl.text) ?? 0;
    double ratio; // montée pour 12 de course
    if (_mode == '%') {
      ratio = v / 100 * 12;
    } else if (_mode == '°') {
      ratio = math.tan(v * math.pi / 180) * 12;
    } else {
      ratio = v;
    }
    final pct = ratio / 12 * 100;
    final deg = math.atan(ratio / 12) * 180 / math.pi;

    return ToolScaffold(
      title: 'Convertisseur de pente',
      children: [
        const InfoBanner(
          text:
              'Convertis une pente entre « montée/12 », pourcentage et degrés.',
          icon: Icons.show_chart,
          color: AppColors.chantier,
        ),
        const SizedBox(height: 16),
        ChoiceSegments(
          options: const ['x/12', '%', '°'],
          selected: _mode,
          onChanged: (m) => setState(() => _mode = m),
        ),
        const SizedBox(height: 14),
        NumberField(
          controller: _ctrl,
          label: _mode == 'x/12'
              ? 'Montée (pour 12)'
              : _mode == '%'
                  ? 'Pourcentage'
                  : 'Degrés',
          suffix: _mode == '%' ? '%' : (_mode == '°' ? '°' : '/12'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Pente',
          value: '${Fmt.trim(ratio, maxDecimals: 2)} / 12',
          color: AppColors.chantier,
          icon: Icons.show_chart,
          details: [
            ResultLine('Pente (x/12)', '${Fmt.trim(ratio, maxDecimals: 2)} / 12'),
            ResultLine('Pourcentage', Fmt.percent(pct)),
            ResultLine('Degrés', '${Fmt.number(deg, decimals: 1)}°', strong: true),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  COFFRAGE (mur de béton)
// ═════════════════════════════════════════════════════════════════════════
class CoffrageScreen extends StatefulWidget {
  const CoffrageScreen({super.key});
  @override
  State<CoffrageScreen> createState() => _CoffrageScreenState();
}

class _CoffrageScreenState extends State<CoffrageScreen> {
  final _longCtrl = TextEditingController();
  final _hautCtrl = TextEditingController();
  final _perteCtrl = TextEditingController(text: '10');
  int _entraxe = 16;

  @override
  void dispose() {
    _longCtrl.dispose();
    _hautCtrl.dispose();
    _perteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final long = parseNum(_longCtrl.text) ?? 0; // pi
    final haut = parseNum(_hautCtrl.text) ?? 0; // pi
    final perte = parseNum(_perteCtrl.text) ?? 0;
    final faceFt2 = long * haut;
    final feuilles = ((2 * faceFt2 / 32) * (1 + perte / 100)).ceil();
    final montantsFace = long > 0 ? (long * 12 / _entraxe).ceil() + 1 : 0;
    final montants = montantsFace * 2;

    return ToolScaffold(
      title: 'Coffrage de mur',
      children: [
        const InfoBanner(
          text:
              'Estimation pour un coffrage de mur : contreplaqué (2 faces, '
              'feuilles 4×8) et montants aux deux faces. Ajoute lisses, '
              'entretoises et attaches selon ta méthode.',
          icon: Icons.foundation,
          color: AppColors.materiaux,
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: NumberField(
                  controller: _longCtrl,
                  label: 'Longueur',
                  suffix: 'pi',
                  onChanged: (_) => setState(() {}))),
          const SizedBox(width: 10),
          Expanded(
              child: NumberField(
                  controller: _hautCtrl,
                  label: 'Hauteur',
                  suffix: 'pi',
                  onChanged: (_) => setState(() {}))),
        ]),
        const SizedBox(height: 12),
        NumberField(
            controller: _perteCtrl,
            label: 'Perte',
            suffix: '%',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 14),
        Text('Entraxe des montants',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        ChoiceSegments(
          options: const ['12', '16', '24'],
          selected: '$_entraxe',
          onChanged: (v) => setState(() => _entraxe = int.parse(v)),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Matériaux de coffrage',
          value: '$feuilles feuilles',
          color: AppColors.materiaux,
          icon: Icons.foundation,
          details: [
            ResultLine('Surface (1 face)',
                '${Fmt.number(faceFt2, decimals: 0)} pi²'),
            ResultLine('Feuilles 4×8 (2 faces)', '$feuilles', strong: true),
            ResultLine('Montants ($_entraxe po, 2 faces)', '$montants'),
          ],
        ),
      ],
    );
  }
}
