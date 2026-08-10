import 'package:flutter/material.dart';

import '../data/ccq_data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/link_tile.dart';

/// Un article de documentation (vulgarisation).
class _Doc {
  const _Doc(this.titre, this.corps);
  final String titre;
  final String corps;
}

/// Une catégorie de documentation regroupant plusieurs articles.
class _CatDoc {
  const _CatDoc(this.titre, this.icon, this.articles);
  final String titre;
  final IconData icon;
  final List<_Doc> articles;
}

const List<_CatDoc> _categories = [
  // ───────────────────────────── La CCQ et l'industrie ───────────────────
  _CatDoc('La CCQ et l\'industrie', Icons.account_balance, [
    _Doc(
      'C\'est quoi la CCQ ?',
      'La Commission de la construction du Québec administre l\'industrie de '
          'la construction : elle applique les conventions collectives, gère '
          'ta carte de compétence, tes heures, tes avantages sociaux '
          '(retraite, assurance MÉDIC) et la formation. Elle n\'est pas un '
          'syndicat : c\'est l\'organisme qui encadre toute l\'industrie.',
    ),
    _Doc(
      'La loi R-20',
      'La loi R-20 (Loi sur les relations du travail, la formation '
          'professionnelle et la gestion de la main-d\'œuvre dans l\'industrie '
          'de la construction) est la loi de base. C\'est elle qui crée la CCQ, '
          'rend les conventions obligatoires et définit qui est assujetti.',
    ),
    _Doc(
      'Les 4 secteurs et leurs conventions',
      'La construction est divisée en 4 secteurs, chacun avec sa convention '
          'collective : résidentiel, institutionnel-commercial (I.C.), '
          'industriel, et génie civil et voirie (G.C.V.). Le résidentiel se '
          'subdivise en « léger » (petits bâtiments) et « lourd ». Ton secteur '
          'détermine tes taux, primes et conditions — un même métier n\'a pas '
          'le même taux d\'un secteur à l\'autre.',
    ),
    _Doc(
      'Le champ d\'application',
      'Pas tous les travaux de construction sont assujettis à la loi R-20. '
          'Certains travaux (auto-construction, agricole, certains travaux '
          'd\'entretien) peuvent être exclus. En cas de doute sur un chantier, '
          'la CCQ peut confirmer si tu es assujetti.',
    ),
    _Doc(
      'Associations patronales et syndicales',
      'Les employeurs sont représentés par des associations patronales '
          '(ACQ, APCHQ, ACRGTQ, etc.) et les travailleurs par des associations '
          'syndicales (FTQ-Construction, CPQMCI/International, CSD, CSN, SQC). '
          'Ensemble, elles négocient les conventions. Le module Syndicats donne '
          'le détail des 5 associations et leur représentativité.',
    ),
  ]),
  // ───────────────────────── Métiers et compétence ───────────────────────
  _CatDoc('Métiers, occupations et compétence', Icons.workspace_premium, [
    _Doc(
      'Métier ou occupation ?',
      'Un « métier » (électricien, charpentier-menuisier, plombier, etc.) '
          'exige un certificat de compétence et un apprentissage encadré. Une '
          '« occupation » (manœuvre, journalier, etc.) demande aussi un '
          'certificat, mais sans le même parcours d\'apprentissage. Tes taux et '
          'ta grille en dépendent.',
    ),
    _Doc(
      'Compagnon, apprenti et paliers',
      'L\'apprenti apprend en accumulant des heures et progresse par périodes. '
          'À chaque période, il gagne un pourcentage du taux de compagnon '
          '(souvent 50, 60, 70 puis 85 %). Le compagnon détient sa carte et '
          'touche 100 %. Le nombre de périodes dépend du métier.',
    ),
    _Doc(
      'Le certificat de compétence',
      'C\'est ta « carte » : certificat de compétence-compagnon, '
          'compétence-apprenti, ou d\'occupation. Elle prouve ton droit de '
          'travailler dans ton métier sur les chantiers assujettis. Garde-la à '
          'jour et sur toi.',
    ),
    _Doc(
      'Le carnet d\'apprentissage et les ratios',
      'Ton carnet enregistre tes heures d\'apprentissage. Sur un chantier, un '
          'ratio limite le nombre d\'apprentis par compagnon selon le métier '
          '(pour garantir l\'encadrement). Ce ratio est fixé par la '
          'réglementation.',
    ),
    _Doc(
      'Les examens de qualification',
      'Une fois tes périodes d\'apprentissage complétées, tu passes l\'examen '
          'de qualification provinciale pour devenir compagnon. La réussite te '
          'donne ta carte de compétence-compagnon.',
    ),
    _Doc(
      'Bassins de main-d\'œuvre et embauche',
      'La CCQ gère des bassins régionaux de main-d\'œuvre. L\'embauche suit un '
          'ordre de priorité (région, disponibilité, etc.). La mobilité entre '
          'régions est possible selon des règles précises.',
    ),
  ]),
  // ───────────────────────────── Ta paie ─────────────────────────────────
  _CatDoc('Ta paie', Icons.payments, [
    _Doc(
      'Lire ton talon de paie',
      'Ton talon montre : tes heures (normales, 1,5×, 2×), ton taux, ton brut, '
          'l\'indemnité de congés, les retenues (impôts, RRQ, AE, RQAP, '
          'cotisations) et le net. Il indique aussi ton métier, ton secteur et '
          'ton employeur. Compare-le toujours à tes heures réelles.',
    ),
    _Doc(
      'Majorations : temps et demi, temps double',
      'Au-delà des heures normales, les heures se paient en temps et demi '
          '(× 1,5) ou double (× 2), selon la convention, le moment de la '
          'semaine et le secteur. Le travail de nuit ou des jours fériés peut '
          'être majoré. Le calculateur de paie accepte chaque type d\'heures.',
    ),
    _Doc(
      'Comprendre les taux et les hausses',
      'Les taux de l\'app sont ceux en vigueur le 26 avril 2026, tirés de la '
          'source officielle CCQ. Les conventions 2025-2029 prévoient des '
          'hausses chaque année, généralement fin avril. « Taux par métier » '
          'montre le taux actuel ET les prochains taux datés.',
    ),
    _Doc(
      'Indemnité de congés (13 %)',
      'Les congés annuels et jours fériés sont versés en indemnité — environ '
          '13 % du salaire brut. Elle est gérée par la CCQ, puis versée aux '
          'périodes prévues (vacances d\'été et d\'hiver). C\'est de l\'argent '
          'qui t\'appartient : vérifie-le sur ton relevé.',
    ),
    _Doc(
      'Les retenues sur ta paie',
      'De ton brut, on retire : l\'impôt fédéral et provincial, le RRQ '
          '(Régime de rentes du Québec), l\'assurance-emploi, le RQAP '
          '(assurance parentale), ta cotisation syndicale et la cotisation à la '
          'CCQ. Ce qui reste est ton net. Le montant varie selon ton revenu.',
    ),
    _Doc(
      'Primes et conditions particulières',
      'Selon la convention : prime de nuit, prime de hauteur, travail en espace '
          'clos, sous l\'eau, etc. Ces primes s\'ajoutent au taux. Les '
          'conditions exactes et les montants sont dans ta convention de '
          'secteur.',
    ),
  ]),
  // ──────────────────────── Déplacement et éloignement ───────────────────
  _CatDoc('Déplacement et éloignement', Icons.directions_car, [
    _Doc(
      'Frais de transport (kilométrage)',
      'Quand tu utilises ton véhicule pour te rendre à un chantier éloigné, tu '
          'peux avoir droit à une indemnité par kilomètre. Le taux/km et les '
          'seuils de distance dépendent de ta convention. L\'outil '
          '« Déplacement » t\'aide à estimer.',
    ),
    _Doc(
      'Les zones de déplacement',
      'Plusieurs conventions découpent le territoire en zones autour du '
          'chantier. Plus tu habites loin, plus l\'indemnité est élevée. '
          'Vérifie la carte des zones et les montants dans ta convention.',
    ),
    _Doc(
      'Chambre et pension',
      'Pour les chantiers très éloignés, tu peux avoir droit à la « chambre et '
          'pension » (hébergement et repas payés ou indemnisés) plutôt qu\'un '
          'aller-retour quotidien. Les conditions varient selon la convention '
          'et la distance.',
    ),
    _Doc(
      'Temps de déplacement',
      'Dans certains cas, le temps passé à te déplacer vers un chantier '
          'éloigné peut être rémunéré ou compensé. Encore une fois, c\'est la '
          'convention de ton secteur qui fixe les règles.',
    ),
  ]),
  // ───────────────────────────── Avantages sociaux ──────────────────────
  _CatDoc('Avantages sociaux', Icons.volunteer_activism, [
    _Doc(
      'Vue d\'ensemble',
      'Pour chaque heure travaillée, des cotisations (employeur + salarié) '
          'financent tes avantages : le régime d\'assurance MÉDIC et le régime '
          'de retraite. La CCQ gère ces montants; ton relevé mensuel en fait '
          'état. Garde tes relevés.',
    ),
    _Doc(
      'MÉDIC Construction (assurance)',
      'MÉDIC est ton assurance collective : maladie et médicaments, dentaire, '
          'vue, paramédical, assurance vie et salaire (invalidité). Ton régime '
          '(A, B, C, D — ou AO à DO pour les occupations) dépend de tes heures. '
          'Le module MÉDIC en donne le tableau complet.',
    ),
    _Doc(
      'Régime de retraite',
      'Deux comptes : le compte général (prestations déterminées, gelé depuis '
          '2005) et le compte complémentaire (cotisations déterminées), où vont '
          'tes cotisations aujourd\'hui. Retraite normale à 65 ans, anticipée '
          'dès 55 ans. Le module Retraite projette ton compte complémentaire.',
    ),
    _Doc(
      'Vacances de la construction',
      'L\'industrie ferme lors de deux périodes de vacances par année (été et '
          'hiver), fixées chaque année par convention. Ton indemnité de congés '
          'accumulée est versée pour couvrir ces périodes. Vérifie les dates '
          'officielles sur ccq.org.',
    ),
  ]),
  // ─────────────────────── Droits et obligations ────────────────────────
  _CatDoc('Tes droits et obligations', Icons.gavel, [
    _Doc(
      'Heures et horaire de travail',
      'La semaine normale et les heures quotidiennes sont fixées par ta '
          'convention (souvent 40 h/semaine). Au-delà, ce sont des heures '
          'supplémentaires majorées. Les horaires comprimés ou de nuit ont '
          'leurs propres règles.',
    ),
    _Doc(
      'Jours fériés chômés',
      'Plusieurs jours fériés sont chômés et payés via l\'indemnité de congés. '
          'La liste et le traitement exact sont dans la convention. L\'outil '
          '« Jours fériés » en donne un aperçu.',
    ),
    _Doc(
      'Mise à pied, rappel et sécurité d\'emploi',
      'La construction fonctionne par chantiers : mises à pied et rappels sont '
          'fréquents. La convention encadre les avis, l\'ordre de rappel et '
          'certains droits. Une mise à pied n\'est pas un congédiement.',
    ),
    _Doc(
      'Mobilité de la main-d\'œuvre',
      'Tu peux travailler dans d\'autres régions selon des règles de mobilité. '
          'La priorité régionale existe, mais la mobilité interrégionale est '
          'permise dans plusieurs situations. La CCQ peut t\'expliquer ta '
          'situation.',
    ),
    _Doc(
      'Recours et plaintes',
      'Si tu n\'es pas payé correctement (heures, taux, avantages), tu peux '
          'porter plainte à la CCQ, qui a le pouvoir d\'enquêter et de récupérer '
          'les sommes dues. Garde tes talons et note tes heures — la feuille de '
          'temps de l\'app t\'aide à bâtir ta preuve.',
    ),
  ]),
  // ─────────────────────────── Santé et sécurité ────────────────────────
  _CatDoc('Santé et sécurité', Icons.health_and_safety, [
    _Doc(
      'Tes obligations et celles de l\'employeur',
      'L\'employeur doit fournir un milieu sécuritaire, l\'équipement de '
          'protection et la formation. Toi, tu dois travailler de façon '
          'sécuritaire, porter tes EPI et signaler les dangers. La sécurité '
          'est une responsabilité partagée.',
    ),
    _Doc(
      'La carte ASP (cours obligatoire)',
      'Pour travailler sur un chantier au Québec, le cours « Santé et sécurité '
          'générale sur les chantiers de construction » (30 heures) est '
          'obligatoire. Il donne la carte ASP Construction. Sans elle, l\'accès '
          'au chantier peut t\'être refusé.',
    ),
    _Doc(
      'Le droit de refus',
      'Tu as le droit de refuser un travail si tu as des motifs raisonnables '
          'de croire qu\'il te met en danger, toi ou un autre. Avise ton '
          'supérieur et le représentant en sécurité. Ce droit est protégé par '
          'la loi (CNESST).',
    ),
    _Doc(
      'Représentant et comité de chantier',
      'Sur les gros chantiers, un représentant en santé et sécurité et un '
          'comité veillent à la prévention. N\'hésite pas à leur parler d\'un '
          'danger — c\'est leur rôle.',
    ),
    _Doc(
      'EPI, SIMDUT et lignes électriques',
      'Casque, bottes, lunettes, harnais : tes EPI sauvent des vies. Le module '
          'SIMDUT explique les 9 pictogrammes des produits dangereux, et le '
          'module Lignes électriques donne les distances d\'approche à '
          'respecter. Consulte-les.',
    ),
  ]),
  // ─────────────────────────── Formation et carrière ────────────────────
  _CatDoc('Formation et carrière', Icons.school, [
    _Doc(
      'Le perfectionnement',
      'La CCQ et le fonds de formation offrent des cours de perfectionnement, '
          'souvent gratuits et parfois rémunérés, pour développer tes '
          'compétences. Se perfectionner aide à décrocher plus de contrats et à '
          'progresser.',
    ),
    _Doc(
      'La formation obligatoire',
      'Certains travaux exigent une formation ou une certification précise '
          '(espaces clos, travail en hauteur, échafaudages, SIMDUT, etc.). '
          'Vérifie les exigences avant d\'accepter une tâche spécialisée.',
    ),
    _Doc(
      'Devenir compagnon',
      'Complète tes périodes d\'apprentissage, accumule tes heures dans ton '
          'carnet, puis réussis l\'examen de qualification. Tu passes alors de '
          'apprenti à compagnon — et à 100 % du taux.',
    ),
    _Doc(
      'Devenir entrepreneur (RBQ)',
      'Pour travailler à ton compte comme entrepreneur, il faut une licence de '
          'la Régie du bâtiment du Québec (RBQ), qui vérifie tes compétences '
          'techniques, administratives et ta probité. C\'est distinct de ta '
          'carte de compétence CCQ.',
    ),
  ]),
  // ─────────────────────────────── Glossaire ────────────────────────────
  _CatDoc('Glossaire', Icons.menu_book, [
    _Doc('CCQ',
        'Commission de la construction du Québec — gère l\'industrie, les '
            'cartes, les heures et les avantages.'),
    _Doc('CNESST',
        'Commission des normes, de l\'équité, de la santé et de la sécurité du '
            'travail — santé-sécurité et indemnisation.'),
    _Doc('RBQ',
        'Régie du bâtiment du Québec — licences d\'entrepreneur et qualité des '
            'bâtiments.'),
    _Doc('Loi R-20',
        'La loi qui encadre les relations de travail et la formation dans la '
            'construction.'),
    _Doc('Compagnon / apprenti',
        'Compagnon : travailleur qualifié (carte, 100 % du taux). Apprenti : '
            'en apprentissage, payé un % du taux de compagnon.'),
    _Doc('Secteur / convention',
        'Secteur : un des 4 champs (rés., I.C., ind., G.C.V.). Convention : '
            'l\'entente qui fixe salaires et conditions du secteur.'),
    _Doc('Annexe',
        'Sous-grille d\'une convention (ex. travail de jour/nuit, région, '
            'chantier isolé).'),
    _Doc('MÉDIC',
        'Le régime collectif d\'assurance des travailleurs de la '
            'construction, géré par la CCQ.'),
    _Doc('EPI',
        'Équipement de protection individuelle : casque, bottes, lunettes, '
            'harnais, protection auditive, etc.'),
    _Doc('ASP Construction',
        'Organisme de prévention; donne le cours de sécurité de 30 h et la '
            'carte obligatoire sur les chantiers.'),
  ]),
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
              'Une base d\'infos pour t\'y retrouver dans l\'industrie. Pour les '
              'règles et les chiffres exacts, réfère-toi à ta convention '
              'collective et à ccq.org — ce sont elles qui font foi.',
          icon: Icons.menu_book,
          color: AppColors.infos,
        ),
        const SizedBox(height: 16),
        const SectionTitle('Documents & sites officiels',
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
          icon: Icons.school,
          title: 'ASP Construction',
          subtitle: 'Cours de sécurité (30 h) et prévention',
          url: 'https://www.asp-construction.org',
          color: AppColors.infos,
        ),
        const LinkTile(
          icon: Icons.apartment,
          title: 'Régie du bâtiment (RBQ)',
          subtitle: 'Licences d\'entrepreneur',
          url: 'https://www.rbq.gouv.qc.ca',
          color: AppColors.infos,
        ),
        const LinkTile(
          icon: Icons.emergency,
          title: 'CNESST — santé et sécurité',
          subtitle: 'Prévention, droits, indemnisation',
          url: 'https://www.cnesst.gouv.qc.ca',
          color: AppColors.infos,
        ),
        const SizedBox(height: 8),
        for (final cat in _categories) ...[
          const SizedBox(height: 10),
          SectionTitle(cat.titre, color: AppColors.infos),
          const SizedBox(height: 4),
          ...cat.articles.map((a) => _DocCard(doc: a, icon: cat.icon)),
        ],
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
  const _DocCard({required this.doc, required this.icon});
  final _Doc doc;
  final IconData icon;

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
            child: Icon(icon, color: AppColors.infos, size: 22),
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
