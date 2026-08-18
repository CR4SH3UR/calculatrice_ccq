import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

/// Libellé d'un code d'unité : « po » → in, « pi » → ft en anglais.
String _uLabel(String code) =>
    tr(code, code == 'po' ? 'in' : (code == 'pi' ? 'ft' : code));

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
      title: tr('Convertisseur d\'unités', 'Unit converter'),
      children: [
        NumberField(
          controller: _ctrl,
          label: tr('Valeur à convertir', 'Value to convert'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        ChoiceSegments(
          options: _versMm.keys.map(_uLabel).toList(),
          selected: _uLabel(_unite),
          onChanged: (v) => setState(
              () => _unite = _versMm.keys.firstWhere((u) => _uLabel(u) == v)),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Équivalences', 'Equivalents'),
          value: '${Fmt.trim(val)} ${_uLabel(_unite)}',
          color: AppColors.chantier,
          icon: Icons.straighten,
          details: [
            ResultLine(tr('Millimètres', 'Millimeters'),
                '${Fmt.number(mm, decimals: 1)} mm'),
            ResultLine(tr('Centimètres', 'Centimeters'),
                '${Fmt.number(mm / 10, decimals: 2)} cm'),
            ResultLine(
                tr('Mètres', 'Meters'), '${Fmt.number(mm / 1000, decimals: 3)} m'),
            ResultLine(tr('Pouces (déc.)', 'Inches (dec.)'),
                '${Fmt.number(mm / Fmt.mmPerInch, decimals: 3)} ${tr('po', 'in')}'),
            ResultLine(tr('Pouces (fract.)', 'Inches (frac.)'),
                Fmt.inchesToFraction(mm / Fmt.mmPerInch)),
            ResultLine(tr('Pieds-pouces', 'Feet-inches'),
                Fmt.inchesToFeetInches(mm / Fmt.mmPerInch),
                strong: true),
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
  final _ctrl = TextEditingController();
  int _denom = 16;
  final _piCtrl = TextEditingController();
  final _poCtrl = TextEditingController();
  int _seizieme = 0;

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
    final Map<String, String> modes = {
      'Fraction → déc.': tr('Fraction → déc.', 'Fraction → dec.'),
      'Décimal → fract.': tr('Décimal → fract.', 'Decimal → frac.'),
    };
    return ToolScaffold(
      title: tr('Fractions de pouce', 'Inch fractions'),
      children: [
        ChoiceSegments(
          options: modes.values.toList(),
          selected: modes[_mode]!,
          onChanged: (v) => setState(
              () => _mode = modes.keys.firstWhere((k) => modes[k] == v)),
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
      InfoBanner(
        text: tr(
            'Compose une mesure en pieds, pouces et fraction (au 1/16) et '
                'obtiens le décimal et le métrique.',
            'Build a measure in feet, inches and fraction (to 1/16) and get the '
                'decimal and metric values.'),
        icon: Icons.straighten,
        color: AppColors.chantier,
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: NumberField(
              controller: _piCtrl,
              label: tr('Pieds', 'Feet'),
              suffix: tr('pi', 'ft'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: NumberField(
              controller: _poCtrl,
              label: tr('Pouces', 'Inches'),
              suffix: tr('po', 'in'),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<int>(
        initialValue: _seizieme,
        isExpanded: true,
        decoration:
            InputDecoration(labelText: tr('Fraction de pouce', 'Inch fraction')),
        items: [
          for (int i = 0; i < _seiziemes.length; i++)
            DropdownMenuItem(value: i, child: Text(_seiziemes[i])),
        ],
        onChanged: (v) => setState(() => _seizieme = v ?? 0),
      ),
      const SizedBox(height: 22),
      ResultCard(
        label: tr('Mesure décimale', 'Decimal measure'),
        value: '${Fmt.trim(totalPo)} ${tr('po', 'in')}',
        color: AppColors.chantier,
        icon: Icons.architecture,
        details: [
          ResultLine(tr('Pieds-pouces', 'Feet-inches'),
              Fmt.inchesToFeetInches(totalPo)),
          ResultLine(tr('Millimètres', 'Millimeters'),
              '${Fmt.number(mm, decimals: 1)} mm',
              strong: true),
          ResultLine(tr('Centimètres', 'Centimeters'),
              '${Fmt.number(mm / 10, decimals: 2)} cm'),
          ResultLine(
              tr('Mètres', 'Meters'), '${Fmt.number(mm / 1000, decimals: 3)} m'),
        ],
      ),
    ];
  }

  List<Widget> _decimalVersFraction(BuildContext context) {
    final double po = parseNum(_ctrl.text) ?? 0;
    final double mm = po * Fmt.mmPerInch;

    return [
      InfoBanner(
        text: tr(
            'Entre une mesure en pouces décimaux (ex. 3,375) et obtiens la '
                'fraction à lire sur ton galon.',
            'Enter a decimal-inch measure (e.g. 3.375) and get the fraction to '
                'read on your tape.'),
        icon: Icons.straighten,
        color: AppColors.chantier,
      ),
      const SizedBox(height: 16),
      NumberField(
        controller: _ctrl,
        label: tr('Mesure', 'Measure'),
        suffix: tr('po (décimal)', 'in (decimal)'),
        hint: tr('ex. 3,375', 'e.g. 3.375'),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      Text(tr('Précision de lecture', 'Reading precision'),
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
        label: tr('Sur le galon', 'On the tape'),
        value: Fmt.inchesToFraction(po, denom: _denom),
        color: AppColors.chantier,
        icon: Icons.architecture,
        details: [
          ResultLine(tr('Pieds-pouces', 'Feet-inches'),
              Fmt.inchesToFeetInches(po, denom: _denom)),
          ResultLine(tr('Millimètres', 'Millimeters'),
              '${Fmt.number(mm, decimals: 1)} mm'),
          ResultLine(tr('Centimètres', 'Centimeters'),
              '${Fmt.number(mm / 10, decimals: 2)} cm'),
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

    double aire;
    switch (_forme) {
      case 'Triangle':
        aire = a * b / 2;
        break;
      case 'Cercle':
        aire = math.pi * a * a;
        break;
      default:
        aire = a * b;
    }

    final bool metrique = _unite == 'm';
    final double aireM2 = metrique ? aire : aire * m2PerFt2;
    final double aireFt2 = metrique ? aire / m2PerFt2 : aire;

    final String labelA =
        _forme == 'Cercle' ? tr('Rayon', 'Radius') : tr('Longueur / base', 'Length / base');
    final String labelB =
        _forme == 'Triangle' ? tr('Hauteur', 'Height') : tr('Largeur', 'Width');

    final Map<String, String> formes = {
      'Rectangle': tr('Rectangle', 'Rectangle'),
      'Triangle': tr('Triangle', 'Triangle'),
      'Cercle': tr('Cercle', 'Circle'),
    };

    return ToolScaffold(
      title: tr('Surface', 'Area'),
      children: [
        ChoiceSegments(
          options: formes.values.toList(),
          selected: formes[_forme]!,
          onChanged: (v) => setState(
              () => _forme = formes.keys.firstWhere((k) => formes[k] == v)),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text('${tr('Unité', 'Unit')} : '),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceSegments(
                options: ['m', _uLabel('pi')],
                selected: _uLabel(_unite),
                onChanged: (v) =>
                    setState(() => _unite = v == 'm' ? 'm' : 'pi'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        NumberField(
          controller: _aCtrl,
          label: labelA,
          suffix: _uLabel(_unite),
          onChanged: (_) => setState(() {}),
        ),
        if (_forme != 'Cercle') ...[
          const SizedBox(height: 12),
          NumberField(
            controller: _bCtrl,
            label: labelB,
            suffix: _uLabel(_unite),
            onChanged: (_) => setState(() {}),
          ),
        ],
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Aire', 'Area'),
          value: '${Fmt.number(aireM2, decimals: 2)} m²',
          color: AppColors.chantier,
          icon: Icons.crop_square,
          details: [
            ResultLine(tr('Pieds carrés', 'Square feet'),
                '${Fmt.number(aireFt2, decimals: 2)} ${tr('pi', 'ft')}²'),
            ResultLine(tr('Mètres carrés', 'Square meters'),
                '${Fmt.number(aireM2, decimals: 2)} m²',
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
        return l * w * (ep / 100);
      }
      final double ft3 = l * w * (ep / 12);
      return ft3 * m3PerFt3;
    } else {
      final double diam = parseNum(_diamCtrl.text) ?? 0;
      final double h = parseNum(_hCtrl.text) ?? 0;
      if (_metrique) {
        final double r = (diam / 100) / 2;
        return math.pi * r * r * h;
      }
      final double rFt = (diam / 12) / 2;
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
    final int sacs = (rendement > 0) ? (volAvecPerte / rendement).ceil() : 0;

    final String uBig = _metrique ? 'm' : tr('pi', 'ft');
    final String uSmall = _metrique ? 'cm' : tr('po', 'in');

    final Map<String, String> formes = {
      'Dalle': tr('Dalle', 'Slab'),
      'Colonne': tr('Colonne', 'Column'),
    };
    final String metr = tr('Métrique', 'Metric');
    final String imp = tr('Impérial', 'Imperial');

    return ToolScaffold(
      title: tr('Calcul de béton', 'Concrete calculation'),
      children: [
        ChoiceSegments(
          options: formes.values.toList(),
          selected: formes[_forme]!,
          onChanged: (v) => setState(
              () => _forme = formes.keys.firstWhere((k) => formes[k] == v)),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text('${tr('Unités', 'Units')} : '),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceSegments(
                options: [metr, imp],
                selected: _metrique ? metr : imp,
                onChanged: (v) => setState(() => _metrique = v == metr),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_forme == 'Dalle') ...[
          NumberField(
              controller: _lCtrl,
              label: tr('Longueur', 'Length'),
              suffix: uBig,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          NumberField(
              controller: _wCtrl,
              label: tr('Largeur', 'Width'),
              suffix: uBig,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          NumberField(
              controller: _epCtrl,
              label: tr('Épaisseur', 'Thickness'),
              suffix: uSmall,
              onChanged: (_) => setState(() {})),
        ] else ...[
          NumberField(
              controller: _diamCtrl,
              label: tr('Diamètre', 'Diameter'),
              suffix: uSmall,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          NumberField(
              controller: _hCtrl,
              label: tr('Hauteur', 'Height'),
              suffix: uBig,
              onChanged: (_) => setState(() {})),
        ],
        const SizedBox(height: 12),
        NumberField(
            controller: _perteCtrl,
            label: tr('Perte / gaspillage', 'Waste'),
            suffix: '%',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Volume de béton', 'Concrete volume'),
          value: '${Fmt.number(volAvecPerte, decimals: 3)} m³',
          color: AppColors.chantier,
          icon: Icons.foundation,
          details: [
            ResultLine(tr('Volume net', 'Net volume'),
                '${Fmt.number(vol, decimals: 3)} m³'),
            ResultLine(
                '${tr('Avec perte', 'With waste')} (${Fmt.trim(perte)} %)',
                '${Fmt.number(volAvecPerte, decimals: 3)} m³'),
            ResultLine(tr('Verges cubes', 'Cubic yards'),
                '${Fmt.number(verges, decimals: 2)} ${tr('vg³', 'yd³')}',
                strong: true),
            ResultLine(tr('Sacs de 30 kg (≈)', '30 kg bags (≈)'),
                '$sacs ${tr('sacs', 'bags')}'),
          ],
        ),
        const SizedBox(height: 14),
        NumberField(
            controller: _rendementCtrl,
            label: tr('Rendement d\'un sac (m³/sac)', 'Yield per bag (m³/bag)'),
            suffix: 'm³',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        InfoBanner(
          text: tr(
              'Le rendement d\'un sac varie selon le produit (≈ 0,0125 m³ pour '
                  'un sac de 30 kg de béton prémélangé). Pour un gros volume, '
                  'commande du béton livré (en verges cubes).',
              'Bag yield varies by product (≈ 0.0125 m³ for a 30 kg bag of '
                  'premixed concrete). For a large volume, order delivered '
                  'concrete (in cubic yards).'),
          icon: Icons.local_shipping,
          color: AppColors.chantier,
        ),
      ],
    );
  }
}
