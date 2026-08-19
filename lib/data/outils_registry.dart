import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../screens/calculs_plus.dart';
import '../screens/charpente_screens.dart';
import '../screens/chantier_screens.dart';
import '../screens/conventions_screen.dart';
import '../screens/documentation_screen.dart';
import '../screens/feuille_temps_screen.dart';
import '../screens/infos_screens.dart';
import '../screens/materiaux_screens.dart';
import '../screens/medic_screen.dart';
import '../screens/outils_plus.dart';
import '../screens/paie_screens.dart';
import '../screens/rapport_screen.dart';
import '../screens/retraite_screen.dart';
import '../screens/sauvegarde_screen.dart';
import '../screens/securite_plus.dart';
import '../screens/syndicat_screen.dart';
import '../theme/app_theme.dart';

/// Un outil de l'app : identité, apparence et écran à ouvrir.
class Outil {
  const Outil(this.id, this.titre, this.sousTitre, this.icon, this.builder);
  final String id;
  final String titre;
  final String sousTitre;
  final IconData icon;
  final WidgetBuilder builder;
}

/// Une section de l'accueil (un groupe d'outils d'une même couleur).
class SectionOutils {
  const SectionOutils(this.titre, this.couleur, this.outils);
  final String titre;
  final Color couleur;
  final List<Outil> outils;
}

/// Toutes les sections et outils, dans l'ordre d'affichage de l'accueil.
final List<SectionOutils> sectionsOutils = [
  SectionOutils('Paie & salaire', AppColors.paie, [
    Outil('calculateur', 'Calculateur de paie', 'Brut, congés, net',
        Icons.paid, (_) => const CalculateurPaieScreen()),
    Outil('feuille-temps', 'Feuille de temps', 'Note et totalise tes heures',
        Icons.punch_clock, (_) => const FeuilleTempsScreen()),
    Outil('rapport-heures', 'Rapport d\'heures', 'Filtre + export CSV',
        Icons.summarize, (_) => const RapportHeuresScreen()),
    Outil('sauvegarde', 'Sauvegarde', 'Exporte et restaure tes heures',
        Icons.backup, (_) => const SauvegardeScreen()),
    Outil('comparateur', 'Comparateur de taux', 'Comparer 5 conventions',
        Icons.compare_arrows, (_) => const ComparateurScreen()),
    Outil('salaire-annuel', 'Salaire annuel', 'Salaire horaire vers annuel',
        Icons.event_repeat, (_) => const SalaireAnnuelScreen()),
    Outil('retraite', 'Retraite', 'Projette ton compte complémentaire',
        Icons.savings, (_) => const RetraiteScreen()),
    Outil('vacances', 'Vacances & congés', 'Indemnité ~13 %',
        Icons.beach_access, (_) => const VacancesScreen()),
    Outil('paie-nette', 'Paie nette', 'Estimation des retenues',
        Icons.account_balance_wallet, (_) => const PaieNetteScreen()),
    Outil('deplacement', 'Déplacement', 'Kilométrage et indemnité',
        Icons.directions_car, (_) => const DeplacementScreen()),
    Outil('rappel-retro', 'Rappel rétroactif', 'Paie de rappel (nouveau taux)',
        Icons.history, (_) => const RappelRetroScreen()),
  ]),
  SectionOutils('Calculs de chantier', AppColors.chantier, [
    Outil('convertisseur', 'Convertisseur', 'Impérial et métrique',
        Icons.straighten, (_) => const ConvertisseurScreen()),
    Outil('fractions', 'Fractions de pouce', 'Décimal et fractions',
        Icons.architecture, (_) => const FractionsScreen()),
    Outil('fractions-avancees', 'Fractions avancées', 'Additionner / soustraire',
        Icons.functions, (_) => const FractionsAvanceesScreen()),
    Outil('surface', 'Surface', 'Rectangle, triangle, cercle',
        Icons.crop_square, (_) => const SurfaceScreen()),
    Outil('aires', 'Aires complexes', 'Trapèze, forme en L',
        Icons.crop_free, (_) => const AiresScreen()),
    Outil('beton', 'Béton', 'Volume, verges cubes, sacs',
        Icons.foundation, (_) => const BetonScreen()),
    Outil('pente-tuyau', 'Pente de tuyau', 'Chute, drainage',
        Icons.trending_down, (_) => const PenteTuyauScreen()),
    Outil('echelle', 'Échelle 4:1', 'Recul sécuritaire',
        Icons.stairs, (_) => const EchelleScreen()),
  ]),
  SectionOutils('Matériaux & estimation', AppColors.materiaux, [
    Outil('peinture', 'Peinture', 'Litres et contenants',
        Icons.format_paint, (_) => const PeintureScreen()),
    Outil('briques', 'Briques & blocs', 'Nombre par surface',
        Icons.grid_view, (_) => const BriquesScreen()),
    Outil('isolation', 'Isolation (R)', 'Valeur R et épaisseur',
        Icons.ac_unit, (_) => const IsolationScreen()),
    Outil('cout', 'Coût matériaux', 'Quantité, prix et taxes',
        Icons.receipt_long, (_) => const CoutScreen()),
    Outil('bardeaux', 'Bardeaux', 'Toiture, paquets',
        Icons.roofing, (_) => const BardeauxScreen()),
    Outil('gravier', 'Gravier & remblai', 'Volume en tonnes',
        Icons.landscape, (_) => const GravierScreen()),
    Outil('ceramique', 'Céramique', 'Tuiles par surface',
        Icons.grid_on, (_) => const CeramiqueScreen()),
    Outil('scellant', 'Scellant', 'Tubes par longueur',
        Icons.water_drop, (_) => const ScellantScreen()),
    Outil('coffrage', 'Coffrage de mur', 'Feuilles et montants',
        Icons.foundation, (_) => const CoffrageScreen()),
    Outil('beton-avance', 'Béton avancé', 'Dalle, mur, colonne, semelle',
        Icons.view_in_ar, (_) => const BetonAvanceScreen()),
  ]),
  SectionOutils('Charpente & finition', AppColors.charpente, [
    Outil('pente-toit', 'Pente de toit', 'Montée/12, angle, %',
        Icons.roofing, (_) => const PenteToitScreen()),
    Outil('pente-conv', 'Convertisseur de pente', 'Pourcentage, x/12, degrés',
        Icons.show_chart, (_) => const PenteConvScreen()),
    Outil('escalier', 'Escalier', 'Contremarches et girons',
        Icons.stairs, (_) => const EscalierScreen()),
    Outil('equerre', 'Équerre 3-4-5', 'Vérifier un angle droit',
        Icons.square_foot, (_) => const EquerreScreen()),
    Outil('materiaux', 'Matériaux', 'Montants et feuilles 4x8',
        Icons.dashboard, (_) => const MateriauxScreen()),
    Outil('angles', 'Angles de coupe', 'Onglet, coins',
        Icons.content_cut, (_) => const AnglesScreen()),
    Outil('solives', 'Solives / poutrelles', 'Entraxe et quantité',
        Icons.view_week, (_) => const SolivesScreen()),
  ]),
  SectionOutils('Outils', AppColors.chantier, [
    Outil('calculatrice', 'Calculatrice', 'Les 4 opérations',
        Icons.calculate, (_) => const CalculatriceScreen()),
    Outil('convertisseur-avance', 'Convertisseur avancé',
        'Poids, temp., pression…', Icons.swap_horiz,
        (_) => const ConvertisseurAvanceScreen()),
    Outil('calculs-electriques', 'Calculs électriques',
        'Loi d\'Ohm, chute de tension', Icons.electric_bolt,
        (_) => const CalculsElectriquesScreen()),
    Outil('couple-serrage', 'Couple de serrage', 'N·m, lb·pi, lb·po, kgf·m',
        Icons.settings, (_) => const CoupleSerrageScreen()),
  ]),
  SectionOutils('Infos pour les gars', AppColors.infos, [
    Outil('taux', 'Taux par métier', 'Actuels + prochains taux',
        Icons.trending_up, (_) => const TauxMetiersScreen()),
    Outil('medic', 'MÉDIC Construction', 'Assurances et retraite',
        Icons.health_and_safety, (_) => const MedicScreen()),
    Outil('conventions', 'Conventions collectives', 'Hors ligne, par secteur',
        Icons.gavel, (_) => const ConventionsScreen()),
    Outil('securite', 'Santé-sécurité', 'Aide-mémoire chantier',
        Icons.shield, (_) => const SecuriteScreen()),
    Outil('simdut', 'SIMDUT 2015', 'Pictogrammes de danger',
        Icons.dangerous, (_) => const SimdutScreen()),
    Outil('lignes-electriques', 'Lignes électriques', 'Distances d\'approche',
        Icons.flash_on, (_) => const LignesElectriquesScreen()),
    Outil('feries', 'Jours fériés', 'Fériés payés et vacances',
        Icons.event, (_) => const FeriesScreen()),
    Outil('syndicats', 'Syndicats', 'Les 5 associations',
        Icons.groups, (_) => const SyndicatScreen()),
    Outil('numeros', 'Numéros utiles', 'CCQ, CNESST, urgence',
        Icons.phone, (_) => const ContactsScreen()),
    Outil('documentation', 'Documentation', 'Guides et infos',
        Icons.menu_book, (_) => const DocumentationScreen()),
  ]),
];

/// Liste plate de tous les outils (pour la recherche et les favoris).
final List<Outil> tousLesOutils = [
  for (final s in sectionsOutils) ...s.outils
];

/// Retrouve un outil par son identifiant (ou `null`).
Outil? outilParId(String id) {
  for (final o in tousLesOutils) {
    if (o.id == id) return o;
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────
//  Traductions anglaises (la coquille : sections + outils). Le contenu des
//  écrans se traduit progressivement avec `tr()`.
// ─────────────────────────────────────────────────────────────────────────
const Map<String, String> _sectionsEn = {
  'Favoris': 'Favorites',
  'Paie & salaire': 'Pay & wages',
  'Calculs de chantier': 'Site calculations',
  'Matériaux & estimation': 'Materials & estimating',
  'Charpente & finition': 'Framing & finishing',
  'Outils': 'Tools',
  'Infos pour les gars': 'Worker info',
};

/// (titre, sous-titre) anglais par identifiant d'outil.
const Map<String, (String, String)> _outilsEn = {
  'calculateur': ('Pay calculator', 'Gross, holiday pay, net'),
  'feuille-temps': ('Timesheet', 'Log and total your hours'),
  'rapport-heures': ('Hours report', 'Filter + CSV export'),
  'sauvegarde': ('Backup', 'Export and restore your hours'),
  'comparateur': ('Rate comparator', 'Compare 5 agreements'),
  'salaire-annuel': ('Annual salary', 'Hourly wage to yearly'),
  'retraite': ('Retirement', 'Project your complementary account'),
  'vacances': ('Vacation & holidays', 'Allowance ~13%'),
  'paie-nette': ('Net pay', 'Estimate deductions'),
  'deplacement': ('Travel', 'Mileage and allowance'),
  'rappel-retro': ('Retro pay', 'Back pay (new rate)'),
  'convertisseur': ('Converter', 'Imperial and metric'),
  'fractions': ('Inch fractions', 'Decimal and fractions'),
  'fractions-avancees': ('Advanced fractions', 'Add / subtract'),
  'surface': ('Area', 'Rectangle, triangle, circle'),
  'aires': ('Complex areas', 'Trapezoid, L-shape'),
  'beton': ('Concrete', 'Volume, cubic yards, bags'),
  'pente-tuyau': ('Pipe slope', 'Fall, drainage'),
  'echelle': ('Ladder 4:1', 'Safe setback'),
  'peinture': ('Paint', 'Litres and cans'),
  'briques': ('Bricks & blocks', 'Count per area'),
  'isolation': ('Insulation (R)', 'R-value and thickness'),
  'cout': ('Material cost', 'Quantity, price and taxes'),
  'bardeaux': ('Shingles', 'Roofing, bundles'),
  'gravier': ('Gravel & fill', 'Volume to tonnes'),
  'ceramique': ('Tile', 'Tiles per area'),
  'scellant': ('Sealant', 'Tubes per length'),
  'coffrage': ('Wall formwork', 'Sheets and studs'),
  'beton-avance': ('Advanced concrete', 'Slab, wall, column, footing'),
  'pente-toit': ('Roof pitch', 'Rise/12, angle, %'),
  'pente-conv': ('Slope converter', 'Percent, x/12, degrees'),
  'escalier': ('Stairs', 'Risers and treads'),
  'equerre': ('Square 3-4-5', 'Check a right angle'),
  'materiaux': ('Materials', 'Studs and 4x8 sheets'),
  'angles': ('Cut angles', 'Miter, corners'),
  'solives': ('Joists', 'Spacing and count'),
  'calculatrice': ('Calculator', 'The 4 operations'),
  'convertisseur-avance': ('Advanced converter', 'Weight, temp., pressure…'),
  'calculs-electriques': ('Electrical calc', 'Ohm\'s law, voltage drop'),
  'couple-serrage': ('Torque', 'N·m, lb·ft, lb·in, kgf·m'),
  'taux': ('Rates by trade', 'Current + upcoming rates'),
  'syndicats': ('Unions', 'The 5 associations'),
  'medic': ('MÉDIC Construction', 'Insurance and retirement'),
  'securite': ('Health & safety', 'Site cheat sheet'),
  'simdut': ('WHMIS 2015', 'Hazard pictograms'),
  'lignes-electriques': ('Power lines', 'Approach distances'),
  'conventions': ('Collective agreements', 'Offline, by sector'),
  'feries': ('Statutory holidays', 'Paid holidays and vacation'),
  'numeros': ('Useful numbers', 'CCQ, CNESST, emergency'),
  'documentation': ('Documentation', 'Guides and info'),
};

/// Titre d'un outil dans la langue active.
String outilTitre(Outil o) => tr(o.titre, _outilsEn[o.id]?.$1 ?? o.titre);

/// Sous-titre d'un outil dans la langue active.
String outilSousTitre(Outil o) => tr(o.sousTitre, _outilsEn[o.id]?.$2 ?? o.sousTitre);

/// Titre d'une section dans la langue active (à partir du titre français).
String sectionTitre(String fr) => tr(fr, _sectionsEn[fr] ?? fr);
