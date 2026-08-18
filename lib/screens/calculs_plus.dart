import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

// ─────────────────────────────────────────────────────────────────────────
//  BÉTON AVANCÉ — volume selon la forme (dalle, mur, colonne, semelle)
// ─────────────────────────────────────────────────────────────────────────
class _Champ {
  const _Champ(this.label, this.suffix);
  final String label;
  final String suffix;
}

const Map<String, List<_Champ>> _formesBeton = {
  'Dalle': [
    _Champ('Longueur', 'm'),
    _Champ('Largeur', 'm'),
    _Champ('Épaisseur', 'cm'),
  ],
  'Mur': [
    _Champ('Longueur', 'm'),
    _Champ('Hauteur', 'm'),
    _Champ('Épaisseur', 'cm'),
  ],
  'Colonne ronde': [
    _Champ('Diamètre', 'cm'),
    _Champ('Hauteur', 'm'),
  ],
  'Semelle': [
    _Champ('Longueur', 'm'),
    _Champ('Largeur', 'cm'),
    _Champ('Hauteur', 'cm'),
  ],
};

String _formeBetonLabel(String k) => tr(
    k,
    const {
          'Dalle': 'Slab',
          'Mur': 'Wall',
          'Colonne ronde': 'Round column',
          'Semelle': 'Footing',
        }[k] ??
        k);

String _champLabel(String k) => tr(
    k,
    const {
          'Longueur': 'Length',
          'Largeur': 'Width',
          'Épaisseur': 'Thickness',
          'Hauteur': 'Height',
          'Diamètre': 'Diameter',
        }[k] ??
        k);

class BetonAvanceScreen extends StatefulWidget {
  const BetonAvanceScreen({super.key});

  @override
  State<BetonAvanceScreen> createState() => _BetonAvanceScreenState();
}

class _BetonAvanceScreenState extends State<BetonAvanceScreen> {
  String _forme = 'Dalle';
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _c = TextEditingController();
  final _qte = TextEditingController(text: '1');
  final _perte = TextEditingController(text: '10');
  final _rendement = TextEditingController(text: '13,3');

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _c.dispose();
    _qte.dispose();
    _perte.dispose();
    _rendement.dispose();
    super.dispose();
  }

  double? _volumeUnitaire() {
    final double? a = parseNum(_a.text);
    final double? b = parseNum(_b.text);
    final double? c = parseNum(_c.text);
    switch (_forme) {
      case 'Dalle':
        if (a == null || b == null || c == null) return null;
        return a * b * (c / 100);
      case 'Mur':
        if (a == null || b == null || c == null) return null;
        return a * b * (c / 100);
      case 'Colonne ronde':
        if (a == null || b == null) return null;
        final double rayon = a / 200;
        return math.pi * rayon * rayon * b;
      case 'Semelle':
        if (a == null || b == null || c == null) return null;
        return a * (b / 100) * (c / 100);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<_Champ> champs = _formesBeton[_forme]!;
    final double? vUnit = _volumeUnitaire();
    final double qte = parseNum(_qte.text) ?? 1;
    final double perte = parseNum(_perte.text) ?? 0;
    final double rendement = parseNum(_rendement.text) ?? 0;

    double? m3, m3Perte, verges;
    int? sacs;
    if (vUnit != null) {
      m3 = vUnit * qte;
      m3Perte = m3 * (1 + perte / 100);
      verges = m3Perte / Fmt.m3PerCubicYard;
      if (rendement > 0) {
        sacs = (m3Perte * 1000 / rendement).ceil();
      }
    }
    final String vg3 = tr('vg³', 'yd³');

    return ToolScaffold(
      title: tr('Béton avancé', 'Advanced concrete'),
      children: [
        Text(tr('Forme', 'Shape'),
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _forme,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: _formesBeton.keys
              .map((f) =>
                  DropdownMenuItem(value: f, child: Text(_formeBetonLabel(f))))
              .toList(),
          onChanged: (f) => f == null ? null : setState(() => _forme = f),
        ),
        const SizedBox(height: 14),
        NumberField(
            controller: _a,
            label: _champLabel(champs[0].label),
            suffix: champs[0].suffix,
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(
            controller: _b,
            label: _champLabel(champs[1].label),
            suffix: champs[1].suffix,
            onChanged: (_) => setState(() {})),
        if (champs.length > 2) ...[
          const SizedBox(height: 12),
          NumberField(
              controller: _c,
              label: _champLabel(champs[2].label),
              suffix: champs[2].suffix,
              onChanged: (_) => setState(() {})),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NumberField(
                  controller: _qte,
                  label: tr('Quantité', 'Quantity'),
                  suffix: '×',
                  onChanged: (_) => setState(() {})),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NumberField(
                  controller: _perte,
                  label: tr('Perte', 'Waste'),
                  suffix: '%',
                  onChanged: (_) => setState(() {})),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (m3 != null)
          ResultCard(
            label: tr('Volume à commander', 'Volume to order'),
            value: '${Fmt.number(verges!, decimals: 2)} $vg3',
            color: AppColors.chantier,
            icon: Icons.foundation,
            details: [
              ResultLine(tr('Volume net', 'Net volume'),
                  '${Fmt.number(m3, decimals: 3)} m³'),
              ResultLine('${tr('Avec perte', 'With waste')} (${Fmt.trim(perte)} %)',
                  '${Fmt.number(m3Perte!, decimals: 3)} m³',
                  strong: true),
              ResultLine(tr('En verges cubes', 'In cubic yards'),
                  '${Fmt.number(verges, decimals: 2)} $vg3',
                  strong: true),
              if (sacs != null)
                ResultLine(tr('Sacs de prémélange', 'Premix bags'),
                    '≈ $sacs ${tr('sacs', 'bags')}'),
            ],
          )
        else
          InfoBanner(
            text: tr('Remplis les dimensions pour obtenir le volume.',
                'Fill in the dimensions to get the volume.'),
            color: AppColors.infos,
          ),
        const SizedBox(height: 14),
        NumberField(
            controller: _rendement,
            label: tr('Rendement d\'un sac', 'Yield per bag'),
            suffix: 'L',
            hint: tr('ex. 13,3 (sac de 30 kg)', 'e.g. 13.3 (30 kg bag)'),
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 6),
        Text(
            tr(
                'Le rendement d\'un sac varie selon le produit — vérifie sur '
                    'l\'emballage. Le calcul de perte est un tampon; ajuste '
                    'selon ta job.',
                'Bag yield varies by product — check the package. The waste '
                    'figure is a buffer; adjust for your job.'),
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  COUPLE DE SERRAGE — convertisseur d'unités
// ─────────────────────────────────────────────────────────────────────────
String _torqueLabel(String k) =>
    tr(k, const {'lb·pi': 'lb·ft', 'lb·po': 'lb·in'}[k] ?? k);

class CoupleSerrageScreen extends StatefulWidget {
  const CoupleSerrageScreen({super.key});

  @override
  State<CoupleSerrageScreen> createState() => _CoupleSerrageScreenState();
}

class _CoupleSerrageScreenState extends State<CoupleSerrageScreen> {
  static const Map<String, double> _versNm = {
    'N·m': 1,
    'lb·pi': 1.35581795,
    'lb·po': 0.112984829,
    'kgf·m': 9.80665,
  };

  final _val = TextEditingController();
  String _unite = 'lb·pi';

  @override
  void dispose() {
    _val.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double? v = parseNum(_val.text);
    final double? nm = v == null ? null : v * _versNm[_unite]!;

    return ToolScaffold(
      title: tr('Couple de serrage', 'Torque'),
      children: [
        InfoBanner(
          text: tr(
              'Convertit un couple (torque) entre les unités courantes. '
                  'lb·pi = livre-pied, lb·po = livre-pouce, kgf·m = '
                  'kilogramme-force mètre.',
              'Converts a torque between common units. lb·ft = pound-foot, '
                  'lb·in = pound-inch, kgf·m = kilogram-force metre.'),
          color: AppColors.infos,
        ),
        const SizedBox(height: 14),
        NumberField(
            controller: _val,
            label: tr('Valeur', 'Value'),
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        Text(tr('Unité de départ', 'Starting unit'),
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75))),
        const SizedBox(height: 8),
        ChoiceSegments(
          options: _versNm.keys.map(_torqueLabel).toList(),
          selected: _torqueLabel(_unite),
          onChanged: (u) => setState(
              () => _unite = _versNm.keys.firstWhere((k) => _torqueLabel(k) == u)),
        ),
        const SizedBox(height: 16),
        if (nm != null)
          ResultCard(
            label: tr('Équivalences', 'Equivalents'),
            value: '${Fmt.trim(nm, maxDecimals: 2)} N·m',
            color: AppColors.charpente,
            icon: Icons.settings,
            details: _versNm.keys
                .where((u) => u != _unite)
                .map((u) => ResultLine(
                    _torqueLabel(u), Fmt.trim(nm / _versNm[u]!, maxDecimals: 3),
                    strong: u == 'N·m'))
                .toList(),
          )
        else
          InfoBanner(
            text: tr('Entre une valeur à convertir.', 'Enter a value to convert.'),
            color: AppColors.infos,
          ),
        const SizedBox(height: 14),
        InfoBanner(
          text: tr(
              'Pour la valeur de serrage exacte d\'un boulon, réfère-toi aux '
                  'spécifications du fabricant ou de l\'ingénieur.',
              'For a bolt\'s exact torque value, refer to the manufacturer\'s or '
                  'engineer\'s specifications.'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  RAPPEL RÉTROACTIF — paie de rappel quand un nouveau taux est signé
// ─────────────────────────────────────────────────────────────────────────
class RappelRetroScreen extends StatefulWidget {
  const RappelRetroScreen({super.key});

  @override
  State<RappelRetroScreen> createState() => _RappelRetroScreenState();
}

class _RappelRetroScreenState extends State<RappelRetroScreen> {
  final _heures = TextEditingController();
  final _ancien = TextEditingController();
  final _nouveau = TextEditingController();
  bool _avecConges = true;

  static const double _pctConges = 13.0;

  @override
  void dispose() {
    _heures.dispose();
    _ancien.dispose();
    _nouveau.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double? h = parseNum(_heures.text);
    final double? ancien = parseNum(_ancien.text);
    final double? nouveau = parseNum(_nouveau.text);

    double? ecart, brut, conges, total;
    if (h != null && ancien != null && nouveau != null) {
      ecart = nouveau - ancien;
      brut = h * ecart;
      conges = _avecConges ? brut * _pctConges / 100 : 0;
      total = brut + conges;
    }

    return ToolScaffold(
      title: tr('Rappel rétroactif', 'Retro pay'),
      children: [
        InfoBanner(
          text: tr(
              'Quand un nouveau taux est signé rétroactivement, tu as droit à '
                  'la différence sur les heures déjà travaillées. Entre tes '
                  'heures de la période visée et les deux taux.',
              'When a new rate is signed retroactively, you\'re owed the '
                  'difference on the hours already worked. Enter your hours for '
                  'the period and both rates.'),
          color: AppColors.infos,
        ),
        const SizedBox(height: 14),
        NumberField(
            controller: _heures,
            label: tr('Heures dans la période', 'Hours in the period'),
            suffix: 'h',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NumberField(
                  controller: _ancien,
                  label: tr('Ancien taux', 'Old rate'),
                  suffix: '\$/h',
                  onChanged: (_) => setState(() {})),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NumberField(
                  controller: _nouveau,
                  label: tr('Nouveau taux', 'New rate'),
                  suffix: '\$/h',
                  onChanged: (_) => setState(() {})),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(tr('Ajouter les congés (13 %)', 'Add holiday pay (13%)'),
              style: const TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w600)),
          subtitle: Text(
              tr('Indemnité de vacances et congés sur le rappel',
                  'Vacation/holiday allowance on the back pay'),
              style: const TextStyle(fontSize: 12)),
          value: _avecConges,
          onChanged: (v) => setState(() => _avecConges = v),
        ),
        const SizedBox(height: 10),
        if (total != null && ecart != null)
          ResultCard(
            label: tr('Rappel à recevoir', 'Back pay to receive'),
            value: Fmt.money(total),
            color: ecart >= 0 ? AppColors.paie : AppColors.danger,
            icon: Icons.history,
            details: [
              ResultLine(tr('Écart de taux', 'Rate difference'),
                  '${Fmt.money(ecart)}/h'),
              ResultLine(tr('Rappel brut', 'Gross back pay'), Fmt.money(brut!),
                  strong: true),
              if (_avecConges)
                ResultLine(tr('Congés (13 %)', 'Holiday (13%)'),
                    Fmt.money(conges!)),
              ResultLine(tr('Total', 'Total'), Fmt.money(total), strong: true),
            ],
          )
        else
          InfoBanner(
            text: tr('Remplis les heures et les deux taux.',
                'Fill in the hours and both rates.'),
            color: AppColors.infos,
          ),
        const SizedBox(height: 14),
        InfoBanner(
          text: tr(
              'Montant brut, avant impôts et retenues. Les modalités exactes du '
                  'rétroactif (période, taux) sont fixées par la convention.',
              'Gross amount, before taxes and deductions. The exact retro terms '
                  '(period, rate) are set by the agreement.'),
        ),
      ],
    );
  }
}
