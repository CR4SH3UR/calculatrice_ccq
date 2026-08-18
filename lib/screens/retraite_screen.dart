import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/link_tile.dart';

/// Valeur future d'un solde initial + cotisations annuelles (fin d'année),
/// à un rendement annuel [rendement] (ex. 0,04) sur [annees] ans.
double projeterCompte({
  required double solde,
  required double cotisAnnuelle,
  required int annees,
  required double rendement,
}) {
  final double r = rendement;
  final double fvSolde = solde * math.pow(1 + r, annees);
  final double fvCotis = r == 0
      ? cotisAnnuelle * annees
      : cotisAnnuelle * ((math.pow(1 + r, annees) - 1) / r);
  return fvSolde + fvCotis;
}

/// Calculateur de retraite CCQ — projection du compte complémentaire
/// (cotisations déterminées). Ne calcule PAS le compte général (prestations
/// déterminées), qui est établi par la CCQ.
class RetraiteScreen extends StatefulWidget {
  const RetraiteScreen({super.key});

  @override
  State<RetraiteScreen> createState() => _RetraiteScreenState();
}

class _RetraiteScreenState extends State<RetraiteScreen> {
  final _solde = TextEditingController();
  final _heures = TextEditingController();
  final _taux = TextEditingController();
  final _annees = TextEditingController();
  final _rendement = TextEditingController(text: '4');
  String _age = '60 ans';

  // Taux de conversion illustratifs, tirés des exemples publiés par la CCQ
  // (150 000 $ → ~10 000 $/an à 55 ans; ~12 500 $/an à 60 ans).
  static const Map<String, double> _conversion = {
    '55 ans': 10000 / 150000,
    '60 ans': 12500 / 150000,
  };

  /// Libellé affiché pour une clé d'âge (la clé reste « 55 ans » / « 60 ans »).
  String _ageLabel(String cle) =>
      tr(cle, cle == '55 ans' ? '55 yrs' : '60 yrs');

  @override
  void dispose() {
    _solde.dispose();
    _heures.dispose();
    _taux.dispose();
    _annees.dispose();
    _rendement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color onSurf = Theme.of(context).colorScheme.onSurface;
    final double solde = parseNum(_solde.text) ?? 0;
    final double? heures = parseNum(_heures.text);
    final double? taux = parseNum(_taux.text);
    final double? annees = parseNum(_annees.text);
    final double rendement = (parseNum(_rendement.text) ?? 0) / 100;
    final double cotisAnnuelle =
        (heures != null && taux != null) ? heures * taux : 0;

    double? projete, renteAn, renteMois, cotisTotales;
    if (annees != null && annees > 0 && (solde > 0 || cotisAnnuelle > 0)) {
      final int n = annees.round();
      projete = projeterCompte(
          solde: solde,
          cotisAnnuelle: cotisAnnuelle,
          annees: n,
          rendement: rendement);
      cotisTotales = cotisAnnuelle * n;
      renteAn = projete * _conversion[_age]!;
      renteMois = renteAn / 12;
    }

    return ToolScaffold(
      title: tr('Calculateur de retraite', 'Retirement calculator'),
      children: [
        InfoBanner(
          text: tr(
              'Projection de ton compte complémentaire (cotisations '
                  'déterminées) — le « pot » qui fructifie. Ce n\'est pas un '
                  'calcul officiel : le compte général et les facteurs exacts '
                  'sont établis par la CCQ.',
              'Projection of your complementary account (defined contribution) '
                  '— the « pot » that grows. This is not an official calculation: '
                  'the general account and exact factors are set by the CCQ.'),
          color: AppColors.infos,
          icon: Icons.savings,
        ),
        const SizedBox(height: 16),
        SectionTitle(tr('Le régime en bref', 'The plan in brief'),
            color: AppColors.paie),
        const SizedBox(height: 8),
        ..._faits().map((f) => _FaitTile(texte: f)),
        const SizedBox(height: 16),
        SectionTitle(tr('Projeter mon compte', 'Project my account'),
            color: AppColors.paie),
        const SizedBox(height: 8),
        NumberField(
            controller: _solde,
            label: tr('Solde actuel du compte', 'Current account balance'),
            suffix: '\$',
            hint: tr('de ton relevé', 'from your statement'),
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NumberField(
                  controller: _heures,
                  label: tr('Heures / an', 'Hours / yr'),
                  suffix: 'h',
                  onChanged: (_) => setState(() {})),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NumberField(
                  controller: _taux,
                  label: tr('Cotisation', 'Contribution'),
                  suffix: '\$/h',
                  hint: tr('relevé', 'stmt'),
                  onChanged: (_) => setState(() {})),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
            tr(
                'Cotisation totale au régime de retraite par heure (employé + '
                    'employeur) — voir ton bulletin ou ta convention.',
                'Total pension contribution per hour (employee + employer) — '
                    'see your statement or agreement.'),
            style: TextStyle(
                fontSize: 12, color: onSurf.withValues(alpha: 0.55))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NumberField(
                  controller: _annees,
                  label: tr('Années avant la retraite', 'Years to retirement'),
                  suffix: tr('ans', 'yrs'),
                  onChanged: (_) => setState(() {})),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NumberField(
                  controller: _rendement,
                  label: tr('Rendement annuel', 'Annual return'),
                  suffix: '%',
                  onChanged: (_) => setState(() {})),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(tr('Âge de retraite visé', 'Target retirement age'),
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: onSurf.withValues(alpha: 0.75))),
        const SizedBox(height: 8),
        ChoiceSegments(
          options: _conversion.keys.map(_ageLabel).toList(),
          selected: _ageLabel(_age),
          onChanged: (v) => setState(() =>
              _age = _conversion.keys.firstWhere((k) => _ageLabel(k) == v)),
        ),
        const SizedBox(height: 16),
        if (projete != null)
          ResultCard(
            label:
                tr('Solde projeté à la retraite', 'Projected balance at retirement'),
            value: Fmt.money(projete, decimals: 0),
            color: AppColors.paie,
            icon: Icons.savings,
            details: [
              ResultLine(tr('Cotisations à venir', 'Upcoming contributions'),
                  Fmt.money(cotisTotales!, decimals: 0)),
              ResultLine(tr('Croissance estimée', 'Estimated growth'),
                  Fmt.money(projete - solde - cotisTotales, decimals: 0)),
              ResultLine(
                  '${tr('Rente annuelle estimée', 'Estimated annual pension')} (${_ageLabel(_age)})',
                  Fmt.money(renteAn!, decimals: 0),
                  strong: true),
              ResultLine(tr('≈ par mois', '≈ per month'),
                  Fmt.money(renteMois!, decimals: 0)),
            ],
          )
        else
          InfoBanner(
            text: tr(
                'Entre au moins ton solde (ou tes cotisations) et le nombre '
                    'd\'années avant la retraite.',
                'Enter at least your balance (or contributions) and the number '
                    'of years to retirement.'),
            color: AppColors.infos,
          ),
        const SizedBox(height: 8),
        Text(
            tr(
                'Rente estimée selon les exemples illustratifs de la CCQ '
                    '(150 000 \$ → ~10 000 \$/an à 55 ans, ~12 500 \$/an à 60 ans). '
                    'Le facteur réel est fixé par la CCQ au moment de la retraite.',
                'Pension estimated from the CCQ\'s illustrative examples '
                    '(\$150,000 → ~\$10,000/yr at 55, ~\$12,500/yr at 60). The '
                    'real factor is set by the CCQ at retirement.'),
            style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: onSurf.withValues(alpha: 0.55))),
        const SizedBox(height: 16),
        InfoBanner(
          text: tr(
              'Estimation basée sur tes hypothèses de rendement — le marché '
                  'varie. Le compte général (prestations déterminées, gelé '
                  'depuis 2005) n\'est pas inclus. Pour le vrai calcul, utilise '
                  'l\'estimateur officiel dans tes services en ligne.',
              'Estimate based on your return assumptions — the market varies. '
                  'The general account (defined benefit, frozen since 2005) is '
                  'not included. For the real calculation, use the official '
                  'estimator in your online services.'),
        ),
        const SizedBox(height: 10),
        LinkTile(
          icon: Icons.calculate,
          title: tr('Estimateur officiel (services en ligne)',
              'Official estimator (online services)'),
          subtitle: 'sel.ccq.org',
          url: 'https://sel.ccq.org',
          color: AppColors.paie,
        ),
        LinkTile(
          icon: Icons.open_in_browser,
          title: tr('Régime de retraite (CCQ)', 'Pension plan (CCQ)'),
          subtitle:
              tr('Admissibilité, calcul de la rente', 'Eligibility, pension calc'),
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/retraite',
          color: AppColors.paie,
        ),
      ],
    );
  }
}

List<String> _faits() => [
      tr(
          'Deux comptes : le compte général (prestations déterminées, gelé '
              'depuis 2005 — la rente déjà accumulée reste acquise) et le '
              'compte complémentaire (cotisations déterminées), où vont tes '
              'cotisations aujourd\'hui.',
          'Two accounts: the general account (defined benefit, frozen since '
              '2005 — pension already earned stays yours) and the complementary '
              'account (defined contribution), where your contributions go today.'),
      tr(
          'Compte général : rente = heures travaillées × un taux par 1 000 h '
              'fixé chaque année, + un supplément de 12,5 % à la retraite. La '
              'CCQ fait ce calcul; il n\'est pas projeté ici.',
          'General account: pension = hours worked × a rate per 1,000 h set '
              'each year, + a 12.5% supplement at retirement. The CCQ does this '
              'calc; it is not projected here.'),
      tr(
          'Compte complémentaire : le solde (cotisations + rendements) est '
              'converti en rente selon ton âge à la retraite — plus tu attends, '
              'plus la rente mensuelle est élevée.',
          'Complementary account: the balance (contributions + returns) is '
              'converted to a pension based on your age at retirement — the '
              'longer you wait, the higher the monthly pension.'),
      tr(
          'Cotisations versées pour chaque heure travaillée : ta part et celle '
              'de l\'employeur. Ton relevé annuel en fait état.',
          'Contributions paid for every hour worked: your share and the '
              'employer\'s. Your annual statement shows them.'),
      tr(
          'Retraite normale à 65 ans, sans condition. Retraite anticipée '
              'possible dès 55 ans (rente réduite selon l\'âge et les heures).',
          'Normal retirement at 65, no conditions. Early retirement possible '
              'from 55 (reduced pension based on age and hours).'),
      tr(
          'La retraite devient obligatoire à la fin de l\'année de ton 71e '
              'anniversaire.',
          'Retirement becomes mandatory at the end of the year of your 71st '
              'birthday.'),
    ];

class _FaitTile extends StatelessWidget {
  const _FaitTile({required this.texte});
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.elderly, size: 18, color: AppColors.paie),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texte,
                style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.85))),
          ),
        ],
      ),
    );
  }
}
