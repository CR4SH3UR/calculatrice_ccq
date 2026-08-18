import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/link_tile.dart';

/// Une association syndicale représentative (loi R-20).
class _Union {
  const _Union(
      this.sigle, this.nom, this.representativite, this.site, this.representants);
  final String sigle;
  final String nom;
  final double representativite; // % au scrutin 2024
  final String site;
  final String representants; // page « représentants / nous joindre »
}

// Triées par représentativité (scrutin 2024). Sources : ccq.org et sites des
// syndicats (pages officielles des représentants / « nous joindre »).
const List<_Union> _unions = [
  _Union(
    'FTQ-Construction',
    'Fédération des travailleurs et travailleuses du Québec',
    44.069,
    'https://ftqconstruction.org',
    'https://ftqconstruction.org/trouvez-vos-representant-e-s/',
  ),
  _Union(
    'SQC',
    'Syndicat québécois de la construction',
    21.703,
    'https://www.sqc.ca',
    'https://www.sqc.ca/nous-joindre/',
  ),
  _Union(
    'International (CPQMC)',
    'Conseil provincial du Québec des métiers de la construction',
    20.698,
    'https://cpqmci.org',
    'https://cpqmci.org/sections-locales/',
  ),
  _Union(
    'CSD Construction',
    'Centrale des syndicats démocratiques',
    7.552,
    'https://www.csd.qc.ca',
    'https://www.csd.qc.ca/nous-contacter/',
  ),
  _Union(
    'CSN-Construction',
    'Confédération des syndicats nationaux',
    5.978,
    'https://www.csnconstruction.qc.ca',
    'https://www.csnconstruction.qc.ca/a-propos/structure/',
  ),
];

class SyndicatScreen extends StatelessWidget {
  const SyndicatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: tr('Syndicats', 'Unions'),
      children: [
        InfoBanner(
          text: tr(
              'La construction au Québec compte 5 associations syndicales '
                  'représentatives (loi R-20). Tu choisis ton allégeance lors '
                  'du scrutin syndical; la représentativité ci-dessous vient du '
                  'scrutin de 2024. Touche « Représentants » pour joindre le '
                  'tien.',
              'Quebec construction has 5 representative union associations '
                  '(Act R-20). You choose your allegiance at the union vote; the '
                  'representativity below comes from the 2024 vote. Tap '
                  '« Representatives » to reach yours.'),
          icon: Icons.groups,
          color: AppColors.syndicat,
        ),
        const SizedBox(height: 16),
        SectionTitle(tr('Les 5 associations', 'The 5 associations'),
            color: AppColors.syndicat),
        ..._unions.map((u) => _UnionCard(union: u)),
        const SizedBox(height: 10),
        SectionTitle(tr('Cotisations syndicales', 'Union dues'),
            color: AppColors.syndicat),
        InfoBanner(
          text: tr(
              'La cotisation syndicale est prélevée chaque semaine sur ta paie. '
                  'Le montant varie selon le syndicat, le métier et l\'horaire '
                  'de travail. Tu la vois sur ton relevé de paie.',
              'Union dues are deducted from your pay each week. The amount '
                  'varies by union, trade and work schedule. You see it on your '
                  'pay stub.'),
        ),
        const SizedBox(height: 12),
        LinkTile(
          icon: Icons.request_quote,
          title: tr('Taux de cotisations syndicales', 'Union dues rates'),
          subtitle: tr('Montants officiels · ccq.org', 'Official amounts · ccq.org'),
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/salaire-taux/cotisations-syndicales',
          color: AppColors.syndicat,
        ),
        LinkTile(
          icon: Icons.how_to_vote,
          title: tr('Associations & scrutin syndical', 'Associations & union vote'),
          subtitle: tr('Rôles, représentativité, changement d\'allégeance',
              'Roles, representativity, changing allegiance'),
          url: 'https://www.ccq.org/fr-CA/loi-r20/relations-travail/associations-syndicales',
          color: AppColors.syndicat,
        ),
      ],
    );
  }
}

class _UnionCard extends StatelessWidget {
  const _UnionCard({required this.union});
  final _Union union;

  @override
  Widget build(BuildContext context) {
    final Color onSurf = Theme.of(context).colorScheme.onSurface;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.syndicat.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.groups,
                      color: AppColors.syndicat, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(union.sigle,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15.5)),
                      Text(union.nom,
                          style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              color: onSurf.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: union.representativite / 100,
                      minHeight: 7,
                      backgroundColor:
                          AppColors.syndicat.withValues(alpha: 0.12),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.syndicat),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${union.representativite.toStringAsFixed(1)} %',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.syndicat)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _LinkChip(
                    icon: Icons.language,
                    label: tr('Site web', 'Website'),
                    onTap: () => openUrl(context, union.site),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LinkChip(
                    icon: Icons.contact_phone,
                    label: tr('Représentants', 'Representatives'),
                    filled: true,
                    onTap: () => openUrl(context, union.representants),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    const Color c = AppColors.syndicat;
    return Material(
      color: filled ? c : c.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: filled ? Colors.white : c),
              const SizedBox(width: 7),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: filled ? Colors.white : c)),
            ],
          ),
        ),
      ),
    );
  }
}
