import 'dart:math' as math;

import 'package:flutter/material.dart';

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
      title: 'Pente de toit',
      children: [
        const InfoBanner(
          text:
              'Entre la montée et la course dans la même unité. La pente de '
              'toit s\'exprime en « montée / 12 » (ex. 6/12).',
          icon: Icons.roofing,
          color: AppColors.charpente,
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _monteeCtrl,
          label: 'Montée (rise)',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _courseCtrl,
          label: 'Course (run)',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Pente',
          value: '${Fmt.trim(ratio12, maxDecimals: 1)} / 12',
          color: AppColors.charpente,
          icon: Icons.change_history,
          details: [
            ResultLine('Angle', '${Fmt.number(angle, decimals: 1)}°'),
            ResultLine('Pourcentage', Fmt.percent(pct)),
            ResultLine('Longueur du chevron (par unité)',
                Fmt.trim(chevron, maxDecimals: 3),
                strong: true),
          ],
        ),
        const SizedBox(height: 12),
        const InfoBanner(
          text:
              'Le chevron est calculé pour la montée et la course entrées '
              '(√(montée² + course²)). Multiplie par la portée réelle pour '
              'la longueur totale.',
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

    final int nbCm = (cible > 0 && hauteur > 0)
        ? math.max(1, (hauteur / cible).round())
        : 0;
    final double hauteurReelle = nbCm > 0 ? hauteur / nbCm : 0;
    final int nbGirons = nbCm > 0 ? nbCm - 1 : 0;
    final double longueur = nbGirons * giron;

    final String uSmall = _metrique ? 'mm' : 'po';

    return ToolScaffold(
      title: 'Escalier',
      children: [
        Row(
          children: [
            const Text('Unités : '),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceSegments(
                options: const ['Métrique', 'Impérial'],
                selected: _metrique ? 'Métrique' : 'Impérial',
                onChanged: (v) => setState(() {
                  _metrique = v == 'Métrique';
                  _appliquerDefauts();
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        NumberField(
          controller: _hauteurCtrl,
          label: 'Hauteur totale à monter',
          suffix: uSmall,
          hint: _metrique ? 'ex. 2 750' : 'ex. 108',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _cmCibleCtrl,
          label: 'Hauteur de contremarche visée',
          suffix: uSmall,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _gironCtrl,
          label: 'Giron (profondeur de marche)',
          suffix: uSmall,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Escalier',
          value: '$nbCm contremarches',
          color: AppColors.charpente,
          icon: Icons.stairs,
          details: [
            ResultLine('Hauteur réelle / contremarche',
                '${Fmt.number(hauteurReelle, decimals: 1)} $uSmall',
                strong: true),
            ResultLine('Nombre de marches (girons)', '$nbGirons'),
            ResultLine('Longueur horizontale totale',
                '${Fmt.number(longueur, decimals: 1)} $uSmall'),
          ],
        ),
        const SizedBox(height: 12),
        const InfoBanner(
          text:
              'Repères usuels (résidentiel) : contremarche ≈ 125–200 mm, '
              'giron ≥ 255 mm. Toujours vérifier le Code du bâtiment '
              'applicable à ton projet.',
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
      title: 'Équerre 3-4-5',
      children: [
        const InfoBanner(
          text:
              'Méthode 3-4-5 pour vérifier un angle droit : mesure 3 sur un '
              'côté, 4 sur l\'autre — la diagonale doit faire 5 (ou tout '
              'multiple : 6-8-10, 9-12-15…).',
          icon: Icons.square_foot,
          color: AppColors.charpente,
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _aCtrl,
          label: 'Côté A',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _bCtrl,
          label: 'Côté B',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Diagonale (hypoténuse)',
          value: Fmt.trim(c, maxDecimals: 4),
          color: AppColors.charpente,
          icon: Icons.details,
          details: [
            ResultLine('Côté A', Fmt.trim(a)),
            ResultLine('Côté B', Fmt.trim(b)),
            ResultLine('√(A² + B²)', Fmt.trim(c, maxDecimals: 4),
                strong: true),
          ],
        ),
        const SizedBox(height: 12),
        const InfoBanner(
          text:
              'Pour équarrir une pièce ou un coffrage : mesure les deux '
              'diagonales. Si elles sont égales, c\'est d\'équerre.',
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

  // Montants
  final _murCtrl = TextEditingController();
  bool _murMetres = false; // false = pieds
  int _espacement = 16; // pouces

  // Feuilles
  final _surfaceCtrl = TextEditingController();
  bool _surfM2 = false; // false = pi²
  final _perteCtrl = TextEditingController(text: '10');

  static const double ft2PerSheet = 32; // 4 pi × 8 pi
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
    return ToolScaffold(
      title: 'Matériaux',
      children: [
        ChoiceSegments(
          options: const ['Montants', 'Feuilles 4×8'],
          selected: _type,
          onChanged: (v) => setState(() => _type = v),
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
    final int nb =
        murPo > 0 ? (murPo / _espacement).ceil() + 1 : 0;

    return [
      Row(
        children: [
          const Text('Longueur en : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: const ['pi', 'm'],
              selected: _murMetres ? 'm' : 'pi',
              onChanged: (v) => setState(() => _murMetres = v == 'm'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      NumberField(
        controller: _murCtrl,
        label: 'Longueur du mur',
        suffix: _murMetres ? 'm' : 'pi',
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      Text('Espacement (centre à centre)',
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
        label: 'Montants nécessaires',
        value: '$nb montants',
        color: AppColors.charpente,
        icon: Icons.view_week,
        details: [
          ResultLine('Espacement', '$_espacement po c/c'),
          ResultLine('(longueur ÷ espacement) + 1', '$nb', strong: true),
        ],
      ),
      const SizedBox(height: 12),
      const InfoBanner(
        text:
            'Estimation pour un mur droit : ajoute les montants d\'extrémité, '
            'les coins, les ouvertures (linteaux, poteaux jumelés) et une '
            'marge selon le plan.',
      ),
    ];
  }

  List<Widget> _feuilles() {
    final double surf = parseNum(_surfaceCtrl.text) ?? 0;
    final double perte = parseNum(_perteCtrl.text) ?? 0;
    final double surfFt2 = _surfM2 ? surf / m2PerFt2 : surf;
    final double surfAvecPerte = surfFt2 * (1 + perte / 100);
    final int feuilles =
        surfFt2 > 0 ? (surfAvecPerte / ft2PerSheet).ceil() : 0;

    return [
      Row(
        children: [
          const Text('Surface en : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: const ['pi²', 'm²'],
              selected: _surfM2 ? 'm²' : 'pi²',
              onChanged: (v) => setState(() => _surfM2 = v == 'm²'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      NumberField(
        controller: _surfaceCtrl,
        label: 'Surface à couvrir',
        suffix: _surfM2 ? 'm²' : 'pi²',
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      NumberField(
        controller: _perteCtrl,
        label: 'Perte / coupes',
        suffix: '%',
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 22),
      ResultCard(
        label: 'Feuilles 4×8 (32 pi²)',
        value: '$feuilles feuilles',
        color: AppColors.charpente,
        icon: Icons.dashboard,
        details: [
          ResultLine('Surface', '${Fmt.number(surfFt2, decimals: 1)} pi²'),
          ResultLine('Avec perte (${Fmt.trim(perte)} %)',
              '${Fmt.number(surfAvecPerte, decimals: 1)} pi²'),
          ResultLine('Feuilles nécessaires', '$feuilles', strong: true),
        ],
      ),
      const SizedBox(height: 12),
      const InfoBanner(
        text:
            'Feuille standard de 4 pi × 8 pi = 32 pi² (gyproc, contreplaqué, '
            'OSB). Ajuste la perte selon la complexité des découpes.',
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
    final double onglet = coin / 2; // chaque pièce coupée à la moitié du coin
    final double scie = 90 - onglet; // réglage depuis la butée à 90°

    return ToolScaffold(
      title: 'Angles de coupe',
      children: [
        const InfoBanner(
          text:
              'Pour un joint d\'onglet, chaque pièce se coupe à la moitié de '
              'l\'angle du coin. Entre l\'angle mesuré du coin (90° pour un '
              'coin carré).',
          icon: Icons.details,
          color: AppColors.charpente,
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _coinCtrl,
          label: 'Angle du coin',
          suffix: '°',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Angle d\'onglet (par pièce)',
          value: '${Fmt.number(onglet, decimals: 1)}°',
          color: AppColors.charpente,
          icon: Icons.content_cut,
          details: [
            ResultLine('Angle du coin', '${Fmt.trim(coin)}°'),
            ResultLine('Onglet (coin ÷ 2)',
                '${Fmt.number(onglet, decimals: 1)}°', strong: true),
            ResultLine('Réglage scie (depuis 90°)',
                '${Fmt.number(scie, decimals: 1)}°'),
          ],
        ),
        const SizedBox(height: 12),
        const InfoBanner(
          text:
              'Selon ta scie à onglet, l\'échelle part de 0° (coupe droite) : '
              'règle alors à « réglage scie ». Coin carré 90° → onglet 45°.',
          icon: Icons.info_outline,
          color: AppColors.charpente,
        ),
      ],
    );
  }
}
