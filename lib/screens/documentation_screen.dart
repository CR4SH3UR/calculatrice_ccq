import 'package:flutter/material.dart';

import '../data/ccq_data.dart';
import '../l10n/lang.dart';
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

/// Traduction des titres de catégories (repli sur le français si absent).
const Map<String, String> _catEn = {
  'La CCQ et l\'industrie': 'The CCQ and the industry',
  'Métiers, occupations et compétence': 'Trades, occupations and competency',
  'Ta paie': 'Your pay',
  'Déplacement et éloignement': 'Travel and remoteness',
  'Avantages sociaux': 'Social benefits',
  'Tes droits et obligations': 'Your rights and obligations',
  'Santé et sécurité': 'Health and safety',
  'Formation et carrière': 'Training and career',
  'Glossaire': 'Glossary',
};

/// Traduction des articles, indexée par le titre français (unique). Le corpus
/// français ci-dessus reste la source; ceci n'ajoute que l'anglais.
const Map<String, ({String titre, String corps})> _docEn = {
  // La CCQ et l'industrie
  'C\'est quoi la CCQ ?': (
    titre: 'What is the CCQ?',
    corps: 'The Commission de la construction du Québec runs the construction '
        'industry: it applies the collective agreements, manages your '
        'competency card, your hours, your social benefits (pension, MÉDIC '
        'insurance) and training. It is not a union: it\'s the body that '
        'oversees the whole industry.',
  ),
  'La loi R-20': (
    titre: 'The R-20 Act',
    corps: 'The R-20 Act (Act respecting labour relations, vocational training '
        'and workforce management in the construction industry) is the '
        'foundational law. It creates the CCQ, makes the agreements mandatory '
        'and defines who is covered.',
  ),
  'Les 4 secteurs et leurs conventions': (
    titre: 'The 4 sectors and their agreements',
    corps: 'Construction is divided into 4 sectors, each with its own '
        'collective agreement: residential, institutional-commercial (I.C.), '
        'industrial, and civil engineering and roads (C.E.R.). Residential '
        'splits into « light » (small buildings) and « heavy ». Your sector '
        'sets your rates, premiums and conditions — the same trade doesn\'t '
        'earn the same rate from one sector to another.',
  ),
  'Le champ d\'application': (
    titre: 'The scope of application',
    corps: 'Not all construction work is covered by the R-20 Act. Some work '
        '(self-building, agricultural, certain maintenance work) may be '
        'excluded. If you\'re unsure about a site, the CCQ can confirm whether '
        'you\'re covered.',
  ),
  'Associations patronales et syndicales': (
    titre: 'Employer and union associations',
    corps: 'Employers are represented by employer associations (ACQ, APCHQ, '
        'ACRGTQ, etc.) and workers by union associations (FTQ-Construction, '
        'CPQMCI/International, CSD, CSN, SQC). Together they negotiate the '
        'agreements. The Unions module details the 5 associations and their '
        'representativity.',
  ),
  // Métiers, occupations et compétence
  'Métier ou occupation ?': (
    titre: 'Trade or occupation?',
    corps: 'A « trade » (electrician, carpenter-joiner, plumber, etc.) '
        'requires a competency certificate and a supervised apprenticeship. An '
        '« occupation » (labourer, general help, etc.) also requires a '
        'certificate, but without the same apprenticeship path. Your rates and '
        'your schedule depend on it.',
  ),
  'Compagnon, apprenti et paliers': (
    titre: 'Journeyman, apprentice and steps',
    corps: 'The apprentice learns by accumulating hours and progresses in '
        'periods. At each period, they earn a percentage of the journeyman '
        'rate (often 50, 60, 70 then 85%). The journeyman holds their card and '
        'earns 100%. The number of periods depends on the trade.',
  ),
  'Le certificat de compétence': (
    titre: 'The competency certificate',
    corps: 'It\'s your « card »: journeyman-competency, apprentice-competency, '
        'or occupation certificate. It proves your right to work in your trade '
        'on covered sites. Keep it up to date and on you.',
  ),
  'Le carnet d\'apprentissage et les ratios': (
    titre: 'The apprenticeship logbook and ratios',
    corps: 'Your logbook records your apprenticeship hours. On a site, a ratio '
        'limits the number of apprentices per journeyman by trade (to ensure '
        'supervision). This ratio is set by regulation.',
  ),
  'Les examens de qualification': (
    titre: 'The qualification exams',
    corps: 'Once your apprenticeship periods are complete, you take the '
        'provincial qualification exam to become a journeyman. Passing gives '
        'you your journeyman-competency card.',
  ),
  'Bassins de main-d\'œuvre et embauche': (
    titre: 'Labour pools and hiring',
    corps: 'The CCQ manages regional labour pools. Hiring follows a priority '
        'order (region, availability, etc.). Mobility between regions is '
        'possible under specific rules.',
  ),
  // Ta paie
  'Lire ton talon de paie': (
    titre: 'Reading your pay stub',
    corps: 'Your stub shows: your hours (regular, 1.5×, 2×), your rate, your '
        'gross, the vacation pay, the deductions (taxes, QPP, EI, QPIP, dues) '
        'and the net. It also lists your trade, sector and employer. Always '
        'compare it to your actual hours.',
  ),
  'Majorations : temps et demi, temps double': (
    titre: 'Premiums: time and a half, double time',
    corps: 'Beyond regular hours, hours are paid at time and a half (× 1.5) or '
        'double (× 2), depending on the agreement, the time of week and the '
        'sector. Night work or holidays may be increased. The pay calculator '
        'accepts each type of hours.',
  ),
  'Comprendre les taux et les hausses': (
    titre: 'Understanding rates and increases',
    corps: 'The app\'s rates are those in force on April 26, 2026, drawn from '
        'the official CCQ source. The 2025-2029 agreements provide for '
        'increases each year, generally in late April. « Rates by trade » '
        'shows the current rate AND the upcoming dated rates.',
  ),
  'Indemnité de congés (13 %)': (
    titre: 'Vacation pay (13%)',
    corps: 'Annual leave and holidays are paid as an indemnity — about 13% of '
        'gross pay. It\'s managed by the CCQ, then paid at the set periods '
        '(summer and winter vacations). It\'s money that belongs to you: check '
        'it on your statement.',
  ),
  'Les retenues sur ta paie': (
    titre: 'The deductions on your pay',
    corps: 'From your gross, they deduct: federal and provincial tax, the QPP '
        '(Quebec Pension Plan), employment insurance, the QPIP (parental '
        'insurance), your union dues and the CCQ contribution. What\'s left is '
        'your net. The amount varies with your income.',
  ),
  'Primes et conditions particulières': (
    titre: 'Premiums and special conditions',
    corps: 'Depending on the agreement: night premium, height premium, '
        'confined-space work, underwater, etc. These premiums add to the rate. '
        'The exact conditions and amounts are in your sector agreement.',
  ),
  // Déplacement et éloignement
  'Frais de transport (kilométrage)': (
    titre: 'Transport costs (mileage)',
    corps: 'When you use your vehicle to get to a remote site, you may be '
        'entitled to a per-kilometre allowance. The rate/km and the distance '
        'thresholds depend on your agreement. The « Travel » tool helps you '
        'estimate.',
  ),
  'Les zones de déplacement': (
    titre: 'The travel zones',
    corps: 'Several agreements divide the territory into zones around the '
        'site. The farther you live, the higher the allowance. Check the zone '
        'map and the amounts in your agreement.',
  ),
  'Chambre et pension': (
    titre: 'Room and board',
    corps: 'For very remote sites, you may be entitled to « room and board » '
        '(lodging and meals paid or reimbursed) rather than a daily round '
        'trip. The conditions vary by agreement and distance.',
  ),
  'Temps de déplacement': (
    titre: 'Travel time',
    corps: 'In some cases, the time spent travelling to a remote site can be '
        'paid or compensated. Again, it\'s your sector agreement that sets the '
        'rules.',
  ),
  // Avantages sociaux
  'Vue d\'ensemble': (
    titre: 'Overview',
    corps: 'For each hour worked, contributions (employer + employee) fund '
        'your benefits: the MÉDIC insurance plan and the pension plan. The CCQ '
        'manages these amounts; your monthly statement shows them. Keep your '
        'statements.',
  ),
  'MÉDIC Construction (assurance)': (
    titre: 'MÉDIC Construction (insurance)',
    corps: 'MÉDIC is your group insurance: health and drugs, dental, vision, '
        'paramedical, life and salary (disability) insurance. Your plan (A, B, '
        'C, D — or AO to DO for occupations) depends on your hours. The MÉDIC '
        'module gives the full table.',
  ),
  'Régime de retraite': (
    titre: 'Pension plan',
    corps: 'Two accounts: the general account (defined benefits, frozen since '
        '2005) and the supplementary account (defined contributions), where '
        'your contributions go today. Normal retirement at 65, early from 55. '
        'The Retirement module projects your supplementary account.',
  ),
  'Vacances de la construction': (
    titre: 'Construction holidays',
    corps: 'The industry closes for two vacation periods per year (summer and '
        'winter), set each year by agreement. Your accumulated vacation pay is '
        'paid to cover these periods. Check the official dates on ccq.org.',
  ),
  // Tes droits et obligations
  'Heures et horaire de travail': (
    titre: 'Hours and work schedule',
    corps: 'The normal week and daily hours are set by your agreement (often '
        '40 h/week). Beyond that, they are increased overtime hours. '
        'Compressed or night schedules have their own rules.',
  ),
  'Jours fériés chômés': (
    titre: 'Paid statutory holidays',
    corps: 'Several holidays are unworked and paid through the vacation pay. '
        'The list and exact treatment are in the agreement. The « Holidays » '
        'tool gives an overview.',
  ),
  'Mise à pied, rappel et sécurité d\'emploi': (
    titre: 'Layoff, recall and job security',
    corps: 'Construction runs by projects: layoffs and recalls are frequent. '
        'The agreement governs notices, the recall order and certain rights. A '
        'layoff is not a dismissal.',
  ),
  'Mobilité de la main-d\'œuvre': (
    titre: 'Workforce mobility',
    corps: 'You can work in other regions under mobility rules. Regional '
        'priority exists, but inter-regional mobility is allowed in several '
        'situations. The CCQ can explain your situation.',
  ),
  'Recours et plaintes': (
    titre: 'Remedies and complaints',
    corps: 'If you\'re not paid correctly (hours, rate, benefits), you can file '
        'a complaint with the CCQ, which has the power to investigate and '
        'recover the amounts owed. Keep your stubs and note your hours — the '
        'app\'s timesheet helps you build your proof.',
  ),
  // Santé et sécurité
  'Tes obligations et celles de l\'employeur': (
    titre: 'Your obligations and the employer\'s',
    corps: 'The employer must provide a safe environment, protective equipment '
        'and training. You must work safely, wear your PPE and report hazards. '
        'Safety is a shared responsibility.',
  ),
  'La carte ASP (cours obligatoire)': (
    titre: 'The ASP card (mandatory course)',
    corps: 'To work on a site in Quebec, the « General health and safety on '
        'construction sites » course (30 hours) is mandatory. It grants the '
        'ASP Construction card. Without it, site access can be denied.',
  ),
  'Le droit de refus': (
    titre: 'The right of refusal',
    corps: 'You have the right to refuse work if you have reasonable grounds '
        'to believe it endangers you or someone else. Notify your supervisor '
        'and the safety representative. This right is protected by law '
        '(CNESST).',
  ),
  'Représentant et comité de chantier': (
    titre: 'Representative and site committee',
    corps: 'On large sites, a health and safety representative and a committee '
        'oversee prevention. Don\'t hesitate to tell them about a hazard — '
        'that\'s their role.',
  ),
  'EPI, SIMDUT et lignes électriques': (
    titre: 'PPE, WHMIS and power lines',
    corps: 'Hard hat, boots, glasses, harness: your PPE saves lives. The WHMIS '
        'module explains the 9 pictograms of hazardous products, and the Power '
        'lines module gives the approach distances to respect. Check them out.',
  ),
  // Formation et carrière
  'Le perfectionnement': (
    titre: 'Skills upgrading',
    corps: 'The CCQ and the training fund offer upgrading courses, often free '
        'and sometimes paid, to develop your skills. Upgrading helps land more '
        'contracts and advance.',
  ),
  'La formation obligatoire': (
    titre: 'Mandatory training',
    corps: 'Some work requires specific training or certification (confined '
        'spaces, work at heights, scaffolding, WHMIS, etc.). Check the '
        'requirements before accepting a specialized task.',
  ),
  'Devenir compagnon': (
    titre: 'Becoming a journeyman',
    corps: 'Complete your apprenticeship periods, accumulate your hours in '
        'your logbook, then pass the qualification exam. You then go from '
        'apprentice to journeyman — and to 100% of the rate.',
  ),
  'Devenir entrepreneur (RBQ)': (
    titre: 'Becoming a contractor (RBQ)',
    corps: 'To work for yourself as a contractor, you need a licence from the '
        'Régie du bâtiment du Québec (RBQ), which checks your technical and '
        'administrative skills and your integrity. It\'s separate from your '
        'CCQ competency card.',
  ),
  // Glossaire
  'CCQ': (
    titre: 'CCQ',
    corps: 'Commission de la construction du Québec — manages the industry, '
        'cards, hours and benefits.',
  ),
  'CNESST': (
    titre: 'CNESST',
    corps: 'Commission des normes, de l\'équité, de la santé et de la sécurité '
        'du travail — health-safety and compensation.',
  ),
  'RBQ': (
    titre: 'RBQ',
    corps: 'Régie du bâtiment du Québec — contractor licences and building '
        'quality.',
  ),
  'Loi R-20': (
    titre: 'R-20 Act',
    corps: 'The law that governs labour relations and training in '
        'construction.',
  ),
  'Compagnon / apprenti': (
    titre: 'Journeyman / apprentice',
    corps: 'Journeyman: qualified worker (card, 100% of rate). Apprentice: in '
        'training, paid a % of the journeyman rate.',
  ),
  'Secteur / convention': (
    titre: 'Sector / agreement',
    corps: 'Sector: one of the 4 fields (res., I.C., ind., C.E.R.). Agreement: '
        'the deal that sets the sector\'s wages and conditions.',
  ),
  'Annexe': (
    titre: 'Schedule',
    corps: 'Sub-grid of an agreement (e.g. day/night work, region, remote '
        'site).',
  ),
  'MÉDIC': (
    titre: 'MÉDIC',
    corps: 'The group insurance plan for construction workers, managed by the '
        'CCQ.',
  ),
  'EPI': (
    titre: 'PPE',
    corps: 'Personal protective equipment: hard hat, boots, glasses, harness, '
        'hearing protection, etc.',
  ),
  'ASP Construction': (
    titre: 'ASP Construction',
    corps: 'Prevention body; gives the 30-h safety course and the card '
        'required on sites.',
  ),
};

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Garde-fou (debug seulement) : chaque catégorie et chaque article doit
    // avoir sa traduction, sinon l'anglais retombe silencieusement au français.
    assert(() {
      for (final cat in _categories) {
        assert(_catEn.containsKey(cat.titre), 'Cat EN manquante: ${cat.titre}');
        for (final a in cat.articles) {
          assert(_docEn.containsKey(a.titre), 'Doc EN manquant: ${a.titre}');
        }
      }
      return true;
    }());
    return ToolScaffold(
      title: 'Documentation',
      children: [
        InfoBanner(
          text: tr(
              'Une base d\'infos pour t\'y retrouver dans l\'industrie. Pour les '
                  'règles et les chiffres exacts, réfère-toi à ta convention '
                  'collective et à ccq.org — ce sont elles qui font foi.',
              'A base of info to find your way in the industry. For the exact '
                  'rules and figures, refer to your collective agreement and to '
                  'ccq.org — those are what prevail.'),
          icon: Icons.menu_book,
          color: AppColors.infos,
        ),
        const SizedBox(height: 16),
        SectionTitle(tr('Documents & sites officiels', 'Official documents & sites'),
            color: AppColors.infos),
        LinkTile(
          icon: Icons.gavel,
          title: tr('Conventions collectives (4 secteurs)',
              'Collective agreements (4 sectors)'),
          subtitle: tr('Résidentiel, I.C., industriel, génie civil',
              'Residential, I.C., industrial, civil engineering'),
          url: 'https://www.ccq.org/fr-CA/loi-r20/conventions-collectives',
          color: AppColors.infos,
        ),
        LinkTile(
          icon: Icons.request_quote,
          title: tr('Taux de salaire officiels', 'Official wage rates'),
          subtitle: tr('Outil de la CCQ, par secteur et métier',
              'CCQ tool, by sector and trade'),
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/salaire-taux',
          color: AppColors.infos,
        ),
        LinkTile(
          icon: Icons.health_and_safety,
          title: 'MÉDIC Construction',
          subtitle: tr('Assurances et avantages sociaux',
              'Insurance and social benefits'),
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/medic-construction',
          color: AppColors.infos,
        ),
        LinkTile(
          icon: Icons.savings,
          title: tr('Régime de retraite', 'Pension plan'),
          subtitle: tr('Ta rente et tes heures accumulées',
              'Your pension and accumulated hours'),
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/retraite',
          color: AppColors.infos,
        ),
        LinkTile(
          icon: Icons.groups,
          title: tr('Cotisations syndicales', 'Union dues'),
          subtitle: tr('Montants par syndicat et métier',
              'Amounts by union and trade'),
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/salaire-taux/cotisations-syndicales',
          color: AppColors.infos,
        ),
        LinkTile(
          icon: Icons.badge,
          title: tr('Certificat de compétence', 'Competency certificate'),
          subtitle: tr('Carte, carnet et apprentissage',
              'Card, logbook and apprenticeship'),
          url: 'https://www.ccq.org/fr-CA/travailleurs',
          color: AppColors.infos,
        ),
        LinkTile(
          icon: Icons.school,
          title: 'ASP Construction',
          subtitle: tr('Cours de sécurité (30 h) et prévention',
              'Safety course (30 h) and prevention'),
          url: 'https://www.asp-construction.org',
          color: AppColors.infos,
        ),
        LinkTile(
          icon: Icons.apartment,
          title: 'Régie du bâtiment (RBQ)',
          subtitle: tr('Licences d\'entrepreneur', 'Contractor licences'),
          url: 'https://www.rbq.gouv.qc.ca',
          color: AppColors.infos,
        ),
        LinkTile(
          icon: Icons.emergency,
          title: tr('CNESST — santé et sécurité', 'CNESST — health and safety'),
          subtitle: tr('Prévention, droits, indemnisation',
              'Prevention, rights, compensation'),
          url: 'https://www.cnesst.gouv.qc.ca',
          color: AppColors.infos,
        ),
        const SizedBox(height: 8),
        for (final cat in _categories) ...[
          const SizedBox(height: 10),
          SectionTitle(tr(cat.titre, _catEn[cat.titre] ?? cat.titre),
              color: AppColors.infos),
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
    final ({String titre, String corps})? en =
        estAnglais ? _docEn[doc.titre] : null;
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
          title: Text(en?.titre ?? doc.titre,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(en?.corps ?? doc.corps,
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
