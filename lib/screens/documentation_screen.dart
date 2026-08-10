import 'package:flutter/material.dart';

import '../data/ccq_data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/link_tile.dart';

/// Un article de documentation (vulgarisation).
class _Doc {
  const _Doc(this.titre, this.icon, this.corps);
  final String titre;
  final IconData icon;
  final String corps;
}

const List<_Doc> _articles = [
  _Doc(
    'Les 4 secteurs et leurs conventions',
    Icons.account_tree,
    'La construction au Québec est divisée en 4 secteurs, chacun avec sa '
        'propre convention collective : résidentiel, institutionnel-commercial '
        '(I.C.), industriel, et génie civil et voirie (G.C.V.). Le résidentiel '
        'se subdivise en « léger » (petits bâtiments) et « lourd ». Ton secteur '
        'détermine tes taux, tes primes et tes conditions. Un même métier n\'a '
        'pas le même taux d\'un secteur à l\'autre.',
  ),
  _Doc(
    'Compagnon, apprenti et paliers',
    Icons.workspace_premium,
    'L\'apprenti apprend le métier en accumulant des heures et progresse par '
        'périodes. À chaque période, il gagne un pourcentage du taux de '
        'compagnon (souvent 50, 60, 70 puis 85 %). Le compagnon détient sa '
        'carte de compétence et touche 100 % du taux. Le nombre de périodes '
        'dépend du métier.',
  ),
  _Doc(
    'Comprendre les taux et les hausses',
    Icons.trending_up,
    'Les taux affichés dans l\'app sont ceux en vigueur le 26 avril 2026, '
        'tirés de la source officielle de la CCQ. Les conventions 2025-2029 '
        'prévoient des hausses chaque année, généralement à la fin avril. '
        'L\'outil « Taux par métier » montre le taux actuel ET les prochains '
        'taux avec leur date. En cas de doute, la convention a préséance.',
  ),
  _Doc(
    'Temps supplémentaire',
    Icons.more_time,
    'Au-delà des heures normales, les heures se paient en temps et demi '
        '(× 1,5) ou en temps double (× 2), selon la convention, le moment de '
        'la semaine et le secteur. Les règles précises (seuils, jours fériés, '
        'travail de nuit) sont dans ta convention. Le calculateur de paie te '
        'laisse entrer chaque type d\'heures.',
  ),
  _Doc(
    'Indemnité de congés (13 %)',
    Icons.beach_access,
    'Dans la construction, les congés annuels et les jours fériés sont versés '
        'sous forme d\'indemnité — généralement environ 13 % du salaire brut. '
        'Elle apparaît sur ta paie ou est déposée par la CCQ, puis versée aux '
        'périodes prévues (vacances d\'été et d\'hiver).',
  ),
  _Doc(
    'Avantages sociaux',
    Icons.volunteer_activism,
    'Une partie de chaque heure travaillée va à tes avantages sociaux : '
        'régime de retraite et régime d\'assurance (Médic Construction), avec '
        'une part payée par l\'employeur et une part par le salarié. Ces '
        'montants sont gérés par la CCQ; ton relevé mensuel en fait état.',
  ),
  _Doc(
    'Déplacement, transport et pension',
    Icons.directions_car,
    'Selon l\'éloignement du chantier, tu peux avoir droit à une indemnité de '
        'transport (kilométrage), à des frais de déplacement par zones, ou à '
        'la « chambre et pension » pour les chantiers éloignés. Les barèmes '
        'varient d\'une convention à l\'autre — vérifie la tienne.',
  ),
  _Doc(
    'Carte de compétence et heures',
    Icons.badge,
    'La CCQ tient le compte de tes heures travaillées et gère ta carte de '
        'compétence, ton carnet d\'apprentissage et l\'accès aux métiers. '
        'Garde tes talons de paie et vérifie ton relevé : tes heures servent '
        'à ta progression et à tes avantages.',
  ),
  _Doc(
    'Glossaire',
    Icons.menu_book,
    'CCQ : Commission de la construction du Québec (gère l\'industrie). '
        'CNESST : santé, sécurité et normes du travail. Compagnon : '
        'travailleur qualifié (carte de compétence). Apprenti : en '
        'apprentissage, payé un % du compagnon. Secteur : un des 4 champs '
        '(rés., I.C., ind., G.C.V.). Convention : l\'entente qui fixe salaires '
        'et conditions. Annexe : sous-grille d\'une convention (jour/nuit, '
        'région).',
  ),
  _Doc(
    'Ressources officielles',
    Icons.link,
    'Taux de salaire officiels et outil de calcul : ccq.org/salaire. '
        'Ta convention collective (secteur) : sur ccq.org. Santé et sécurité, '
        'indemnisation : cnesst.gouv.qc.ca. En cas d\'écart avec l\'app, les '
        'documents officiels ont toujours préséance.',
  ),
];

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Documentation',
      children: [
        const InfoBanner(
          text:
              'Infos générales pour s\'y retrouver. Pour les règles exactes, '
              'réfère-toi à ta convention collective et à ccq.org — ce sont '
              'elles qui font foi.',
          icon: Icons.menu_book,
          color: AppColors.infos,
        ),
        const SizedBox(height: 16),
        const SectionTitle('Conventions & documents officiels',
            color: AppColors.infos),
        const LinkTile(
          icon: Icons.gavel,
          title: 'Conventions collectives (4 secteurs)',
          subtitle: 'Résidentiel, I.C., industriel, génie civil',
          url: 'https://www.ccq.org/fr-CA/loi-r20/conventions-collectives',
          color: AppColors.infos,
        ),
        const LinkTile(
          icon: Icons.request_quote,
          title: 'Taux de salaire officiels',
          subtitle: 'Outil de la CCQ, par secteur et métier',
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/salaire-taux',
          color: AppColors.infos,
        ),
        const LinkTile(
          icon: Icons.health_and_safety,
          title: 'MÉDIC Construction',
          subtitle: 'Assurances et avantages sociaux',
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/medic-construction',
          color: AppColors.infos,
        ),
        const LinkTile(
          icon: Icons.savings,
          title: 'Régime de retraite',
          subtitle: 'Ta rente et tes heures accumulées',
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/retraite',
          color: AppColors.infos,
        ),
        const LinkTile(
          icon: Icons.groups,
          title: 'Cotisations syndicales',
          subtitle: 'Montants par syndicat et métier',
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/salaire-taux/cotisations-syndicales',
          color: AppColors.infos,
        ),
        const LinkTile(
          icon: Icons.badge,
          title: 'Certificat de compétence',
          subtitle: 'Carte, carnet et apprentissage',
          url: 'https://www.ccq.org/fr-CA/travailleurs',
          color: AppColors.infos,
        ),
        const LinkTile(
          icon: Icons.emergency,
          title: 'CNESST — santé et sécurité',
          subtitle: 'Prévention, droits, indemnisation',
          url: 'https://www.cnesst.gouv.qc.ca',
          color: AppColors.infos,
        ),
        const SizedBox(height: 16),
        const SectionTitle('Comprendre la CCQ', color: AppColors.infos),
        ..._articles.map((a) => _DocCard(doc: a)),
        const SizedBox(height: 6),
        Center(
          child: Text(CcqData.source,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11.5,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5))),
        ),
      ],
    );
  }
}

class _DocCard extends StatelessWidget {
  const _DocCard({required this.doc});
  final _Doc doc;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.infos.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(doc.icon, color: AppColors.infos, size: 22),
          ),
          title: Text(doc.titre,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(doc.corps,
                  style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8))),
            ),
          ],
        ),
      ),
    );
  }
}
