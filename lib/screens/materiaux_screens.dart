import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

const double _m2PerFt2 = 0.09290304;
const Color _c = AppColors.materiaux;

String _pi2() => tr('pi²', 'ft²');

// ─────────────────────────────────────────────────────────────────────────
//  PEINTURE
// ─────────────────────────────────────────────────────────────────────────
class PeintureScreen extends StatefulWidget {
  const PeintureScreen({super.key});
  @override
  State<PeintureScreen> createState() => _PeintureScreenState();
}

class _PeintureScreenState extends State<PeintureScreen> {
  final _surfCtrl = TextEditingController();
  final _couchesCtrl = TextEditingController(text: '2');
  final _rendCtrl = TextEditingController(text: '10');
  bool _m2 = true;

  @override
  void dispose() {
    _surfCtrl.dispose();
    _couchesCtrl.dispose();
    _rendCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surf = parseNum(_surfCtrl.text) ?? 0;
    final couches = parseNum(_couchesCtrl.text) ?? 1;
    final rend = parseNum(_rendCtrl.text) ?? 10;
    final surfM2 = _m2 ? surf : surf * _m2PerFt2;
    final litres = rend > 0 ? surfM2 * couches / rend : 0.0;
    final gallons = (litres / 3.78).ceil();
    final String pi2 = _pi2();

    return ToolScaffold(
      title: tr('Peinture', 'Paint'),
      children: [
        InfoBanner(
          text: tr(
              'Estime les litres de peinture selon la surface, le nombre de '
                  'couches et le rendement (souvent 8 à 12 m²/L).',
              'Estimate paint litres from area, number of coats and coverage '
                  '(often 8 to 12 m²/L).'),
          icon: Icons.format_paint,
          color: _c,
        ),
        const SizedBox(height: 16),
        Row(children: [
          Text('${tr('Surface en', 'Area in')} : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: ['m²', pi2],
              selected: _m2 ? 'm²' : pi2,
              onChanged: (v) => setState(() => _m2 = v == 'm²'),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        NumberField(
            controller: _surfCtrl,
            label: tr('Surface à peindre', 'Area to paint'),
            suffix: _m2 ? 'm²' : pi2,
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: NumberField(
                  controller: _couchesCtrl,
                  label: tr('Couches', 'Coats'),
                  onChanged: (_) => setState(() {}))),
          const SizedBox(width: 10),
          Expanded(
              child: NumberField(
                  controller: _rendCtrl,
                  label: tr('Rendement', 'Coverage'),
                  suffix: 'm²/L',
                  onChanged: (_) => setState(() {}))),
        ]),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Peinture nécessaire', 'Paint needed'),
          value: '${Fmt.number(litres, decimals: 1)} L',
          color: _c,
          icon: Icons.format_paint,
          details: [
            ResultLine(tr('Surface × couches', 'Area × coats'),
                '${Fmt.number(surfM2 * couches, decimals: 1)} m²'),
            ResultLine(tr('Litres', 'Litres'),
                '${Fmt.number(litres, decimals: 2)} L',
                strong: true),
            ResultLine(tr('Contenants de 3,78 L (gallon)',
                'Cans of 3.78 L (gallon)'), '$gallons'),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  BRIQUES / BLOCS
// ─────────────────────────────────────────────────────────────────────────
String _briqueLabel(String k) => tr(
    k,
    const {
          'Brique modulaire': 'Modular brick',
          'Bloc de béton 8"': '8" concrete block',
          'Bloc de béton 12"': '12" concrete block',
          'Pierre de parement': 'Veneer stone',
        }[k] ??
        k);

class BriquesScreen extends StatefulWidget {
  const BriquesScreen({super.key});
  @override
  State<BriquesScreen> createState() => _BriquesScreenState();
}

class _BriquesScreenState extends State<BriquesScreen> {
  static const Map<String, double> _parM2 = {
    'Brique modulaire': 48.5,
    'Bloc de béton 8"': 12.5,
    'Bloc de béton 12"': 12.5,
    'Pierre de parement': 20.0,
  };
  final _surfCtrl = TextEditingController();
  final _perteCtrl = TextEditingController(text: '10');
  bool _m2 = true;
  String _type = 'Brique modulaire';

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
    final surfM2 = _m2 ? surf : surf * _m2PerFt2;
    final parM2 = _parM2[_type]!;
    final nb = (surfM2 * parM2 * (1 + perte / 100)).ceil();
    final String pi2 = _pi2();

    return ToolScaffold(
      title: tr('Briques & blocs', 'Bricks & blocks'),
      children: [
        InfoBanner(
          text: tr(
              'Estimation du nombre d\'unités selon la surface. Les quantités '
                  'par m² incluent le joint et sont approximatives — confirme '
                  'selon le format exact.',
              'Estimated number of units from the area. The per-m² quantities '
                  'include the joint and are approximate — confirm with the '
                  'exact format.'),
          icon: Icons.grid_view,
          color: _c,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _type,
          isExpanded: true,
          decoration: InputDecoration(labelText: tr('Type', 'Type')),
          items: _parM2.keys
              .map((k) => DropdownMenuItem(
                  value: k,
                  child: Text('${_briqueLabel(k)}  (${Fmt.trim(_parM2[k]!)}/m²)')))
              .toList(),
          onChanged: (v) => setState(() => _type = v ?? _type),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Text('${tr('Surface en', 'Area in')} : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: ['m²', pi2],
              selected: _m2 ? 'm²' : pi2,
              onChanged: (v) => setState(() => _m2 = v == 'm²'),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        NumberField(
            controller: _surfCtrl,
            label: tr('Surface du mur', 'Wall area'),
            suffix: _m2 ? 'm²' : pi2,
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(
            controller: _perteCtrl,
            label: tr('Perte / bris', 'Waste / breakage'),
            suffix: '%',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Unités nécessaires', 'Units needed'),
          value: '$nb',
          color: _c,
          icon: Icons.grid_view,
          details: [
            ResultLine(tr('Surface', 'Area'),
                '${Fmt.number(surfM2, decimals: 2)} m²'),
            ResultLine(tr('Densité', 'Density'), '${Fmt.trim(parM2)} / m²'),
            ResultLine('${tr('Avec perte', 'With waste')} (${Fmt.trim(perte)} %)',
                '$nb',
                strong: true),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  ISOLATION (valeur R)
// ─────────────────────────────────────────────────────────────────────────
String _matLabel(String k) => tr(
    k,
    const {
          'Fibre de verre (matelas)': 'Fiberglass (batt)',
          'Laine minérale': 'Mineral wool',
          'Cellulose soufflée': 'Blown cellulose',
          'Polystyrène EPS': 'EPS polystyrene',
          'Polystyrène XPS': 'XPS polystyrene',
          'Uréthane giclé': 'Spray urethane',
        }[k] ??
        k);

class IsolationScreen extends StatefulWidget {
  const IsolationScreen({super.key});
  @override
  State<IsolationScreen> createState() => _IsolationScreenState();
}

class _IsolationScreenState extends State<IsolationScreen> {
  static const Map<String, double> _rParPouce = {
    'Fibre de verre (matelas)': 3.2,
    'Laine minérale': 3.7,
    'Cellulose soufflée': 3.5,
    'Polystyrène EPS': 3.8,
    'Polystyrène XPS': 5.0,
    'Uréthane giclé': 6.0,
  };
  String _mode = 'Épaisseur → R';
  String _mat = 'Laine minérale';
  final _epCtrl = TextEditingController();
  final _rCtrl = TextEditingController();

  @override
  void dispose() {
    _epCtrl.dispose();
    _rCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rpp = _rParPouce[_mat]!;
    final ep = parseNum(_epCtrl.text) ?? 0;
    final rVise = parseNum(_rCtrl.text) ?? 0;
    final rTotal = ep * rpp;
    final epNec = rpp > 0 ? rVise / rpp : 0.0;
    final String po = tr('po', 'in');

    final Map<String, String> modes = {
      'Épaisseur → R': tr('Épaisseur → R', 'Thickness → R'),
      'R visé → épaisseur': tr('R visé → épaisseur', 'Target R → thickness'),
    };

    return ToolScaffold(
      title: tr('Isolation (valeur R)', 'Insulation (R-value)'),
      children: [
        InfoBanner(
          text: tr(
              'Valeur R selon l\'épaisseur et le matériau, ou l\'épaisseur '
                  'requise pour un R visé. Valeurs R/pouce approximatives.',
              'R-value from thickness and material, or the thickness required '
                  'for a target R. Approximate R/inch values.'),
          icon: Icons.ac_unit,
          color: _c,
        ),
        const SizedBox(height: 16),
        ChoiceSegments(
          options: modes.values.toList(),
          selected: modes[_mode]!,
          onChanged: (v) => setState(
              () => _mode = modes.keys.firstWhere((k) => modes[k] == v)),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _mat,
          isExpanded: true,
          decoration: InputDecoration(labelText: tr('Matériau', 'Material')),
          items: _rParPouce.keys
              .map((k) => DropdownMenuItem(
                  value: k,
                  child: Text('${_matLabel(k)}  (R${Fmt.trim(_rParPouce[k]!)}/$po)')))
              .toList(),
          onChanged: (v) => setState(() => _mat = v ?? _mat),
        ),
        const SizedBox(height: 12),
        if (_mode == 'Épaisseur → R') ...[
          NumberField(
              controller: _epCtrl,
              label: tr('Épaisseur', 'Thickness'),
              suffix: po,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 22),
          ResultCard(
            label: tr('Valeur R totale', 'Total R-value'),
            value: 'R-${Fmt.number(rTotal, decimals: 1)}',
            color: _c,
            icon: Icons.ac_unit,
            details: [
              ResultLine(tr('Matériau', 'Material'),
                  '${_matLabel(_mat)} (R${Fmt.trim(rpp)}/$po)'),
              ResultLine(tr('Épaisseur', 'Thickness'),
                  '${Fmt.trim(ep)} $po (${Fmt.number(ep * 25.4, decimals: 0)} mm)'),
              ResultLine(tr('R total', 'Total R'),
                  'R-${Fmt.number(rTotal, decimals: 1)}',
                  strong: true),
            ],
          ),
        ] else ...[
          NumberField(
              controller: _rCtrl,
              label: tr('Valeur R visée', 'Target R-value'),
              hint: tr('ex. 24', 'e.g. 24'),
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 22),
          ResultCard(
            label: tr('Épaisseur requise', 'Required thickness'),
            value: '${Fmt.number(epNec, decimals: 1)} $po',
            color: _c,
            icon: Icons.straighten,
            details: [
              ResultLine(tr('Matériau', 'Material'),
                  '${_matLabel(_mat)} (R${Fmt.trim(rpp)}/$po)'),
              ResultLine(tr('R visé', 'Target R'), 'R-${Fmt.trim(rVise)}'),
              ResultLine(tr('Épaisseur', 'Thickness'),
                  '${Fmt.number(epNec, decimals: 2)} $po (${Fmt.number(epNec * 25.4, decimals: 0)} mm)',
                  strong: true),
            ],
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  COÛT DE MATÉRIAUX
// ─────────────────────────────────────────────────────────────────────────
class CoutScreen extends StatefulWidget {
  const CoutScreen({super.key});
  @override
  State<CoutScreen> createState() => _CoutScreenState();
}

class _LigneCout {
  final desc = TextEditingController();
  final qte = TextEditingController();
  final prix = TextEditingController();
  double get total => (parseNum(qte.text) ?? 0) * (parseNum(prix.text) ?? 0);
  void dispose() {
    desc.dispose();
    qte.dispose();
    prix.dispose();
  }
}

class _CoutScreenState extends State<CoutScreen> {
  final List<_LigneCout> _lignes = [_LigneCout(), _LigneCout()];
  final _taxesCtrl = TextEditingController(text: '14.975');

  @override
  void dispose() {
    for (final l in _lignes) {
      l.dispose();
    }
    _taxesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sousTotal = _lignes.fold(0.0, (s, l) => s + l.total);
    final taxes = sousTotal * (parseNum(_taxesCtrl.text) ?? 0) / 100;
    final total = sousTotal + taxes;

    return ToolScaffold(
      title: tr('Coût de matériaux', 'Material cost'),
      children: [
        InfoBanner(
          text: tr(
              'Additionne tes matériaux (quantité × prix). Ajoute autant de '
                  'lignes que nécessaire. Taxes du Québec (TPS+TVQ) ≈ 14,975 %.',
              'Add up your materials (quantity × price). Add as many lines as '
                  'needed. Quebec taxes (GST+QST) ≈ 14.975%.'),
          icon: Icons.receipt_long,
          color: _c,
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < _lignes.length; i++) _ligneWidget(i),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _lignes.add(_LigneCout())),
            icon: const Icon(Icons.add, color: _c),
            label: Text(tr('Ajouter une ligne', 'Add a line'),
                style: const TextStyle(color: _c, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        NumberField(
            controller: _taxesCtrl,
            label: tr('Taxes', 'Taxes'),
            suffix: '%',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Coût total', 'Total cost'),
          value: Fmt.money(total),
          color: _c,
          icon: Icons.receipt_long,
          details: [
            ResultLine(tr('Sous-total', 'Subtotal'), Fmt.money(sousTotal)),
            ResultLine(
                '${tr('Taxes', 'Taxes')} (${Fmt.trim(parseNum(_taxesCtrl.text) ?? 0)} %)',
                Fmt.money(taxes)),
            ResultLine(tr('Total', 'Total'), Fmt.money(total), strong: true),
          ],
        ),
      ],
    );
  }

  Widget _ligneWidget(int i) {
    final l = _lignes[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: l.desc,
              decoration: InputDecoration(
                  labelText: tr('Article', 'Item'), isDense: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: NumberField(
                controller: l.qte,
                label: tr('Qté', 'Qty'),
                onChanged: (_) => setState(() {})),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: NumberField(
                controller: l.prix,
                label: tr('Prix', 'Price'),
                suffix: '\$',
                onChanged: (_) => setState(() {})),
          ),
          if (_lignes.length > 1)
            IconButton(
              icon: Icon(Icons.close,
                  size: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4)),
              onPressed: () => setState(() {
                _lignes.removeAt(i).dispose();
              }),
            ),
        ],
      ),
    );
  }
}
