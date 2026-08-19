import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/link_tile.dart';

/// Traductions des libellés MÉDIC. Les données (montants) restent identiques;
/// seuls les libellés sont traduits — repli sur le français si absent.
const Map<String, String> _medicEn = {
  // Couvertures — titres
  'Assurance maladie & médicaments': 'Health & drug insurance',
  'Hospitalisation': 'Hospitalization',
  'Soins dentaires': 'Dental care',
  'Assurance vie': 'Life insurance',
  'Assurance salaire (invalidité)': 'Salary insurance (disability)',
  'Personnes à charge (famille)': 'Dependents (family)',
  'CONSTRUIRE en santé': 'CONSTRUIRE en santé',
  'Assurance aux retraités': 'Retiree insurance',
  // Couvertures — détails
  'Remboursement des médicaments et de soins de santé, selon ton régime '
          'de base (A, B, C ou D). C\'est la protection la plus utilisée au '
          'quotidien.':
      'Reimbursement of medication and health care, based on your basic '
          'plan (A, B, C or D). It\'s the most-used protection day to day.',
  'Couverture des frais liés à une hospitalisation (ex. chambre), selon '
          'les modalités de ton régime.':
      'Coverage of costs related to a hospital stay (e.g. room), based on '
          'your plan\'s terms.',
  'Remboursement de soins dentaires selon le niveau de ton régime. '
          'Vérifie ta couverture avant des traitements importants.':
      'Reimbursement of dental care based on your plan level. Check your '
          'coverage before major treatments.',
  'Prestation versée à tes proches en cas de décès. Le montant dépend de '
          'ton régime.':
      'Benefit paid to your loved ones in case of death. The amount depends '
          'on your plan.',
  'Revenu de remplacement si une maladie ou un accident (hors travail) '
          't\'empêche de travailler. Pour un accident du travail, c\'est plutôt '
          'la CNESST.':
      'Replacement income if an illness or accident (outside work) keeps '
          'you from working. For a work accident, it\'s the CNESST instead.',
  'Ton conjoint et tes enfants peuvent être couverts selon ton régime — '
          'une protection pour toute la famille.':
      'Your spouse and children can be covered based on your plan — '
          'protection for the whole family.',
  'Programme de promotion et de gestion de la santé inclus : accès à des '
          'services professionnels en santé physique ET mentale, ligne d\'aide '
          'confidentielle. Un bon réflexe quand ça va moins bien.':
      'Included health promotion and management program: access to '
          'professional physical AND mental health services, and a '
          'confidential help line. A good reflex when things go sideways.',
  'Si tu as accumulé au moins 21 000 heures au régime de retraite, tu peux '
          'garder une protection d\'assurance à la retraite, pour toi et tes '
          'personnes à charge.':
      'If you\'ve accumulated at least 21,000 hours in the pension plan, you '
          'can keep insurance protection in retirement, for you and your '
          'dependents.',
  // Sections — titres
  'Assurance maladie': 'Health insurance',
  'Assurance dentaire': 'Dental insurance',
  'Assurance vie et mutilation': 'Life & dismemberment insurance',
  // Sections — notes
  'Soins paramédicaux : maximums par visite. Régime D : paramédical non couvert.':
      'Paramedical care: maximums per visit. Plan D: paramedical not covered.',
  'Régime D / DO : aucune assurance dentaire.':
      'Plan D / DO: no dental insurance.',
  'Métiers : montants « moins de 65 ans » — réduits après 65 ans, cessent à 70 ans. Occupations : montant unique.':
      'Trades: « under 65 » amounts — reduced after 65, end at 70. Occupations: single amount.',
  'Selon les heures accumulées au régime de retraite (avant l\'invalidité). Payable au salarié seulement; régime D : aucune.':
      'Based on hours accumulated in the pension plan (before the disability). Payable to the employee only; plan D: none.',
  // Lignes — assurance maladie
  'Hospitalisation / jour': 'Hospitalization / day',
  'Médicaments remboursés': 'Drugs reimbursed',
  'Franchise médicaments': 'Drug deductible',
  'Plafond médicaments (100 %)': 'Drug ceiling (100%)',
  'Examen vue — salarié (24 m)': 'Eye exam — employee (24 mo)',
  'Examen vue — conjoint (24 m)': 'Eye exam — spouse (24 mo)',
  'Examen vue — enfant (12 m)': 'Eye exam — child (12 mo)',
  'Lunettes — salarié (24 m)': 'Glasses — employee (24 mo)',
  'Lunettes — conjoint (24 m)': 'Glasses — spouse (24 mo)',
  'Lunettes — enfant (24 m)': 'Glasses — child (24 mo)',
  'Lunettes sécurité (12 m)': 'Safety glasses (12 mo)',
  'Chirurgie vision — à vie': 'Vision surgery — lifetime',
  'Chiropraticien / visite': 'Chiropractor / visit',
  'Radiographies chiro': 'Chiro X-rays',
  'Physiothérapeute / visite': 'Physiotherapist / visit',
  'Acupuncteur / visite': 'Acupuncturist / visit',
  'Audiologiste / visite': 'Audiologist / visit',
  'Psychologue / visite': 'Psychologist / visit',
  'Orthophoniste / visite': 'Speech therapist / visit',
  'Podiatre / podologue': 'Podiatrist / chiropodist',
  'Travailleur social / visite': 'Social worker / visit',
  'Ostéopathe / visite': 'Osteopath / visit',
  'Naturopathe / visite': 'Naturopath / visit',
  'Massothérapeute / visite': 'Massage therapist / visit',
  'Paramédical — max/période': 'Paramedical — max/period',
  'Appareils auditifs (36 m)': 'Hearing aids (36 mo)',
  'Piles auditives (12 m)': 'Hearing aid batteries (12 mo)',
  'Labo — max/12 mois': 'Lab — max/12 months',
  'Rapports médicaux CCQ': 'CCQ medical reports',
  'Dentaire suite accident': 'Dental after accident',
  'Chirurgie plastique (accident)': 'Plastic surgery (accident)',
  'Orthèses/béquilles/CPAP': 'Orthoses/crutches/CPAP',
  'Transport ambulance': 'Ambulance transport',
  'Urgence à l\'étranger': 'Emergency abroad',
  'Construire — alcool/toxico/jeu': 'Construire — alcohol/drugs/gambling',
  'Construire — dépression': 'Construire — depression',
  'Aide aux travailleurs (h/an)': 'Worker assistance (h/yr)',
  // Lignes — assurance dentaire
  'Franchise / famille': 'Deductible / family',
  'Diagnostic, prévention, mineur': 'Diagnostic, prevention, minor',
  '  max / personne / période': '  max / person / period',
  'Parodontie, endodontie': 'Periodontics, endodontics',
  'Restaurations majeures': 'Major restorations',
  'Orthodontie (enfant)': 'Orthodontics (child)',
  '  ortho. max à vie / enfant': '  ortho. lifetime max / child',
  // Lignes — assurance vie et mutilation
  'Décès salarié (avec charge)': 'Employee death (with dependents)',
  'Décès salarié (sans charge)': 'Employee death (no dependents)',
  'Décès conjoint': 'Spouse death',
  'Décès enfant à charge': 'Dependent child death',
  'Décès accidentel (add.)': 'Accidental death (add.)',
  'Mutilation accidentelle (max)': 'Accidental dismemberment (max)',
  // Lignes — assurance salaire
  'Courte < 4 000 h /sem': 'Short-term < 4,000 h /wk',
  'Courte 4 000–6 000 h /sem': 'Short-term 4,000–6,000 h /wk',
  'Courte 6 000 h+ /sem': 'Short-term 6,000 h+ /wk',
  'Longue 6 000 h+ /mois': 'Long-term 6,000 h+ /mo',
};

/// Libellé MÉDIC traduit : anglais depuis la table, repli sur le français.
String _mtr(String fr) => tr(fr, _medicEn[fr] ?? fr);

// ── Période en vigueur + bulletins officiels ──────────────────────────────
// Les bulletins MÉDIC sont publiés deux fois par année (périodes janv.–juin et
// juill.–déc.). Les données reproduites ici viennent des bulletins de la
// période en cours. Le dossier « juillet » de ccq.org pointe le bulletin en
// vigueur pour cette période — c'est notre bouton « vérifier le dernier ».
const String _medicPeriodeFr =
    'En vigueur du 1er juillet au 31 décembre 2026';
const String _medicPeriodeEn = 'In effect July 1 to December 31, 2026';
const String _medicBulletinFr = 'Bulletins vol. 25 no 2 (juillet 2026)';
const String _medicBulletinEn = 'Bulletins vol. 25 no. 2 (July 2026)';

const String _urlBulletinMetiers =
    'https://www.ccq.org/-/media/Project/Ccq/Ccq-Website/PDF/AvantagesSociaux/BulletinMedic/juillet/110406-110385-PD5212.pdf';
const String _urlBulletinOccupations =
    'https://www.ccq.org/-/media/Project/Ccq/Ccq-Website/PDF/AvantagesSociaux/BulletinMedic/juillet/110412-PD5225.pdf';

// Numéros d'aide MÉDIC (vérifiés sur les sources officielles CCQ).
const String _telConstruireEnSante = '1 800 807-2433';
const String _telServiceClientCcq = '1 888 842-8282';

class _Couverture {
  const _Couverture(this.titre, this.icon, this.details);
  final String titre;
  final IconData icon;
  final String details;
}

const List<_Couverture> _couvertures = [
  _Couverture(
    'Assurance maladie & médicaments',
    Icons.medication,
    'Remboursement des médicaments et de soins de santé, selon ton régime '
        'de base (A, B, C ou D). C\'est la protection la plus utilisée au '
        'quotidien.',
  ),
  _Couverture(
    'Hospitalisation',
    Icons.local_hospital,
    'Couverture des frais liés à une hospitalisation (ex. chambre), selon '
        'les modalités de ton régime.',
  ),
  _Couverture(
    'Soins dentaires',
    Icons.medical_services,
    'Remboursement de soins dentaires selon le niveau de ton régime. '
        'Vérifie ta couverture avant des traitements importants.',
  ),
  _Couverture(
    'Assurance vie',
    Icons.favorite,
    'Prestation versée à tes proches en cas de décès. Le montant dépend de '
        'ton régime.',
  ),
  _Couverture(
    'Assurance salaire (invalidité)',
    Icons.healing,
    'Revenu de remplacement si une maladie ou un accident (hors travail) '
        't\'empêche de travailler. Pour un accident du travail, c\'est plutôt '
        'la CNESST.',
  ),
  _Couverture(
    'Personnes à charge (famille)',
    Icons.family_restroom,
    'Ton conjoint et tes enfants peuvent être couverts selon ton régime — '
        'une protection pour toute la famille.',
  ),
  _Couverture(
    'CONSTRUIRE en santé',
    Icons.self_improvement,
    'Programme de promotion et de gestion de la santé inclus : accès à des '
        'services professionnels en santé physique ET mentale, ligne d\'aide '
        'confidentielle. Un bon réflexe quand ça va moins bien.',
  ),
  _Couverture(
    'Assurance aux retraités',
    Icons.elderly,
    'Si tu as accumulé au moins 21 000 heures au régime de retraite, tu peux '
        'garder une protection d\'assurance à la retraite, pour toi et tes '
        'personnes à charge.',
  ),
];

/// Une ligne du tableau : une protection et ses 4 montants pour le régime
/// des métiers (A-D) et celui des occupations (AO-DO).
class _LigneRegime {
  const _LigneRegime(this.label, this.metiers, this.occup);
  final String label;
  final List<String> metiers; // A, B, C, D
  final List<String> occup; // AO, BO, CO, DO
}

/// Une section du bulletin (assurance maladie, dentaire, vie, salaire…).
class _SectionRegime {
  const _SectionRegime(this.titre, this.lignes, {this.note});
  final String titre;
  final List<_LigneRegime> lignes;
  final String? note;
}

/// Protections reproduites des bulletins d'information MÉDIC (vol. 25 no 2,
/// juillet 2026), période du 1er juillet au 31 décembre 2026 — régimes de
/// base des métiers (PD5212) et des occupations (PD5225). Classement et
/// contenu fidèles au bulletin (7 pages).
const List<_SectionRegime> _sectionsRegime = [
  _SectionRegime('Assurance maladie', [
    _LigneRegime('Hospitalisation / jour',
        ['75 \$', '75 \$', '75 \$', '75 \$'], ['75 \$', '75 \$', '75 \$', '75 \$']),
    _LigneRegime('Médicaments remboursés',
        ['85 %', '75 %', '70 %', '70 %'], ['95 %', '85 %', '75 %', '75 %']),
    _LigneRegime('Franchise médicaments',
        ['aucune', '20 \$', '30 \$', '40 \$'], ['aucune', 'aucune', 'aucune', 'aucune']),
    _LigneRegime('Plafond médicaments (100 %)',
        ['850 \$', '850 \$', '850 \$', '850 \$'], ['850 \$', '850 \$', '850 \$', '850 \$']),
    _LigneRegime('Examen vue — salarié (24 m)',
        ['70 \$', '70 \$', '70 \$', '70 \$'], ['70 \$', '70 \$', '70 \$', '70 \$']),
    _LigneRegime('Examen vue — conjoint (24 m)',
        ['70 \$', '70 \$', '70 \$', '0 \$'], ['70 \$', '70 \$', '70 \$', '0 \$']),
    _LigneRegime('Examen vue — enfant (12 m)',
        ['70 \$', '70 \$', '0 \$', '0 \$'], ['70 \$', '70 \$', '0 \$', '0 \$']),
    _LigneRegime('Lunettes — salarié (24 m)',
        ['300 \$', '200 \$', '100 \$', '0 \$'], ['750 \$', '500 \$', '200 \$', '175 \$']),
    _LigneRegime('Lunettes — conjoint (24 m)',
        ['300 \$', '200 \$', '100 \$', '0 \$'], ['625 \$', '400 \$', '125 \$', '0 \$']),
    _LigneRegime('Lunettes — enfant (24 m)',
        ['300 \$', '200 \$', '0 \$', '0 \$'], ['400 \$', '250 \$', '0 \$', '0 \$']),
    _LigneRegime('Lunettes sécurité (12 m)',
        ['250 \$', '250 \$', '250 \$', '250 \$'], ['250 \$', '250 \$', '250 \$', '250 \$']),
    _LigneRegime('Chirurgie vision — à vie',
        ['2 000 \$', '1 500 \$', '1 000 \$', '0 \$'], ['3 500 \$', '2 500 \$', '1 500 \$', '0 \$']),
    _LigneRegime('Chiropraticien / visite',
        ['35 \$', '27 \$', '24 \$', '0 \$'], ['60 \$', '50 \$', '25 \$', '0 \$']),
    _LigneRegime('Radiographies chiro',
        ['45 \$', '35 \$', '28 \$', '0 \$'], ['50 \$', '40 \$', '28 \$', '0 \$']),
    _LigneRegime('Physiothérapeute / visite',
        ['50 \$', '40 \$', '30 \$', '0 \$'], ['60 \$', '45 \$', '30 \$', '0 \$']),
    _LigneRegime('Acupuncteur / visite',
        ['45 \$', '35 \$', '27 \$', '0 \$'], ['50 \$', '40 \$', '27 \$', '0 \$']),
    _LigneRegime('Audiologiste / visite',
        ['55 \$', '45 \$', '40 \$', '0 \$'], ['60 \$', '50 \$', '40 \$', '0 \$']),
    _LigneRegime('Psychologue / visite',
        ['70 \$', '55 \$', '40 \$', '0 \$'], ['80 \$', '60 \$', '45 \$', '0 \$']),
    _LigneRegime('Orthophoniste / visite',
        ['70 \$', '55 \$', '40 \$', '0 \$'], ['75 \$', '60 \$', '45 \$', '0 \$']),
    _LigneRegime('Podiatre / podologue',
        ['50 \$', '40 \$', '40 \$', '0 \$'], ['70 \$', '55 \$', '40 \$', '0 \$']),
    _LigneRegime('Travailleur social / visite',
        ['65 \$', '55 \$', '40 \$', '0 \$'], ['70 \$', '60 \$', '45 \$', '0 \$']),
    _LigneRegime('Ostéopathe / visite',
        ['55 \$', '45 \$', '0 \$', '0 \$'], ['65 \$', '55 \$', '29 \$', '0 \$']),
    _LigneRegime('Naturopathe / visite',
        ['40 \$', '30 \$', '0 \$', '0 \$'], ['45 \$', '40 \$', '24 \$', '0 \$']),
    _LigneRegime('Massothérapeute / visite',
        ['45 \$', '35 \$', '0 \$', '0 \$'], ['50 \$', '40 \$', '0 \$', '0 \$']),
    _LigneRegime('Paramédical — max/période',
        ['1 000 \$', '700 \$', '460 \$', '0 \$'], ['1 150 \$', '900 \$', '500 \$', '0 \$']),
    _LigneRegime('Appareils auditifs (36 m)',
        ['500 \$', '500 \$', '500 \$', '500 \$'], ['1 200 \$', '1 200 \$', '1 000 \$', '500 \$']),
    _LigneRegime('Piles auditives (12 m)',
        ['50 \$', '50 \$', '50 \$', '50 \$'], ['50 \$', '50 \$', '50 \$', '50 \$']),
    _LigneRegime('Labo — max/12 mois',
        ['427,50 \$', '427,50 \$', '337,50 \$', '337,50 \$'],
        ['1 500 \$', '1 350 \$', '750 \$', '500 \$']),
    _LigneRegime('Rapports médicaux CCQ',
        ['27 \$', '27 \$', '27 \$', '27 \$'], ['30 \$', '30 \$', '30 \$', '30 \$']),
    _LigneRegime('Dentaire suite accident',
        ['90 %', '90 %', '90 %', '90 %'], ['100 %', '100 %', '100 %', '100 %']),
    _LigneRegime('Chirurgie plastique (accident)',
        ['90 %', '90 %', '90 %', '90 %'], ['100 %', '100 %', '100 %', '100 %']),
    _LigneRegime('Orthèses/béquilles/CPAP',
        ['90 %', '90 %', '90 %', '90 %'], ['100 %', '100 %', '100 %', '100 %']),
    _LigneRegime('Transport ambulance',
        ['90 %', '90 %', '90 %', '90 %'], ['100 %', '100 %', '100 %', '100 %']),
    _LigneRegime('Urgence à l\'étranger',
        ['100 %', '100 %', '100 %', 'aucun'], ['100 %', '100 %', '100 %', 'aucun']),
    _LigneRegime('Construire — alcool/toxico/jeu',
        ['2 500 \$', '2 500 \$', '2 500 \$', '2 500 \$'],
        ['6 500 \$', '5 000 \$', '2 500 \$', '2 500 \$']),
    _LigneRegime('Construire — dépression',
        ['2 500 \$', '2 500 \$', '2 500 \$', '2 500 \$'],
        ['5 000 \$', '5 000 \$', '2 500 \$', '2 500 \$']),
    _LigneRegime('Aide aux travailleurs (h/an)',
        ['12', '12', '8', '8'], ['24', '12', '8', '8']),
  ], note: 'Soins paramédicaux : maximums par visite. Régime D : paramédical non couvert.'),
  _SectionRegime('Assurance dentaire', [
    _LigneRegime('Franchise / famille',
        ['aucune', '20 \$', '45 \$', 'aucun'], ['aucune', 'aucune', '20 \$', 'aucun']),
    _LigneRegime('Diagnostic, prévention, mineur',
        ['90 %', '80 %', '60 %', 'aucun'], ['95 %', '85 %', '75 %', 'aucun']),
    _LigneRegime('  max / personne / période',
        ['600 \$', '600 \$', '600 \$', 'aucun'], ['600 \$', '600 \$', '600 \$', 'aucun']),
    _LigneRegime('Parodontie, endodontie',
        ['80 %', '70 %', '60 %', 'aucun'], ['90 %', '80 %', '75 %', 'aucun']),
    _LigneRegime('Restaurations majeures',
        ['70 %', '60 %', 'aucun', 'aucun'], ['90 %', '80 %', 'aucun', 'aucun']),
    _LigneRegime('Orthodontie (enfant)',
        ['60 %', '50 %', 'aucun', 'aucun'], ['90 %', '80 %', '70 %', 'aucun']),
    _LigneRegime('  ortho. max à vie / enfant',
        ['2 000 \$', '1 500 \$', 'aucun', 'aucun'], ['3 500 \$', '2 500 \$', '1 800 \$', 'aucun']),
  ], note: 'Régime D / DO : aucune assurance dentaire.'),
  _SectionRegime('Assurance vie et mutilation', [
    _LigneRegime('Décès salarié (avec charge)',
        ['25 000 \$', '20 000 \$', '15 000 \$', '10 000 \$'],
        ['65 000 \$', '50 000 \$', '50 000 \$', '50 000 \$']),
    _LigneRegime('Décès salarié (sans charge)',
        ['16 000 \$', '10 000 \$', '10 000 \$', '5 000 \$'],
        ['40 000 \$', '35 000 \$', '35 000 \$', '35 000 \$']),
    _LigneRegime('Décès conjoint',
        ['7 500 \$', '7 500 \$', '5 000 \$', '5 000 \$'],
        ['30 000 \$', '30 000 \$', '25 000 \$', '25 000 \$']),
    _LigneRegime('Décès enfant à charge',
        ['7 500 \$', '7 500 \$', '5 000 \$', '5 000 \$'],
        ['20 000 \$', '20 000 \$', '15 000 \$', '15 000 \$']),
    _LigneRegime('Décès accidentel (add.)',
        ['10 000 \$', '10 000 \$', '10 000 \$', '5 000 \$'],
        ['20 000 \$', '20 000 \$', '20 000 \$', '20 000 \$']),
    _LigneRegime('Mutilation accidentelle (max)',
        ['10 000 \$', '10 000 \$', '10 000 \$', '5 000 \$'],
        ['20 000 \$', '20 000 \$', '20 000 \$', '20 000 \$']),
  ], note: 'Métiers : montants « moins de 65 ans » — réduits après 65 ans, cessent à 70 ans. Occupations : montant unique.'),
  _SectionRegime('Assurance salaire (invalidité)', [
    _LigneRegime('Courte < 4 000 h /sem',
        ['380 \$', '380 \$', '380 \$', 'aucune'], ['550 \$', '455 \$', '380 \$', 'aucune']),
    _LigneRegime('Courte 4 000–6 000 h /sem',
        ['460 \$', '460 \$', '460 \$', 'aucune'], ['650 \$', '540 \$', '460 \$', 'aucune']),
    _LigneRegime('Courte 6 000 h+ /sem',
        ['515 \$', '515 \$', '515 \$', 'aucune'], ['770 \$', '610 \$', '515 \$', 'aucune']),
    _LigneRegime('Longue 6 000 h+ /mois',
        ['1 625 \$', '1 375 \$', '1 275 \$', 'aucune'], ['2 800 \$', '2 280 \$', '1 450 \$', 'aucune']),
  ], note: 'Selon les heures accumulées au régime de retraite (avant l\'invalidité). Payable au salarié seulement; régime D : aucune.'),
];

class MedicScreen extends StatelessWidget {
  const MedicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'MÉDIC Construction',
      children: [
        InfoBanner(
          text: tr(
              'MÉDIC Construction, c\'est le régime d\'assurance collectif des '
                  'travailleurs de la construction, géré par la CCQ. Il vient avec '
                  'ton travail dans l\'industrie — une protection santé, vie et '
                  'invalidité pour toi et ta famille.',
              'MÉDIC Construction is the group insurance plan for construction '
                  'workers, managed by the CCQ. It comes with your work in the '
                  'industry — health, life and disability protection for you and '
                  'your family.'),
          icon: Icons.health_and_safety,
          color: AppColors.medic,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.medic.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.medic.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_available, color: AppColors.medic),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr(_medicPeriodeFr, _medicPeriodeEn),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.medic)),
                    const SizedBox(height: 2),
                    Text(tr(_medicBulletinFr, _medicBulletinEn),
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionTitle(tr('Ce que ça couvre', 'What it covers'),
            color: AppColors.medic),
        ..._couvertures.map((c) => _CouvertureCard(couv: c)),
        const SizedBox(height: 10),
        SectionTitle(tr('Régimes et financement', 'Plans and funding'),
            color: AppColors.medic),
        InfoBanner(
          text: tr(
              'Il existe des régimes de base A, B, C et D : ton admissibilité '
                  'et ton niveau de protection dépendent des heures travaillées. '
                  'Le régime est financé par des cotisations versées pour chaque '
                  'heure travaillée (part de l\'employeur et du salarié), gérées '
                  'par la CCQ. Ton relevé mensuel en fait état.',
              'There are basic plans A, B, C and D: your eligibility and your '
                  'protection level depend on the hours you work. The plan is '
                  'funded by contributions paid for each hour worked (employer '
                  'and employee share), managed by the CCQ. Your monthly '
                  'statement shows it.'),
          icon: Icons.info_outline,
          color: AppColors.medic,
        ),
        const SizedBox(height: 16),
        SectionTitle(tr('Comparatif des protections', 'Protection comparison'),
            color: AppColors.medic),
        const SizedBox(height: 6),
        InfoBanner(
          text: tr(
              'Protections du 1er juillet au 31 décembre 2026, classées comme le '
                  'bulletin : maladie, dentaire, vie et mutilation, salaire. Bascule '
                  'entre le régime des métiers (A-D) et celui des occupations '
                  '(AO-DO). Ton régime dépend des heures de la période de référence '
                  '(6 mois) — minimum 300 h pour être assuré.',
              'Protections from July 1 to December 31, 2026, ordered like the '
                  'bulletin: health, dental, life & dismemberment, salary. Toggle '
                  'between the trades plan (A-D) and the occupations plan (AO-DO). '
                  'Your plan depends on the hours in the reference period '
                  '(6 months) — minimum 300 h to be insured.'),
          icon: Icons.table_chart,
          color: AppColors.medic,
        ),
        const SizedBox(height: 12),
        const _ComparatifRegimes(),
        const SizedBox(height: 8),
        InfoBanner(
          text: tr(
              'Source : Bulletins d\'information MÉDIC Construction, vol. 25 no 2 '
                  '(juillet 2026), CCQ — régimes de base des métiers (PD5212) et des '
                  'occupations (PD5225), 7 pages reproduites. Le régime de base '
                  'inclut l\'assurance dentaire (sauf régime D). Montants indicatifs; '
                  'seul le Règlement R-20, r. 10 a valeur officielle — ta couverture '
                  'réelle figure sur ton relevé.',
              'Source: MÉDIC Construction information bulletins, vol. 25 no. 2 '
                  '(July 2026), CCQ — basic plans for trades (PD5212) and '
                  'occupations (PD5225), 7 pages reproduced. The basic plan '
                  'includes dental insurance (except plan D). Amounts are '
                  'indicative; only Regulation R-20, r. 10 is official — your '
                  'actual coverage is on your statement.'),
        ),
        const SizedBox(height: 16),
        SectionTitle(
            tr('Vérifier le dernier bulletin', 'Check the latest bulletin'),
            color: AppColors.medic),
        const SizedBox(height: 6),
        InfoBanner(
          text: tr(
              'MÉDIC n\'a pas de mise à jour automatique comme les taux de '
                  'salaire. Ouvre le bulletin officiel de ton régime pour '
                  'confirmer les montants et voir s\'il y a une nouvelle version.',
              'MÉDIC has no automatic update like the wage rates. Open your '
                  'plan\'s official bulletin to confirm the amounts and check for '
                  'a newer version.'),
          icon: Icons.sync,
          color: AppColors.medic,
        ),
        const SizedBox(height: 8),
        LinkTile(
          icon: Icons.picture_as_pdf,
          title: tr('Bulletin — régime des métiers (A-D)',
              'Bulletin — trades plan (A-D)'),
          subtitle: tr('PDF officiel · PD5212 · ccq.org',
              'Official PDF · PD5212 · ccq.org'),
          url: _urlBulletinMetiers,
          color: AppColors.medic,
        ),
        LinkTile(
          icon: Icons.picture_as_pdf,
          title: tr('Bulletin — régime des occupations (AO-DO)',
              'Bulletin — occupations plan (AO-DO)'),
          subtitle: tr('PDF officiel · PD5225 · ccq.org',
              'Official PDF · PD5225 · ccq.org'),
          url: _urlBulletinOccupations,
          color: AppColors.medic,
        ),
        const SizedBox(height: 16),
        SectionTitle(tr('Besoin d\'aide ?', 'Need help?'),
            color: AppColors.medic),
        const SizedBox(height: 6),
        ToolListTile(
          icon: Icons.call,
          title: 'CONSTRUIRE en santé',
          subtitle:
              '$_telConstruireEnSante · ${tr('santé physique et mentale, confidentiel', 'physical & mental health, confidential')}',
          color: AppColors.medic,
          onTap: () => appelerNumero(context, _telConstruireEnSante),
        ),
        ToolListTile(
          icon: Icons.call,
          title: tr('Service à la clientèle CCQ', 'CCQ customer service'),
          subtitle:
              '$_telServiceClientCcq · ${tr('MÉDIC, réclamations', 'MÉDIC, claims')}',
          color: AppColors.medic,
          onTap: () => appelerNumero(context, _telServiceClientCcq),
        ),
        const SizedBox(height: 14),
        LinkTile(
          icon: Icons.open_in_browser,
          title: 'MÉDIC Construction (CCQ)',
          subtitle: tr('Détails des régimes, protections, réclamations',
              'Plan details, protections, claims'),
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/medic-construction',
          color: AppColors.medic,
        ),
        LinkTile(
          icon: Icons.elderly,
          title: tr('Assurance aux retraités', 'Retiree insurance'),
          subtitle: tr('Admissibilité (21 000 h) et protections',
              'Eligibility (21,000 h) and protections'),
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/medic-construction/assurances-retraites',
          color: AppColors.medic,
        ),
        const SizedBox(height: 8),
        InfoBanner(
          text: tr(
              'Infos générales de vulgarisation. Pour ta couverture exacte et '
                  'tes réclamations, réfère-toi à la CCQ (avantages sociaux) et à '
                  'ton relevé.',
              'General plain-language info. For your exact coverage and your '
                  'claims, refer to the CCQ (social benefits) and your '
                  'statement.'),
        ),
      ],
    );
  }
}

class _CouvertureCard extends StatelessWidget {
  const _CouvertureCard({required this.couv});
  final _Couverture couv;

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
              color: AppColors.medic.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(couv.icon, color: AppColors.medic, size: 22),
          ),
          title: Text(_mtr(couv.titre),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(_mtr(couv.details),
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

/// Tableau comparatif des régimes, avec bascule métiers (A-D) / occupations
/// (AO-DO). Le tableau défile horizontalement pour ne rien tronquer.
class _ComparatifRegimes extends StatefulWidget {
  const _ComparatifRegimes();

  @override
  State<_ComparatifRegimes> createState() => _ComparatifRegimesState();
}

class _ComparatifRegimesState extends State<_ComparatifRegimes> {
  bool _metiers = true;

  @override
  Widget build(BuildContext context) {
    final Color onSurf = Theme.of(context).colorScheme.onSurface;
    final List<String> cols =
        _metiers ? const ['A', 'B', 'C', 'D'] : const ['AO', 'BO', 'CO', 'DO'];

    Widget entete(String t) => Text(t,
        style: const TextStyle(
            fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.medic));

    Widget valeur(String v) {
      final bool nul = v == '0 \$' || v == 'aucun';
      final String disp =
          estAnglais && (v == 'aucun' || v == 'aucune') ? 'none' : v;
      return Text(disp,
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: nul ? FontWeight.w400 : FontWeight.w600,
              color: nul ? onSurf.withValues(alpha: 0.4) : onSurf));
    }

    Widget section(_SectionRegime s) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 15,
                  decoration: BoxDecoration(
                    color: AppColors.medic,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(_mtr(s.titre),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                horizontalMargin: 14,
                headingRowHeight: 40,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 46,
                headingRowColor: WidgetStatePropertyAll(
                    AppColors.medic.withValues(alpha: 0.10)),
                columns: [
                  DataColumn(
                      label: Text(tr('Protection', 'Coverage'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 13))),
                  for (final c in cols) DataColumn(label: entete(c)),
                ],
                rows: s.lignes.map((r) {
                  final List<String> vals = _metiers ? r.metiers : r.occup;
                  return DataRow(cells: [
                    DataCell(SizedBox(
                      width: 150,
                      child: Text(_mtr(r.label),
                          style: TextStyle(
                              fontSize: 12.5,
                              color: onSurf.withValues(alpha: 0.85))),
                    )),
                    for (final v in vals) DataCell(valeur(v)),
                  ]);
                }).toList(),
              ),
            ),
          ),
          if (s.note != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(_mtr(s.note!),
                  style: TextStyle(
                      fontSize: 11.5,
                      height: 1.3,
                      fontStyle: FontStyle.italic,
                      color: onSurf.withValues(alpha: 0.55))),
            ),
        ],
      );
    }

    final String metiersLabel = tr('Métiers', 'Trades');
    final String occupLabel = tr('Occupations', 'Occupations');
    return Column(
      children: [
        ChoiceSegments(
          options: [metiersLabel, occupLabel],
          selected: _metiers ? metiersLabel : occupLabel,
          onChanged: (v) => setState(() => _metiers = v == metiersLabel),
        ),
        const SizedBox(height: 12),
        for (final s in _sectionsRegime) ...[
          section(s),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}
