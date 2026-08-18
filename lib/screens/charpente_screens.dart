import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

// ─────────────────────────────────────────────────────────────────────────
//  PENTE DE TOIT
// ─────────────────────────────────────────────────────────────────────────
class PenteToitScreen extends StatefulWidget {
  const PenteToitScreen({super.key});

  @override
  State<PenteToitScreen> createState() => _PenteToitScreenState();
}

class _PenteToitScreenState extends State<PenteToitScreen> {
  final _monteeCtrl = TextEditingController(text: '6');
  final _courseCtrl = TextEditingController(text: '12');

  @override
  void dispose() {
    _monteeCtrl.dispose();
    _courseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double montee = parseNum(_monteeCtrl.text) ?? 0;
    final double course = parseNum(_courseCtrl.text) ?? 0;

    final double ratio12 = course != 0 ? montee / course * 12 : 0;
    final double angle = Fmt.slopeToDegrees(montee, course);
    final double pct = course != 0 ? montee / course * 100 : 0;
    final double chevron = math.sqrt(montee * montee + course * course);

    return ToolScaffold(
      title: tr('Pente de toit', 'Roof pitch'),
      children: [
        InfoBanner(
          text: tr(
              'Entre la montée et la course dans la même unité. La pente de '
                  'toit s\'exprime en « montée / 12 » (ex. 6/12).',
              'Enter rise and run in the same unit. Roof pitch is expressed as '
                  '« rise / 12 » (e.g. 6/12).'),
          icon: Icons.roofing,
          color: AppColors.charpente,
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _monteeCtrl,
          label: tr('Montée (rise)', 'Rise'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _courseCtrl,
          label: tr('Course (run)', 'Run'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Pente', 'Pitch'),
          value: '${Fmt.trim(ratio12, maxDecimals: 1)} / 12',
          color: AppColors.charpente,
          icon: Icons.change_history,
          details: [
            ResultLine(tr('Angle', 'Angle'), '${Fmt.number(angle, decimals: 1)}°'),
            ResultLine(tr('Pourcentage', 'Percentage'), Fmt.percent(pct)),
            ResultLine(tr('Longueur du chevron (par unité)',
                'Rafter length (per unit)'),
                Fmt.trim(chevron, maxDecimals: 3),
                strong: true),
          ],
        ),
        const SizedBox(height: 12),
        InfoBanner(
          text: tr(
              'Le chevron est calculé pour la montée et la course entrées '
                  '(√(montée² + course²)). Multiplie par la portée réelle pour '
                  'la longueur totale.',
              'The rafter is computed for the rise and run entered '
                  '(√(rise² + run²)). Multiply by the actual span for the total '
                  'length.'),
          icon: Icons.info_outline,
          color: AppColors.charpente,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  ESCALIER
// ─────────────────────────────────────────────────────────────────────────
class EscalierScreen extends StatefulWidget {
  const EscalierScreen({super.key});

  @override
  State<EscalierScreen> createState() => _EscalierScreenState();
}

class _EscalierScreenState extends State<EscalierScreen> {
  final _hauteurCtrl = TextEditingController();
  final _cmCibleCtrl = TextEditingController();
  final _gironCtrl = TextEditingController();
  bool _metrique = true;

  @override
  void initState() {
    super.initState();
    _appliquerDefauts();
  }

  void _appliquerDefauts() {
    _cmCibleCtrl.text = _metrique ? '180' : '7';
    _gironCtrl.text = _metrique ? '255' : '10';
  }

  @override
  void dispose() {
    _hauteurCtrl.dispose();
    _cmCibleCtrl.dispose();
    _gironCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double hauteur = parseNum(_hauteurCtrl.text) ?? 0;
    final double cible = parseNum(_cmCibleCtrl.text) ?? 1;
    final double giron = parseNum(_gironCtrl.text) ?? 0;

    final int nbCm =
        (cible > 0 && hauteur > 0) ? math.max(1, (hauteur / cible).round()) : 0;
    final double hauteurReelle = nbCm > 0 ? hauteur / nbCm : 0;
    final int nbGirons = nbCm > 0 ? nbCm - 1 : 0;
    final double longueur = nbGirons * giron;

    final String uSmall = _metrique ? 'mm' : tr('po', 'in');
    final String metr = tr('Métrique', 'Metric');
    final String imp = tr('Impérial', 'Imperial');

    return ToolScaffold(
      title: tr('Escalier', 'Stairs'),
      children: [
        Row(
          children: [
            Text('${tr('Unités', 'Units')} : '),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceSegments(
                options: [metr, imp],
                selected: _metrique ? metr : imp,
                onChanged: (v) => setState(() {
                  _metrique = v == metr;
                  _appliquerDefauts();
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        NumberField(
          controller: _hauteurCtrl,
          label: tr('Hauteur totale à monter', 'Total rise'),
          suffix: uSmall,
          hint: _metrique ? tr('ex. 2 750', 'e.g. 2,750') : tr('ex. 108', 'e.g. 108'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _cmCibleCtrl,
          label: tr('Hauteur de contremarche visée', 'Target riser height'),
          suffix: uSmall,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _gironCtrl,
          label: tr('Giron (profondeur de marche)', 'Tread (step depth)'),
          suffix: uSmall,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Escalier', 'Stairs'),
          value: '$nbCm ${tr('contremarches', 'risers')}',
          color: AppColors.charpente,
          icon: Icons.stairs,
          details: [
            ResultLine(
                tr('Hauteur réelle / contremarche', 'Actual riser height'),
                '${Fmt.number(hauteurReelle, decimals: 1)} $uSmall',
                strong: true),
            ResultLine(tr('Nombre de marches (girons)', 'Number of treads'),
                '$nbGirons'),
            ResultLine(tr('Longueur horizontale totale', 'Total horizontal length'),
                '${Fmt.number(longueur, decimals: 1)} $uSmall'),
          ],
        ),
        const SizedBox(height: 12),
        InfoBanner(
          text: tr(
              'Repères usuels (résidentiel) : contremarche ≈ 125–200 mm, '
                  'giron ≥ 255 mm. Toujours vérifier le Code du bâtiment '
                  'applicable à ton projet.',
              'Usual guides (residential): riser ≈ 125–200 mm, tread ≥ 255 mm. '
                  'Always check the Building Code that applies to your project.'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  ÉQUERRE 3-4-5 / PYTHAGORE
// ─────────────────────────────────────────────────────────────────────────
class EquerreScreen extends StatefulWidget {
  const EquerreScreen({super.key});

  @override
  State<EquerreScreen> createState() => _EquerreScreenState();
}

class _EquerreScreenState extends State<EquerreScreen> {
  final _aCtrl = TextEditingController();
  final _bCtrl = TextEditingController();

  @override
  void dispose() {
    _aCtrl.dispose();
    _bCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double a = parseNum(_aCtrl.text) ?? 0;
    final double b = parseNum(_bCtrl.text) ?? 0;
    final double c = math.sqrt(a * a + b * b);

    return ToolScaffold(
      title: tr('Équerre 3-4-5', 'Square 3-4-5'),
      children: [
        InfoBanner(
          text: tr(
              'Méthode 3-4-5 pour vérifier un angle droit : mesure 3 sur un '
                  'côté, 4 sur l\'autre — la diagonale doit faire 5 (ou tout '
                  'multiple : 6-8-10, 9-12-15…).',
              '3-4-5 method to check a right angle: measure 3 on one side, 4 on '
                  'the other — the diagonal must be 5 (or any multiple: 6-8-10, '
                  '9-12-15…).'),
          icon: Icons.square_foot,
          color: AppColors.charpente,
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _aCtrl,
          label: tr('Côté A', 'Side A'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _bCtrl,
          label: tr('Côté B', 'Side B'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Diagonale (hypoténuse)', 'Diagonal (hypotenuse)'),
          value: Fmt.trim(c, maxDecimals: 4),
          color: AppColors.charpente,
          icon: Icons.details,
          details: [
            ResultLine(tr('Côté A', 'Side A'), Fmt.trim(a)),
            ResultLine(tr('Côté B', 'Side B'), Fmt.trim(b)),
            ResultLine('√(A² + B²)', Fmt.trim(c, maxDecimals: 4), strong: true),
          ],
        ),
        const SizedBox(height: 12),
        InfoBanner(
          text: tr(
              'Pour équarrir une pièce ou un coffrage : mesure les deux '
                  'diagonales. Si elles sont égales, c\'est d\'équerre.',
              'To square a room or a form: measure both diagonals. If they are '
                  'equal, it is square.'),
          icon: Icons.crop_rotate,
          color: AppColors.charpente,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  MATÉRIAUX (montants & feuilles)
// ─────────────────────────────────────────────────────────────────────────
class MateriauxScreen extends StatefulWidget {
  const MateriauxScreen({super.key});

  @override
  State<MateriauxScreen> createState() => _MateriauxScreenState();
}

class _MateriauxScreenState extends State<MateriauxScreen> {
  String _type = 'Montants';

  final _murCtrl = TextEditingController();
  bool _murMetres = false;
  int _espacement = 16;

  final _surfaceCtrl = TextEditingController();
  bool _surfM2 = false;
  final _perteCtrl = TextEditingController(text: '10');

  static const double ft2PerSheet = 32;
  static const double m2PerFt2 = 0.09290304;

  @override
  void dispose() {
    _murCtrl.dispose();
    _surfaceCtrl.dispose();
    _perteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> types = {
      'Montants': tr('Montants', 'Studs'),
      'Feuilles 4×8': tr('Feuilles 4×8', 'Sheets 4×8'),
    };
    return ToolScaffold(
      title: tr('Matériaux', 'Materials'),
      children: [
        ChoiceSegments(
          options: types.values.toList(),
          selected: types[_type]!,
          onChanged: (v) => setState(
              () => _type = types.keys.firstWhere((k) => types[k] == v)),
        ),
        const SizedBox(height: 18),
        if (_type == 'Montants')
          ..._montants()
        else
          ..._feuilles(),
      ],
    );
  }

  List<Widget> _montants() {
    final double mur = parseNum(_murCtrl.text) ?? 0;
    final double murPo = _murMetres ? mur * 1000 / Fmt.mmPerInch : mur * 12;
    final int nb = murPo > 0 ? (murPo / _espacement).ceil() + 1 : 0;
    final String pi = tr('pi', 'ft');

    return [
      Row(
        children: [
          Text('${tr('Longueur en', 'Length in')} : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: [pi, 'm'],
              selected: _murMetres ? 'm' : pi,
              onChanged: (v) => setState(() => _murMetres = v == 'm'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      NumberField(
        controller: _murCtrl,
        label: tr('Longueur du mur', 'Wall length'),
        suffix: _murMetres ? 'm' : pi,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      Text(tr('Espacement (centre à centre)', 'Spacing (center to center)'),
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
      const SizedBox(height: 8),
      ChoiceSegments(
        options: const ['16', '24'],
        selected: '$_espacement',
        onChanged: (v) => setState(() => _espacement = int.parse(v)),
      ),
      const SizedBox(height: 22),
      ResultCard(
        label: tr('Montants nécessaires', 'Studs needed'),
        value: '$nb ${tr('montants', 'studs')}',
        color: AppColors.charpente,
        icon: Icons.view_week,
        details: [
          ResultLine(tr('Espacement', 'Spacing'),
              '$_espacement ${tr('po c/c', 'in o.c.')}'),
          ResultLine(
              tr('(longueur ÷ espacement) + 1', '(length ÷ spacing) + 1'), '$nb',
              strong: true),
        ],
      ),
      const SizedBox(height: 12),
      InfoBanner(
        text: tr(
            'Estimation pour un mur droit : ajoute les montants d\'extrémité, '
                'les coins, les ouvertures (linteaux, poteaux jumelés) et une '
                'marge selon le plan.',
            'Estimate for a straight wall: add end studs, corners, openings '
                '(headers, jack studs) and a margin per the plan.'),
      ),
    ];
  }

  List<Widget> _feuilles() {
    final double surf = parseNum(_surfaceCtrl.text) ?? 0;
    final double perte = parseNum(_perteCtrl.text) ?? 0;
    final double surfFt2 = _surfM2 ? surf / m2PerFt2 : surf;
    final double surfAvecPerte = surfFt2 * (1 + perte / 100);
    final int feuilles = surfFt2 > 0 ? (surfAvecPerte / ft2PerSheet).ceil() : 0;
    final String pi2 = tr('pi²', 'ft²');

    return [
      Row(
        children: [
          Text('${tr('Surface en', 'Area in')} : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: [pi2, 'm²'],
              selected: _surfM2 ? 'm²' : pi2,
              onChanged: (v) => setState(() => _surfM2 = v == 'm²'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      NumberField(
        controller: _surfaceCtrl,
        label: tr('Surface à couvrir', 'Area to cover'),
        suffix: _surfM2 ? 'm²' : pi2,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      NumberField(
        controller: _perteCtrl,
        label: tr('Perte / coupes', 'Waste / cuts'),
        suffix: '%',
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 22),
      ResultCard(
        label: tr('Feuilles 4×8 (32 pi²)', 'Sheets 4×8 (32 ft²)'),
        value: '$feuilles ${tr('feuilles', 'sheets')}',
        color: AppColors.charpente,
        icon: Icons.dashboard,
        details: [
          ResultLine(tr('Surface', 'Area'),
              '${Fmt.number(surfFt2, decimals: 1)} $pi2'),
          ResultLine('${tr('Avec perte', 'With waste')} (${Fmt.trim(perte)} %)',
              '${Fmt.number(surfAvecPerte, decimals: 1)} $pi2'),
          ResultLine(tr('Feuilles nécessaires', 'Sheets needed'), '$feuilles',
              strong: true),
        ],
      ),
      const SizedBox(height: 12),
      InfoBanner(
        text: tr(
            'Feuille standard de 4 pi × 8 pi = 32 pi² (gyproc, contreplaqué, '
                'OSB). Ajuste la perte selon la complexité des découpes.',
            'Standard 4 ft × 8 ft sheet = 32 ft² (drywall, plywood, OSB). '
                'Adjust waste for cut complexity.'),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  ANGLES DE COUPE (onglet)
// ─────────────────────────────────────────────────────────────────────────
class AnglesScreen extends StatefulWidget {
  const AnglesScreen({super.key});

  @override
  State<AnglesScreen> createState() => _AnglesScreenState();
}

class _AnglesScreenState extends State<AnglesScreen> {
  final _coinCtrl = TextEditingController(text: '90');

  @override
  void dispose() {
    _coinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double coin = parseNum(_coinCtrl.text) ?? 0;
    final double onglet = coin / 2;
    final double scie = 90 - onglet;

    return ToolScaffold(
      title: tr('Angles de coupe', 'Cut angles'),
      children: [
        InfoBanner(
          text: tr(
              'Pour un joint d\'onglet, chaque pièce se coupe à la moitié de '
                  'l\'angle du coin. Entre l\'angle mesuré du coin (90° pour un '
                  'coin carré).',
              'For a miter joint, each piece is cut at half the corner angle. '
                  'Enter the measured corner angle (90° for a square corner).'),
          icon: Icons.details,
          color: AppColors.charpente,
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _coinCtrl,
          label: tr('Angle du coin', 'Corner angle'),
          suffix: '°',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Angle d\'onglet (par pièce)', 'Miter angle (per piece)'),
          value: '${Fmt.number(onglet, decimals: 1)}°',
          color: AppColors.charpente,
          icon: Icons.content_cut,
          details: [
            ResultLine(tr('Angle du coin', 'Corner angle'), '${Fmt.trim(coin)}°'),
            ResultLine(tr('Onglet (coin ÷ 2)', 'Miter (corner ÷ 2)'),
                '${Fmt.number(onglet, decimals: 1)}°', strong: true),
            ResultLine(tr('Réglage scie (depuis 90°)', 'Saw setting (from 90°)'),
                '${Fmt.number(scie, decimals: 1)}°'),
          ],
        ),
        const SizedBox(height: 12),
        InfoBanner(
          text: tr(
              'Selon ta scie à onglet, l\'échelle part de 0° (coupe droite) : '
                  'règle alors à « réglage scie ». Coin carré 90° → onglet 45°.',
              'Depending on your miter saw, the scale starts at 0° (straight '
                  'cut): set it to « saw setting ». Square corner 90° → miter '
                  '45°.'),
          icon: Icons.info_outline,
          color: AppColors.charpente,
        ),
      ],
    );
  }
}
