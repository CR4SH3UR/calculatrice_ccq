import 'dart:math' as math;

import 'package:flutter/material.dart';

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

  /// Volume d'un seul élément, en m³ (null si champs incomplets).
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
        final double rayon = a / 200; // diamètre cm → rayon m
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

    return ToolScaffold(
      title: 'Béton avancé',
      children: [
        Text('Forme',
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
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: (f) => f == null ? null : setState(() => _forme = f),
        ),
        const SizedBox(height: 14),
        NumberField(
            controller: _a,
            label: champs[0].label,
            suffix: champs[0].suffix,
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(
            controller: _b,
            label: champs[1].label,
            suffix: champs[1].suffix,
            onChanged: (_) => setState(() {})),
        if (champs.length > 2) ...[
          const SizedBox(height: 12),
          NumberField(
              controller: _c,
              label: champs[2].label,
              suffix: champs[2].suffix,
              onChanged: (_) => setState(() {})),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NumberField(
                  controller: _qte,
                  label: 'Quantité',
                  suffix: '×',
                  onChanged: (_) => setState(() {})),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NumberField(
                  controller: _perte,
                  label: 'Perte',
                  suffix: '%',
                  onChanged: (_) => setState(() {})),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (m3 != null)
          ResultCard(
            label: 'Volume à commander',
            value: '${Fmt.number(verges!, decimals: 2)} vg³',
            color: AppColors.chantier,
            icon: Icons.foundation,
            details: [
              ResultLine('Volume net', '${Fmt.number(m3, decimals: 3)} m³'),
              ResultLine('Avec perte (${Fmt.trim(perte)} %)',
                  '${Fmt.number(m3Perte!, decimals: 3)} m³',
                  strong: true),
              ResultLine('En verges cubes', '${Fmt.number(verges, decimals: 2)} vg³',
                  strong: true),
              if (sacs != null)
                ResultLine('Sacs de prémélange', '≈ $sacs sacs'),
            ],
          )
        else
          const InfoBanner(
            text: 'Remplis les dimensions pour obtenir le volume.',
            color: AppColors.infos,
          ),
        const SizedBox(height: 14),
        NumberField(
            controller: _rendement,
            label: 'Rendement d\'un sac',
            suffix: 'L',
            hint: 'ex. 13,3 (sac de 30 kg)',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 6),
        Text(
            'Le rendement d\'un sac varie selon le produit — vérifie sur '
            'l\'emballage. Le calcul de perte est un tampon; ajuste selon ta job.',
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
class CoupleSerrageScreen extends StatefulWidget {
  const CoupleSerrageScreen({super.key});

  @override
  State<CoupleSerrageScreen> createState() => _CoupleSerrageScreenState();
}

class _CoupleSerrageScreenState extends State<CoupleSerrageScreen> {
  // Valeur d'une unité en N·m.
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
      title: 'Couple de serrage',
      children: [
        const InfoBanner(
          text:
              'Convertit un couple (torque) entre les unités courantes. '
              'lb·pi = livre-pied, lb·po = livre-pouce, kgf·m = kilogramme-force '
              'mètre.',
          color: AppColors.infos,
        ),
        const SizedBox(height: 14),
        NumberField(
            controller: _val,
            label: 'Valeur',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        Text('Unité de départ',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75))),
        const SizedBox(height: 8),
        ChoiceSegments(
          options: _versNm.keys.toList(),
          selected: _unite,
          onChanged: (u) => setState(() => _unite = u),
        ),
        const SizedBox(height: 16),
        if (nm != null)
          ResultCard(
            label: 'Équivalences',
            value: '${Fmt.trim(nm, maxDecimals: 2)} N·m',
            color: AppColors.charpente,
            icon: Icons.settings,
            details: _versNm.keys
                .where((u) => u != _unite)
                .map((u) => ResultLine(
                    u, Fmt.trim(nm / _versNm[u]!, maxDecimals: 3),
                    strong: u == 'N·m'))
                .toList(),
          )
        else
          const InfoBanner(
            text: 'Entre une valeur à convertir.',
            color: AppColors.infos,
          ),
        const SizedBox(height: 14),
        const InfoBanner(
          text:
              'Pour la valeur de serrage exacte d\'un boulon, réfère-toi aux '
              'spécifications du fabricant ou de l\'ingénieur.',
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
      title: 'Rappel rétroactif',
      children: [
        const InfoBanner(
          text:
              'Quand un nouveau taux est signé rétroactivement, tu as droit à '
              'la différence sur les heures déjà travaillées. Entre tes heures '
              'de la période visée et les deux taux.',
          color: AppColors.infos,
        ),
        const SizedBox(height: 14),
        NumberField(
            controller: _heures,
            label: 'Heures dans la période',
            suffix: 'h',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NumberField(
                  controller: _ancien,
                  label: 'Ancien taux',
                  suffix: '\$/h',
                  onChanged: (_) => setState(() {})),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NumberField(
                  controller: _nouveau,
                  label: 'Nouveau taux',
                  suffix: '\$/h',
                  onChanged: (_) => setState(() {})),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Ajouter les congés (13 %)',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
          subtitle: const Text('Indemnité de vacances et congés sur le rappel',
              style: TextStyle(fontSize: 12)),
          value: _avecConges,
          onChanged: (v) => setState(() => _avecConges = v),
        ),
        const SizedBox(height: 10),
        if (total != null && ecart != null)
          ResultCard(
            label: 'Rappel à recevoir',
            value: Fmt.money(total),
            color: ecart >= 0 ? AppColors.paie : AppColors.danger,
            icon: Icons.history,
            details: [
              ResultLine('Écart de taux', '${Fmt.money(ecart)}/h'),
              ResultLine('Rappel brut', Fmt.money(brut!), strong: true),
              if (_avecConges)
                ResultLine('Congés (13 %)', Fmt.money(conges!)),
              ResultLine('Total', Fmt.money(total), strong: true),
            ],
          )
        else
          const InfoBanner(
            text: 'Remplis les heures et les deux taux.',
            color: AppColors.infos,
          ),
        const SizedBox(height: 14),
        const InfoBanner(
          text:
              'Montant brut, avant impôts et retenues. Les modalités exactes du '
              'rétroactif (période, taux) sont fixées par la convention.',
        ),
      ],
    );
  }
}
