import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

// ─────────────────────────────────────────────────────────────────────────
//  CONVERTISSEUR D'UNITÉS (longueur)
// ─────────────────────────────────────────────────────────────────────────
class ConvertisseurScreen extends StatefulWidget {
  const ConvertisseurScreen({super.key});

  @override
  State<ConvertisseurScreen> createState() => _ConvertisseurScreenState();
}

class _ConvertisseurScreenState extends State<ConvertisseurScreen> {
  final _ctrl = TextEditingController(text: '1');
  String _unite = 'pi';

  static const Map<String, double> _versMm = {
    'mm': 1,
    'cm': 10,
    'm': 1000,
    'po': Fmt.mmPerInch,
    'pi': Fmt.mmPerInch * 12,
  };

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double val = parseNum(_ctrl.text) ?? 0;
    final double mm = val * (_versMm[_unite] ?? 1);

    return ToolScaffold(
      title: 'Convertisseur d\'unités',
      children: [
        NumberField(
          controller: _ctrl,
          label: 'Valeur à convertir',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        ChoiceSegments(
          options: const ['mm', 'cm', 'm', 'po', 'pi'],
          selected: _unite,
          onChanged: (v) => setState(() => _unite = v),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Équivalences',
          value: '${Fmt.trim(val)} $_unite',
          color: AppColors.chantier,
          icon: Icons.straighten,
          details: [
            ResultLine('Millimètres', '${Fmt.number(mm, decimals: 1)} mm'),
            ResultLine('Centimètres', '${Fmt.number(mm / 10, decimals: 2)} cm'),
            ResultLine('Mètres', '${Fmt.number(mm / 1000, decimals: 3)} m'),
            ResultLine('Pouces (déc.)',
                '${Fmt.number(mm / Fmt.mmPerInch, decimals: 3)} po'),
            ResultLine('Pouces (fract.)',
                Fmt.inchesToFraction(mm / Fmt.mmPerInch)),
            ResultLine('Pieds-pouces',
                Fmt.inchesToFeetInches(mm / Fmt.mmPerInch), strong: true),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  FRACTIONS DE POUCE
// ─────────────────────────────────────────────────────────────────────────
class FractionsScreen extends StatefulWidget {
  const FractionsScreen({super.key});

  @override
  State<FractionsScreen> createState() => _FractionsScreenState();
}

class _FractionsScreenState extends State<FractionsScreen> {
  // Sens « décimal → fraction »
  final _ctrl = TextEditingController();
  int _denom = 16;
  // Sens « fraction → décimal »
  final _piCtrl = TextEditingController();
  final _poCtrl = TextEditingController();
  int _seizieme = 0; // nombre de seizièmes (0 à 15)

  String _mode = 'Fraction → déc.';

  static const List<String> _seiziemes = [
    '0', '1/16', '1/8', '3/16', '1/4', '5/16', '3/8', '7/16',
    '1/2', '9/16', '5/8', '11/16', '3/4', '13/16', '7/8', '15/16'
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _piCtrl.dispose();
    _poCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Fractions de pouce',
      children: [
        ChoiceSegments(
          options: const ['Fraction → déc.', 'Décimal → fract.'],
          selected: _mode,
          onChanged: (v) => setState(() => _mode = v),
        ),
        const SizedBox(height: 16),
        if (_mode == 'Fraction → déc.')
          ..._fractionVersDecimal(context)
        else
          ..._decimalVersFraction(context),
      ],
    );
  }

  List<Widget> _fractionVersDecimal(BuildContext context) {
    final double pi = parseNum(_piCtrl.text) ?? 0;
    final double po = parseNum(_poCtrl.text) ?? 0;
    final double totalPo = pi * 12 + po + _seizieme / 16;
    final double mm = totalPo * Fmt.mmPerInch;

    return [
      const InfoBanner(
        text:
            'Compose une mesure en pieds, pouces et fraction (au 1/16) et '
            'obtiens le décimal et le métrique.',
        icon: Icons.straighten,
        color: AppColors.chantier,
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: NumberField(
              controller: _piCtrl,
              label: 'Pieds',
              suffix: 'pi',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: NumberField(
              controller: _poCtrl,
              label: 'Pouces',
              suffix: 'po',
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<int>(
        initialValue: _seizieme,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Fraction de pouce'),
        items: [
          for (int i = 0; i < _seiziemes.length; i++)
            DropdownMenuItem(value: i, child: Text(_seiziemes[i])),
        ],
        onChanged: (v) => setState(() => _seizieme = v ?? 0),
      ),
      const SizedBox(height: 22),
      ResultCard(
        label: 'Mesure décimale',
        value: '${Fmt.trim(totalPo)} po',
        color: AppColors.chantier,
        icon: Icons.architecture,
        details: [
          ResultLine('Pieds-pouces', Fmt.inchesToFeetInches(totalPo)),
          ResultLine('Millimètres', '${Fmt.number(mm, decimals: 1)} mm',
              strong: true),
          ResultLine('Centimètres', '${Fmt.number(mm / 10, decimals: 2)} cm'),
          ResultLine('Mètres', '${Fmt.number(mm / 1000, decimals: 3)} m'),
        ],
      ),
    ];
  }

  List<Widget> _decimalVersFraction(BuildContext context) {
    final double po = parseNum(_ctrl.text) ?? 0;
    final double mm = po * Fmt.mmPerInch;

    return [
      const InfoBanner(
        text:
            'Entre une mesure en pouces décimaux (ex. 3,375) et obtiens la '
            'fraction à lire sur ton galon.',
        icon: Icons.straighten,
        color: AppColors.chantier,
      ),
      const SizedBox(height: 16),
      NumberField(
        controller: _ctrl,
        label: 'Mesure',
        suffix: 'po (décimal)',
        hint: 'ex. 3,375',
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      Text('Précision de lecture',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7))),
      const SizedBox(height: 8),
      ChoiceSegments(
        options: const ['1/8', '1/16', '1/32'],
        selected: '1/$_denom',
        onChanged: (v) => setState(() => _denom = int.parse(v.split('/')[1])),
      ),
      const SizedBox(height: 22),
      ResultCard(
        label: 'Sur le galon',
        value: Fmt.inchesToFraction(po, denom: _denom),
        color: AppColors.chantier,
        icon: Icons.architecture,
        details: [
          ResultLine('Pieds-pouces', Fmt.inchesToFeetInches(po, denom: _denom)),
          ResultLine('Millimètres', '${Fmt.number(mm, decimals: 1)} mm'),
          ResultLine('Centimètres', '${Fmt.number(mm / 10, decimals: 2)} cm'),
        ],
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  SURFACE (aire)
// ─────────────────────────────────────────────────────────────────────────
class SurfaceScreen extends StatefulWidget {
  const SurfaceScreen({super.key});

  @override
  State<SurfaceScreen> createState() => _SurfaceScreenState();
}

class _SurfaceScreenState extends State<SurfaceScreen> {
  final _aCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  String _forme = 'Rectangle';
  String _unite = 'm';

  static const double m2PerFt2 = 0.09290304;

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

    double aire; // dans l'unité choisie, au carré
    switch (_forme) {
      case 'Triangle':
        aire = a * b / 2;
        break;
      case 'Cercle':
        aire = math.pi * a * a; // a = rayon
        break;
      default:
        aire = a * b;
    }

    final bool metrique = _unite == 'm';
    final double aireM2 = metrique ? aire : aire * m2PerFt2;
    final double aireFt2 = metrique ? aire / m2PerFt2 : aire;

    final String labelA = _forme == 'Cercle' ? 'Rayon' : 'Longueur / base';
    final String labelB = _forme == 'Triangle' ? 'Hauteur' : 'Largeur';

    return ToolScaffold(
      title: 'Surface',
      children: [
        ChoiceSegments(
          options: const ['Rectangle', 'Triangle', 'Cercle'],
          selected: _forme,
          onChanged: (v) => setState(() => _forme = v),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Text('Unité : '),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceSegments(
                options: const ['m', 'pi'],
                selected: _unite,
                onChanged: (v) => setState(() => _unite = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        NumberField(
          controller: _aCtrl,
          label: labelA,
          suffix: _unite,
          onChanged: (_) => setState(() {}),
        ),
        if (_forme != 'Cercle') ...[
          const SizedBox(height: 12),
          NumberField(
            controller: _bCtrl,
            label: labelB,
            suffix: _unite,
            onChanged: (_) => setState(() {}),
          ),
        ],
        const SizedBox(height: 22),
        ResultCard(
          label: 'Aire',
          value: '${Fmt.number(aireM2, decimals: 2)} m²',
          color: AppColors.chantier,
          icon: Icons.crop_square,
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

// ─────────────────────────────────────────────────────────────────────────
//  BÉTON (volume)
// ─────────────────────────────────────────────────────────────────────────
class BetonScreen extends StatefulWidget {
  const BetonScreen({super.key});

  @override
  State<BetonScreen> createState() => _BetonScreenState();
}

class _BetonScreenState extends State<BetonScreen> {
  final _lCtrl = TextEditingController();
  final _wCtrl = TextEditingController();
  final _epCtrl = TextEditingController();
  final _diamCtrl = TextEditingController();
  final _hCtrl = TextEditingController();
  final _perteCtrl = TextEditingController(text: '10');
  final _rendementCtrl = TextEditingController(text: '0.0125');

  String _forme = 'Dalle';
  bool _metrique = true;

  static const double m3PerFt3 = 0.0283168;

  @override
  void dispose() {
    for (final c in [
      _lCtrl,
      _wCtrl,
      _epCtrl,
      _diamCtrl,
      _hCtrl,
      _perteCtrl,
      _rendementCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _volumeM3() {
    if (_forme == 'Dalle') {
      final double l = parseNum(_lCtrl.text) ?? 0;
      final double w = parseNum(_wCtrl.text) ?? 0;
      final double ep = parseNum(_epCtrl.text) ?? 0;
      if (_metrique) {
        return l * w * (ep / 100); // m × m × (cm→m)
      }
      final double ft3 = l * w * (ep / 12); // pi × pi × (po→pi)
      return ft3 * m3PerFt3;
    } else {
      final double diam = parseNum(_diamCtrl.text) ?? 0;
      final double h = parseNum(_hCtrl.text) ?? 0;
      if (_metrique) {
        final double r = (diam / 100) / 2; // cm→m
        return math.pi * r * r * h;
      }
      final double rFt = (diam / 12) / 2; // po→pi
      final double ft3 = math.pi * rFt * rFt * h;
      return ft3 * m3PerFt3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double perte = parseNum(_perteCtrl.text) ?? 0;
    final double rendement = parseNum(_rendementCtrl.text) ?? 0.0125;

    final double vol = _volumeM3();
    final double volAvecPerte = vol * (1 + perte / 100);
    final double verges = volAvecPerte / Fmt.m3PerCubicYard;
    final int sacs = (rendement > 0)
        ? (volAvecPerte / rendement).ceil()
        : 0;

    final String uBig = _metrique ? 'm' : 'pi';
    final String uSmall = _metrique ? 'cm' : 'po';

    return ToolScaffold(
      title: 'Calcul de béton',
      children: [
        ChoiceSegments(
          options: const ['Dalle', 'Colonne'],
          selected: _forme,
          onChanged: (v) => setState(() => _forme = v),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Text('Unités : '),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceSegments(
                options: const ['Métrique', 'Impérial'],
                selected: _metrique ? 'Métrique' : 'Impérial',
                onChanged: (v) =>
                    setState(() => _metrique = v == 'Métrique'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_forme == 'Dalle') ...[
          NumberField(
              controller: _lCtrl,
              label: 'Longueur',
              suffix: uBig,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          NumberField(
              controller: _wCtrl,
              label: 'Largeur',
              suffix: uBig,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          NumberField(
              controller: _epCtrl,
              label: 'Épaisseur',
              suffix: uSmall,
              onChanged: (_) => setState(() {})),
        ] else ...[
          NumberField(
              controller: _diamCtrl,
              label: 'Diamètre',
              suffix: uSmall,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          NumberField(
              controller: _hCtrl,
              label: 'Hauteur',
              suffix: uBig,
              onChanged: (_) => setState(() {})),
        ],
        const SizedBox(height: 12),
        NumberField(
            controller: _perteCtrl,
            label: 'Perte / gaspillage',
            suffix: '%',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Volume de béton',
          value: '${Fmt.number(volAvecPerte, decimals: 3)} m³',
          color: AppColors.chantier,
          icon: Icons.foundation,
          details: [
            ResultLine('Volume net', '${Fmt.number(vol, decimals: 3)} m³'),
            ResultLine('Avec perte (${Fmt.trim(perte)} %)',
                '${Fmt.number(volAvecPerte, decimals: 3)} m³'),
            ResultLine('Verges cubes', '${Fmt.number(verges, decimals: 2)} vg³',
                strong: true),
            ResultLine('Sacs de 30 kg (≈)', '$sacs sacs'),
          ],
        ),
        const SizedBox(height: 14),
        NumberField(
            controller: _rendementCtrl,
            label: 'Rendement d\'un sac (m³/sac)',
            suffix: 'm³',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        const InfoBanner(
          text:
              'Le rendement d\'un sac varie selon le produit (≈ 0,0125 m³ pour '
              'un sac de 30 kg de béton prémélangé). Pour un gros volume, '
              'commande du béton livré (en verges cubes).',
          icon: Icons.local_shipping,
          color: AppColors.chantier,
        ),
      ],
    );
  }
}
