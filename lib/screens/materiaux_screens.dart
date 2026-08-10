import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

const double _m2PerFt2 = 0.09290304;
const Color _c = AppColors.materiaux;

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
    final gallons = (litres / 3.78).ceil(); // gallon US 3,78 L

    return ToolScaffold(
      title: 'Peinture',
      children: [
        const InfoBanner(
          text:
              'Estime les litres de peinture selon la surface, le nombre de '
              'couches et le rendement (souvent 8 à 12 m²/L).',
          icon: Icons.format_paint,
          color: _c,
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Text('Surface en : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: const ['m²', 'pi²'],
              selected: _m2 ? 'm²' : 'pi²',
              onChanged: (v) => setState(() => _m2 = v == 'm²'),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        NumberField(
            controller: _surfCtrl,
            label: 'Surface à peindre',
            suffix: _m2 ? 'm²' : 'pi²',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: NumberField(
                  controller: _couchesCtrl,
                  label: 'Couches',
                  onChanged: (_) => setState(() {}))),
          const SizedBox(width: 10),
          Expanded(
              child: NumberField(
                  controller: _rendCtrl,
                  label: 'Rendement',
                  suffix: 'm²/L',
                  onChanged: (_) => setState(() {}))),
        ]),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Peinture nécessaire',
          value: '${Fmt.number(litres, decimals: 1)} L',
          color: _c,
          icon: Icons.format_paint,
          details: [
            ResultLine('Surface × couches',
                '${Fmt.number(surfM2 * couches, decimals: 1)} m²'),
            ResultLine('Litres', '${Fmt.number(litres, decimals: 2)} L',
                strong: true),
            ResultLine('Contenants de 3,78 L (gallon)', '$gallons'),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  BRIQUES / BLOCS
// ─────────────────────────────────────────────────────────────────────────
class BriquesScreen extends StatefulWidget {
  const BriquesScreen({super.key});
  @override
  State<BriquesScreen> createState() => _BriquesScreenState();
}

class _BriquesScreenState extends State<BriquesScreen> {
  // Unités par m² (joint inclus, approximatif).
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

    return ToolScaffold(
      title: 'Briques & blocs',
      children: [
        const InfoBanner(
          text:
              'Estimation du nombre d\'unités selon la surface. Les quantités '
              'par m² incluent le joint et sont approximatives — confirme '
              'selon le format exact.',
          icon: Icons.grid_view,
          color: _c,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _type,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Type'),
          items: _parM2.keys
              .map((k) => DropdownMenuItem(
                  value: k, child: Text('$k  (${Fmt.trim(_parM2[k]!)}/m²)')))
              .toList(),
          onChanged: (v) => setState(() => _type = v ?? _type),
        ),
        const SizedBox(height: 12),
        Row(children: [
          const Text('Surface en : '),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceSegments(
              options: const ['m²', 'pi²'],
              selected: _m2 ? 'm²' : 'pi²',
              onChanged: (v) => setState(() => _m2 = v == 'm²'),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        NumberField(
            controller: _surfCtrl,
            label: 'Surface du mur',
            suffix: _m2 ? 'm²' : 'pi²',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(
            controller: _perteCtrl,
            label: 'Perte / bris',
            suffix: '%',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Unités nécessaires',
          value: '$nb',
          color: _c,
          icon: Icons.grid_view,
          details: [
            ResultLine('Surface', '${Fmt.number(surfM2, decimals: 2)} m²'),
            ResultLine('Densité', '${Fmt.trim(parM2)} / m²'),
            ResultLine('Avec perte (${Fmt.trim(perte)} %)', '$nb', strong: true),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  ISOLATION (valeur R)
// ─────────────────────────────────────────────────────────────────────────
class IsolationScreen extends StatefulWidget {
  const IsolationScreen({super.key});
  @override
  State<IsolationScreen> createState() => _IsolationScreenState();
}

class _IsolationScreenState extends State<IsolationScreen> {
  // Valeur R par pouce (approximative).
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

    return ToolScaffold(
      title: 'Isolation (valeur R)',
      children: [
        const InfoBanner(
          text:
              'Valeur R selon l\'épaisseur et le matériau, ou l\'épaisseur '
              'requise pour un R visé. Valeurs R/pouce approximatives.',
          icon: Icons.ac_unit,
          color: _c,
        ),
        const SizedBox(height: 16),
        ChoiceSegments(
          options: const ['Épaisseur → R', 'R visé → épaisseur'],
          selected: _mode,
          onChanged: (v) => setState(() => _mode = v),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _mat,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Matériau'),
          items: _rParPouce.keys
              .map((k) => DropdownMenuItem(
                  value: k, child: Text('$k  (R${Fmt.trim(_rParPouce[k]!)}/po)')))
              .toList(),
          onChanged: (v) => setState(() => _mat = v ?? _mat),
        ),
        const SizedBox(height: 12),
        if (_mode == 'Épaisseur → R') ...[
          NumberField(
              controller: _epCtrl,
              label: 'Épaisseur',
              suffix: 'po',
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 22),
          ResultCard(
            label: 'Valeur R totale',
            value: 'R-${Fmt.number(rTotal, decimals: 1)}',
            color: _c,
            icon: Icons.ac_unit,
            details: [
              ResultLine('Matériau', '$_mat (R${Fmt.trim(rpp)}/po)'),
              ResultLine('Épaisseur', '${Fmt.trim(ep)} po '
                  '(${Fmt.number(ep * 25.4, decimals: 0)} mm)'),
              ResultLine('R total', 'R-${Fmt.number(rTotal, decimals: 1)}',
                  strong: true),
            ],
          ),
        ] else ...[
          NumberField(
              controller: _rCtrl,
              label: 'Valeur R visée',
              hint: 'ex. 24',
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 22),
          ResultCard(
            label: 'Épaisseur requise',
            value: '${Fmt.number(epNec, decimals: 1)} po',
            color: _c,
            icon: Icons.straighten,
            details: [
              ResultLine('Matériau', '$_mat (R${Fmt.trim(rpp)}/po)'),
              ResultLine('R visé', 'R-${Fmt.trim(rVise)}'),
              ResultLine('Épaisseur',
                  '${Fmt.number(epNec, decimals: 2)} po '
                      '(${Fmt.number(epNec * 25.4, decimals: 0)} mm)',
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
      title: 'Coût de matériaux',
      children: [
        const InfoBanner(
          text:
              'Additionne tes matériaux (quantité × prix). Ajoute autant de '
              'lignes que nécessaire. Taxes du Québec (TPS+TVQ) ≈ 14,975 %.',
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
            label: const Text('Ajouter une ligne',
                style: TextStyle(color: _c, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        NumberField(
            controller: _taxesCtrl,
            label: 'Taxes',
            suffix: '%',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Coût total',
          value: Fmt.money(total),
          color: _c,
          icon: Icons.receipt_long,
          details: [
            ResultLine('Sous-total', Fmt.money(sousTotal)),
            ResultLine('Taxes (${Fmt.trim(parseNum(_taxesCtrl.text) ?? 0)} %)',
                Fmt.money(taxes)),
            ResultLine('Total', Fmt.money(total), strong: true),
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
              decoration: const InputDecoration(
                  labelText: 'Article', isDense: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: NumberField(
                controller: l.qte, label: 'Qté', onChanged: (_) => setState(() {})),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: NumberField(
                controller: l.prix,
                label: 'Prix',
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
