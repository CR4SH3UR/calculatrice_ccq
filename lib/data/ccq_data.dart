import 'package:flutter/material.dart';

import '../l10n/lang.dart';

/// Les grilles de taux de l'industrie de la construction au Québec.
///
/// La construction compte 4 secteurs (chacun sa convention collective).
/// Le secteur résidentiel se divise en « léger » et « lourd » (annexes R
/// et R-1), qui ont des taux distincts — d'où 5 grilles sélectionnables.
///
/// Constat des conventions 2025-2029 (en vigueur le 26 avril 2026) :
///  • Institutionnel-commercial et Industriel partagent les annexes B/C
///    (mêmes taux de salaire de base).
///  • Génie civil et voirie : taux « arrimés » avec l'I.C. depuis le
///    26 avril 2026 (secteur avec ses propres horaires jour/nuit et primes).
enum Secteur {
  residentielLeger('Résidentiel léger', 'Light residential', 'Rés. léger',
      'Res. light', null, null),
  residentielLourd('Résidentiel lourd', 'Heavy residential', 'Rés. lourd',
      'Res. heavy', null, null),
  institutionnelCommercial('Institutionnel-commercial',
      'Institutional-commercial', 'I.C.', 'I.C.', null, null),
  industriel('Industriel', 'Industrial', 'Ind.', 'Ind.',
      'Taux de salaire harmonisés avec l\'I.C.',
      'Wage rates harmonized with I.C.'),
  genieCivilVoirie('Génie civil et voirie', 'Civil engineering and roads',
      'G.C.V.', 'C.E.R.',
      'Le secteur a ses propres taux, horaires jour/nuit et primes. Taux de jour affichés.',
      'This sector has its own rates, day/night schedules and premiums. Day rates shown.');

  const Secteur(
      this.nomFr, this.nomEn, this.courtFr, this.courtEn, this.noteFr, this.noteEn);
  final String nomFr, nomEn, courtFr, courtEn;
  final String? noteFr, noteEn;

  String get nom => tr(nomFr, nomEn);
  String get court => tr(courtFr, courtEn);
  String? get note => noteFr == null ? null : tr(noteFr!, noteEn!);
}

/// Une hausse de salaire programmée par la convention (date + %).
class Hausse {
  const Hausse(this.annee, this.mois, this.jour, this.pct);
  final int annee;
  final int mois;
  final int jour;
  final double pct;
  DateTime get date => DateTime(annee, mois, jour);
}

/// Données de référence CCQ (Commission de la construction du Québec).
///
/// Taux de COMPAGNON en vigueur le 26 avril 2026, transcrits des grilles
/// officielles (ACQ pour résidentiel/I.C./industriel ; ACRGTQ pour le
/// génie civil). Les apprentis sont un pourcentage du taux de compagnon.
/// ⚠️ Toujours valider les chiffres officiels sur ccq.org/salaire — en cas
/// d'écart, les conventions collectives ont préséance.
class CcqData {
  const CcqData._();

  static const String siteWeb = 'ccq.org/salaire';
  static final DateTime enVigueurDepuis = DateTime(2026, 4, 26);
  static String get enVigueurTexte =>
      tr('En vigueur le 26 avril 2026', 'In effect April 26, 2026');
  static String get source => tr(
      'Taux tirés de l\'API officielle de la CCQ · à valider sur ccq.org/salaire',
      'Rates from the CCQ\'s official API · verify on ccq.org/salaire');

  /// Indemnité de congés annuels et de jours fériés : 13,0 % du salaire brut
  /// (confirmé par les grilles des conventions I.C./industriel).
  static const double indemniteCongesPct = 13.0;

  /// Hausses à venir par grille (conventions 2025-2029). La hausse d'avril
  /// 2026 est déjà incluse dans les taux de base ci-dessous.
  static final Map<Secteur, List<Hausse>> haussesAVenir = {
    Secteur.residentielLeger: const [
      Hausse(2027, 4, 25, 5.5),
      Hausse(2028, 4, 30, 4.5),
    ],
    Secteur.residentielLourd: const [
      Hausse(2027, 4, 25, 5.0),
      Hausse(2028, 4, 30, 4.0),
    ],
    Secteur.institutionnelCommercial: const [
      Hausse(2027, 4, 25, 5.0),
      Hausse(2028, 4, 30, 4.0),
    ],
    Secteur.industriel: const [
      Hausse(2027, 4, 25, 5.0),
      Hausse(2028, 4, 30, 4.0),
    ],
    Secteur.genieCivilVoirie: const [
      Hausse(2027, 4, 25, 5.0),
      Hausse(2028, 4, 30, 4.0),
    ],
  };

  /// Construit un métier avec ses taux de compagnon par grille : rl = rés.
  /// léger, rlo = rés. lourd, ic = institutionnel-commercial, ind =
  /// industriel, gcv = génie civil et voirie.
  static Metier _m(int code, String nom, IconData icon, List<int> pct,
          double rl, double rlo, double ic, double ind, double gcv,
          {String comp = 'Compagnon'}) =>
      Metier(nom, icon, pct, {
        Secteur.residentielLeger: rl,
        Secteur.residentielLourd: rlo,
        Secteur.institutionnelCommercial: ic,
        Secteur.industriel: ind,
        Secteur.genieCivilVoirie: gcv,
      }, libelleCompagnon: comp, code: code);

  /// Taux de compagnon en vigueur le 26 avril 2026, tirés de l'API officielle
  /// de la CCQ (/api/wagerates/Rates) : annexe « règle générale, travail de
  /// jour » pour I.C./industriel/G.C.V. ; annexes R (léger) et R-1 (lourd)
  /// pour le résidentiel. Les apprentis sont au % réel de la grille.
  /// Le code de l'occupation CCQ est indiqué en commentaire.
  static final List<Metier> metiers = [
    _m(617, 'Boutefeu', Icons.local_fire_department, [], 40.08, 42.05, 48.68, 48.68, 48.68, comp: 'Taux'),
    _m(622, 'Boutefeu classe 2', Icons.local_fire_department, [], 41.38, 41.38, 41.38, 41.38, 41.38, comp: 'Taux'),
    _m(110, 'Briqueteur-maçon', Icons.grid_view, [60, 70, 85], 46.59, 49.22, 49.57, 49.57, 50.18),
    _m(130, 'Calorifugeur', Icons.ac_unit, [60, 70, 85], 47.85, 50.20, 50.79, 50.79, 50.84),
    _m(140, 'Carreleur', Icons.dashboard, [60, 70, 85], 46.59, 49.69, 50.12, 50.12, 50.18),
    _m(160, 'Charpentier-menuisier', Icons.carpenter, [60, 70, 85], 45.76, 49.61, 50.16, 50.16, 50.24),
    _m(190, 'Chaudronnier', Icons.propane_tank, [60, 70, 85], 47.85, 50.20, 50.79, 50.79, 50.79),
    _m(626, 'Chauffeur de chaudière classe IV', Icons.local_fire_department, [], 36.21, 36.21, 36.21, 36.21, 39.11, comp: 'Taux'),
    _m(625, 'Chauffeur de chaudière à vapeur', Icons.local_fire_department, [], 40.78, 40.78, 40.78, 40.78, 42.92, comp: 'Taux'),
    _m(200, 'Cimentier-applicateur', Icons.foundation, [70, 85], 45.27, 48.27, 48.55, 48.55, 49.15),
    _m(500, 'Coffrage à béton (Charp-men)', Icons.foundation, [60, 70, 85], 45.76, 49.61, 50.16, 50.16, 50.24),
    _m(629, 'Commis', Icons.inventory_2, [], 36.98, 38.78, 27.78, 27.78, 29.33, comp: 'Taux'),
    _m(643, 'Conducteur de camions classe A', Icons.local_shipping, [], 38.73, 41.95, 41.67, 41.67, 42.23, comp: 'Taux'),
    _m(642, 'Conducteur de camions classe AA', Icons.local_shipping, [], 43.23, 43.23, 43.23, 43.23, 43.38, comp: 'Taux'),
    _m(644, 'Conducteur de camions classe B', Icons.local_shipping, [], 37.67, 40.88, 40.94, 40.94, 41.13, comp: 'Taux'),
    _m(645, 'Conducteur de camions classe C', Icons.local_shipping, [], 37.25, 40.38, 40.41, 40.41, 40.61, comp: 'Taux'),
    _m(210, 'Couvreur', Icons.roofing, [70, 85], 47.85, 50.20, 51.20, 51.20, 51.74),
    _m(230, 'Ferblantier', Icons.hvac, [60, 70, 85], 47.85, 50.20, 50.79, 50.79, 51.26),
    _m(240, 'Ferrailleur', Icons.iron, [85], 46.85, 50.67, 51.31, 51.31, 51.32),
    _m(697, 'Foreur', Icons.handyman, [], 41.39, 43.45, 48.68, 48.68, 48.68, comp: 'Taux'),
    _m(696, 'Foreur classe 2', Icons.handyman, [], 41.38, 41.38, 41.38, 41.38, 41.38, comp: 'Taux'),
    _m(418, 'Frigoriste', Icons.severe_cold, [50, 60, 70, 85], 47.85, 50.20, 50.79, 50.79, 50.87),
    _m(701, 'Gardien', Icons.shield, [], 36.98, 38.78, 20.75, 20.75, 25.83, comp: 'Taux'),
    _m(264, 'Grutier - classe A - 1er homme', Icons.precision_manufacturing, [70, 85], 45.93, 50.20, 50.79, 50.79, 50.87),
    _m(266, 'Grutier - classe A - 2e homme', Icons.precision_manufacturing, [70, 85], 50.79, 50.79, 50.79, 50.79, 50.87),
    _m(268, 'Grutier - classe B', Icons.precision_manufacturing, [70, 85], 44.50, 48.17, 48.58, 48.58, 48.86),
    _m(265, 'Grutier-classe A-1er homme (viaduc)', Icons.precision_manufacturing, [], 51.74, 51.74, 51.74, 51.74, 51.74),
    _m(267, 'Grutier-classe A-2e homme (viaduc)', Icons.precision_manufacturing, [], 51.74, 51.74, 51.74, 51.74, 51.74),
    _m(269, 'Grutier-classe B (viaduc)', Icons.precision_manufacturing, [], 49.71, 49.71, 49.71, 49.71, 49.71),
    _m(779, 'Homme service sur machinerie lourde', Icons.construction, [], 38.01, 39.84, 39.44, 39.44, 42.08, comp: 'Taux'),
    _m(273, 'Inst plateformes élév (mécan d\'asc)', Icons.construction, [50, 60, 70, 85, 85], 52.95, 55.63, 56.70, 56.70, 56.70),
    _m(275, 'Inst plateformes élév (mécan d\'asc)', Icons.construction, [50, 60, 70, 85, 85], 52.95, 55.63, 56.70, 56.70, 56.70),
    _m(222, 'Inst. de systèmes de sécurité', Icons.view_quilt, [60, 70, 85], 38.52, 40.88, 41.66, 41.66, 41.80),
    _m(311, 'Inst. miroir, montres-comptoirs', Icons.construction, [60, 70, 85], 45.07, 49.34, 49.60, 49.60, 50.22),
    _m(352, 'Jointoyeur (Peintre)', Icons.format_paint, [60, 70, 85], 44.29, 47.23, 47.51, 47.51, 47.62),
    _m(372, 'Jointoyeur (Plâtrier)', Icons.texture, [60, 70, 85], 44.29, 47.23, 47.39, 47.39, 47.73),
    _m(711, 'Magasinier', Icons.inventory_2, [], 33.09, 33.09, 33.09, 33.09, 36.24, comp: 'Taux'),
    _m(713, 'Manoeuvre', Icons.engineering, [], 36.98, 38.78, 40.19, 40.19, 41.02, comp: 'Taux'),
    _m(621, 'Manoeuvre (entr. & nett.)', Icons.engineering, [], 36.98, 38.78, 40.19, 40.19, 41.02, comp: 'Taux'),
    _m(607, 'Manoeuvre (travaux de couverture)', Icons.engineering, [], 40.45, 40.45, 40.45, 40.45, 41.49, comp: 'Taux'),
    _m(610, 'Manoeuvre canalisation souterraine', Icons.engineering, [], 38.73, 39.84, 40.83, 40.83, 42.08, comp: 'Taux'),
    _m(601, 'Manoeuvre en décontamination', Icons.engineering, [], 45.22, 45.22, 45.22, 45.22, 44.78, comp: 'Taux'),
    _m(609, 'Manoeuvre en maçonnerie', Icons.grid_view, [], 38.01, 39.84, 41.91, 41.91, 42.07, comp: 'Taux'),
    _m(614, 'Manoeuvre en échafaudage', Icons.engineering, [], 38.01, 39.84, 40.83, 40.83, 42.08, comp: 'Taux'),
    _m(612, 'Manoeuvre nettoyage conduits d\'air', Icons.engineering, [], 36.98, 38.79, 40.19, 40.19, 41.02, comp: 'Taux'),
    _m(781, 'Manoeuvre pipeline', Icons.engineering, [], 40.83, 40.83, 40.83, 40.83, 42.14, comp: 'Taux'),
    _m(611, 'Manoeuvre sciage béton et asphalte', Icons.foundation, [], 38.01, 39.84, 40.83, 40.83, 42.08, comp: 'Taux'),
    _m(608, 'Manoeuvre spéc.(trav. couverture)', Icons.engineering, [], 41.09, 41.09, 41.09, 41.09, 42.27, comp: 'Taux'),
    _m(719, 'Manoeuvre spécialisé', Icons.engineering, [], 38.01, 39.84, 40.83, 40.83, 42.08, comp: 'Taux'),
    _m(715, 'Manoeuvre spécialisé carreleur', Icons.dashboard, [], 38.73, 40.68, 42.04, 42.04, 42.64, comp: 'Taux'),
    _m(855, 'Manœuvre (aqueduc et égouts) 1er poseur', Icons.engineering, [], 48.73, 48.73, 48.73, 48.73, 48.73, comp: 'Taux'),
    _m(856, 'Manœuvre (aqueduc et égouts) 1er poseur (classe 2)', Icons.engineering, [], 41.42, 41.42, 41.42, 41.42, 41.42, comp: 'Taux'),
    _m(857, 'Manœuvre (aqueduc et égouts) 2ème poseur', Icons.engineering, [], 45.63, 45.63, 45.63, 45.63, 45.63, comp: 'Taux'),
    _m(858, 'Manœuvre (aqueduc et égouts) 2ème poseur (classe 2)', Icons.engineering, [], 38.79, 38.79, 38.79, 38.79, 38.79, comp: 'Taux'),
    _m(867, 'Manœuvre à la préparation (top man)', Icons.engineering, [], 45.63, 45.63, 45.63, 45.63, 45.63, comp: 'Taux'),
    _m(868, 'Manœuvre à la préparation (top man)  (classe 2)', Icons.engineering, [], 38.79, 38.79, 38.79, 38.79, 38.79, comp: 'Taux'),
    _m(304, 'Monteur-assembleur', Icons.warehouse, [60, 70, 85], 47.85, 50.67, 51.31, 51.31, 51.32),
    _m(310, 'Monteur-mécanicien (vitrier)', Icons.warehouse, [60, 70, 85], 45.07, 49.34, 49.60, 49.60, 50.22),
    _m(312, 'Monteur-mécanique porte et fenêtre', Icons.warehouse, [60, 70, 85], 45.07, 49.34, 49.60, 49.60, 50.22),
    _m(272, 'Mécanicien d\'ascenseur', Icons.elevator, [50, 60, 70, 85, 85], 52.95, 55.63, 56.70, 56.70, 56.70),
    _m(274, 'Mécanicien d\'ascenseur', Icons.elevator, [50, 60, 70, 85, 85], 52.95, 55.63, 56.70, 56.70, 56.70),
    _m(280, 'Mécanicien de chantier', Icons.build, [60, 70, 85], 47.85, 50.20, 50.79, 50.79, 50.87),
    _m(290, 'Mécanicien de machines lourdes', Icons.build, [60, 70, 85], 46.33, 48.59, 48.94, 48.94, 49.95),
    _m(416, 'Mécanicien en protection-incendie', Icons.local_fire_department, [50, 60, 70, 85], 47.85, 50.20, 50.79, 50.79, 50.87),
    _m(257, 'Op. pompe béton mât dist. -42m', Icons.foundation, [85, 85], 42.04, 45.36, 45.89, 45.89, 46.03),
    _m(255, 'Op. pompe béton mât dist. 42m +', Icons.foundation, [85, 85], 44.47, 47.78, 47.89, 47.89, 48.46),
    _m(253, 'Op. pompe béton mât dist. 50m +', Icons.foundation, [85, 85], 44.47, 47.78, 48.89, 48.89, 48.46),
    _m(259, 'Op. pompe béton mât dist. 58m +', Icons.foundation, [85, 85], 44.47, 47.78, 50.89, 50.89, 48.46),
    _m(723, 'Opér. appareils levage - classe A', Icons.precision_manufacturing, [], 42.32, 44.41, 44.38, 44.38, 45.74, comp: 'Taux'),
    _m(724, 'Opér. appareils levage - classe B', Icons.precision_manufacturing, [], 40.74, 42.77, 42.54, 42.54, 44.10, comp: 'Taux'),
    _m(348, 'Opér. pelles mécaniques - classe A', Icons.construction, [85], 45.93, 49.51, 49.92, 49.92, 49.51),
    _m(347, 'Opér. pelles mécaniques - classe AA', Icons.construction, [85], 51.51, 51.51, 51.51, 51.51, 50.91),
    _m(349, 'Opér. pelles mécaniques - classe B', Icons.construction, [85], 44.50, 48.05, 48.32, 48.32, 48.03),
    _m(749, 'Opérateur d\'usine fixe ou mobile', Icons.agriculture, [], 38.01, 43.45, 43.28, 43.28, 44.77, comp: 'Taux'),
    _m(324, 'Opérateur d\'épandeuses', Icons.agriculture, [85], 43.08, 46.53, 46.69, 46.69, 46.58),
    _m(745, 'Opérateur de génératrice', Icons.agriculture, [], 41.70, 41.70, 41.70, 41.70, 42.83, comp: 'Taux'),
    _m(326, 'Opérateur de niveleuses', Icons.agriculture, [85], 43.08, 46.53, 46.69, 46.69, 46.58),
    _m(747, 'Opérateur de pompe et compresseur', Icons.agriculture, [], 41.39, 43.45, 42.86, 42.86, 45.22, comp: 'Taux'),
    _m(336, 'Opérateur de rouleaux - classe A', Icons.agriculture, [85], 43.08, 46.53, 46.69, 46.69, 46.58),
    _m(337, 'Opérateur de rouleaux - classe B', Icons.agriculture, [85], 42.06, 45.45, 45.49, 45.49, 45.53),
    _m(331, 'Opérateur de rétrocaveuses classe A', Icons.agriculture, [85], 43.08, 46.53, 46.69, 46.69, 46.58),
    _m(338, 'Opérateur de tracteurs - classe A', Icons.agriculture, [85], 43.08, 46.53, 46.69, 46.69, 46.58),
    _m(339, 'Opérateur de tracteurs - classe B', Icons.agriculture, [85], 42.06, 45.45, 45.49, 45.49, 45.53),
    _m(538, 'Opérateur de tracteurs classe AA', Icons.agriculture, [85], 48.23, 48.23, 48.23, 48.23, 48.03),
    _m(296, 'Opérateur pompe à béton 63m', Icons.foundation, [85, 85], 54.28, 54.28, 54.28, 54.28, 48.46),
    _m(174, 'Parqueteur-sableur (menuisier)', Icons.carpenter, [60, 70, 85], 45.76, 49.61, 50.16, 50.16, 50.24),
    _m(350, 'Peintre', Icons.format_paint, [60, 70, 85], 42.81, 46.99, 47.39, 47.39, 47.89),
    _m(412, 'Plombier (Tuyauteur)', Icons.plumbing, [50, 60, 70, 85], 47.85, 50.20, 50.79, 50.79, 50.87),
    _m(370, 'Plâtrier', Icons.texture, [60, 70, 85], 44.98, 48.05, 48.26, 48.26, 48.47),
    _m(168, 'Pose de fondations profondes', Icons.construction, [60, 70, 85], 45.76, 49.61, 50.16, 50.16, 50.24),
    _m(414, 'Poseur d\'appareils de chauffage', Icons.construction, [50, 60, 70, 85], 47.85, 50.20, 50.79, 50.79, 50.87),
    _m(313, 'Poseur de portes de garage', Icons.construction, [60, 70, 85], 45.07, 49.34, 49.60, 49.60, 50.22),
    _m(390, 'Poseur de revêtements souples', Icons.layers, [60, 70, 85], 41.71, 44.25, 49.07, 49.07, 49.07),
    _m(380, 'Poseur de systèmes intérieurs', Icons.view_quilt, [60, 70, 85], 45.76, 49.61, 50.16, 50.16, 50.28),
    _m(775, 'Préposé aux instruments d\'arpentage', Icons.straighten, [], 42.65, 44.48, 50.07, 50.07, 50.07, comp: 'Taux'),
    _m(778, 'Préposé aux instruments d’arpentage classe 2', Icons.straighten, [], 42.56, 42.56, 42.56, 42.56, 42.56, comp: 'Taux'),
    _m(785, 'Préposé aux pneus et au débosselage', Icons.tire_repair, [], 38.01, 38.78, 44.47, 44.47, 46.70, comp: 'Taux'),
    _m(896, 'Préposé à l’ajustement de la table d’épandeuse (homme de vis)', Icons.construction, [], 46.58, 46.58, 46.58, 46.58, 46.58, comp: 'Taux'),
    _m(897, 'Préposé à l’ajustement de la table d’épandeuse (homme de vis) (classe 2)', Icons.construction, [], 39.59, 39.59, 39.59, 39.59, 39.59, comp: 'Taux'),
    _m(753, 'Rateleur d\'asphalte', Icons.construction, [], 42.08, 42.08, 42.08, 42.08, 42.08, comp: 'Taux'),
    _m(751, 'Scaphandrier (plongeur prof)', Icons.scuba_diving, [], 48.96, 51.86, 53.18, 53.18, 53.18, comp: 'Taux'),
    _m(752, 'Scaphandrier (plongeur prof) CL2', Icons.scuba_diving, [], 45.20, 45.20, 45.20, 45.20, 45.20, comp: 'Taux'),
    _m(761, 'Soudeur', Icons.local_fire_department, [], 45.35, 47.56, 47.40, 47.40, 49.38, comp: 'Taux'),
    _m(769, 'Soudeur chaudronnier', Icons.local_fire_department, [], 47.85, 50.20, 50.79, 50.79, 50.87, comp: 'Taux'),
    _m(771, 'Soudeur de distribution', Icons.local_fire_department, [], 47.85, 50.20, 50.79, 50.79, 50.87, comp: 'Taux'),
    _m(763, 'Soudeur de machinerie lourde', Icons.local_fire_department, [], 45.35, 47.56, 48.94, 48.94, 49.95, comp: 'Taux'),
    _m(767, 'Soudeur de pipeline', Icons.local_fire_department, [], 47.85, 50.20, 50.79, 50.79, 50.87, comp: 'Taux'),
    _m(765, 'Soudeur en tuyauterie', Icons.plumbing, [], 47.85, 50.20, 50.79, 50.79, 50.87, comp: 'Taux'),
    _m(773, 'Soudeur monteur-assembleur', Icons.local_fire_department, [], 47.85, 50.20, 51.31, 51.31, 51.32, comp: 'Taux'),
    _m(787, 'Spéc. branchement immeuble(gaz fit)', Icons.construction, [], 47.85, 50.20, 50.33, 50.33, 50.42, comp: 'Taux'),
    _m(783, 'Travailleur souterrain (mineur)', Icons.terrain, [], 42.21, 44.34, 46.10, 46.10, 46.10, comp: 'Taux'),
    _m(220, 'Électricien', Icons.electric_bolt, [50, 60, 70, 85], 47.85, 50.20, 50.79, 50.79, 50.87),
  ];

  // ── Moteur de taux daté ──────────────────────────────────────────────

  /// Surcharges de taux récupérées en direct de l'API (clé « code|secteur »).
  /// Un taux live remplace la valeur intégrée pour ce métier et cette grille.
  static final Map<String, double> _tauxLive = {};

  static String _cle(int code, Secteur s) => '$code|${s.name}';

  /// Enregistre un taux de compagnon récupéré en direct pour (métier, grille).
  static void appliquerTauxLive(Metier m, Secteur s, double taux) {
    if (m.code != null) _tauxLive[_cle(m.code!, s)] = taux;
  }

  /// Vrai si un taux live a été enregistré pour ce (métier, grille).
  static bool aTauxLive(Metier m, Secteur s) =>
      m.code != null && _tauxLive.containsKey(_cle(m.code!, s));

  /// Taux de compagnon de base : live si disponible, sinon valeur intégrée.
  static double baseCompagnonOf(Metier m, Secteur s) {
    if (m.code != null) {
      final double? live = _tauxLive[_cle(m.code!, s)];
      if (live != null) return live;
    }
    return m.baseCompagnon(s);
  }

  /// Taux de compagnon à une date donnée (applique les hausses échues).
  static double tauxCompagnon(Metier m, Secteur s, {DateTime? on}) {
    final DateTime d = on ?? DateTime.now();
    double r = baseCompagnonOf(m, s);
    for (final h in haussesAVenir[s] ?? const <Hausse>[]) {
      if (!d.isBefore(h.date)) r *= 1 + h.pct / 100;
    }
    return r;
  }

  /// Taux d'un palier (apprenti ou compagnon) à une date donnée.
  static double taux(Metier m, Secteur s, int pourcentage, {DateTime? on}) {
    return tauxCompagnon(m, s, on: on) * pourcentage / 100;
  }

  /// Les hausses encore à venir pour une grille (après [on], défaut =
  /// aujourd'hui).
  static List<Hausse> haussesFutures(Secteur s, {DateTime? on}) {
    final DateTime d = on ?? DateTime.now();
    return [
      for (final h in haussesAVenir[s] ?? const <Hausse>[])
        if (h.date.isAfter(d)) h
    ];
  }

  // ── Reste des données de référence ───────────────────────────────────

  static List<JourFerie> get feries => [
    JourFerie(tr('Jour de l\'An', 'New Year\'s Day'),
        tr('1er janvier (et parfois le 2)', 'January 1 (and sometimes the 2nd)')),
    JourFerie(tr('Vendredi saint ou lundi de Pâques', 'Good Friday or Easter Monday'),
        tr('Selon la convention', 'As per the agreement')),
    JourFerie(tr('Journée nationale des patriotes', 'National Patriots\' Day'),
        tr('Lundi avant le 25 mai', 'Monday before May 25')),
    JourFerie(tr('Fête nationale du Québec', 'Quebec National Holiday'),
        tr('24 juin (Saint-Jean)', 'June 24 (Saint-Jean)')),
    JourFerie(tr('Fête du Canada', 'Canada Day'), tr('1er juillet', 'July 1')),
    JourFerie(tr('Fête du travail', 'Labour Day'),
        tr('1er lundi de septembre', '1st Monday of September')),
    JourFerie(tr('Action de grâce', 'Thanksgiving'),
        tr('2e lundi d\'octobre', '2nd Monday of October')),
    JourFerie(tr('Noël', 'Christmas'),
        tr('25 décembre (et parfois les jours autour)',
            'December 25 (and sometimes surrounding days)')),
  ];

  static List<JourFerie> get vacancesConstruction => [
    JourFerie(tr('Vacances d\'été', 'Summer vacation'),
        tr('Généralement les 2 dernières semaines de juillet',
            'Usually the last 2 weeks of July')),
    JourFerie(tr('Vacances d\'hiver', 'Winter vacation'),
        tr('Généralement 2 semaines autour de la période des Fêtes',
            'Usually 2 weeks around the holidays')),
  ];

  static List<Ressource> get ressources => [
    Ressource(tr('Urgence', 'Emergency'), '911',
        tr('Accident grave, incendie, blessé — appeler tout de suite.',
            'Serious accident, fire, injury — call immediately.'),
        confirme: true, urgence: true),
    Ressource('Info-Santé / Info-Social', '811',
        tr('Conseil santé (option 1) ou psychosocial (option 2), 24 h/24.',
            'Health advice (option 1) or psychosocial (option 2), 24/7.'),
        confirme: true),
    Ressource('CNESST', '1 844 838-0808',
        tr('Santé et sécurité du travail, indemnisation, plaintes.',
            'Occupational health & safety, compensation, complaints.'),
        confirme: true),
    Ressource('CCQ', '1 888 842-8282',
        tr('Heures, avantages sociaux, carte de compétence, formation.',
            'Hours, benefits, competency card, training.'),
        confirme: true),
    Ressource(tr('Site web CCQ', 'CCQ website'), 'ccq.org/salaire',
        tr('Taux de salaire officiels par secteur, conventions, relevés.',
            'Official wage rates by sector, agreements, statements.'),
        confirme: true, web: true),
  ];

  static List<ConseilSecurite> get securite => [
    ConseilSecurite(
      tr('Droit de refus', 'Right to refuse'),
      Icons.pan_tool,
      tr(
          'Tu peux refuser un travail dangereux pour toi ou les autres. '
              'Avise ton supérieur et le représentant en santé-sécurité. '
              'C\'est un droit protégé — personne ne peut te punir pour ça.',
          'You can refuse work that\'s dangerous to you or others. Tell your '
              'supervisor and the health-and-safety rep. It\'s a protected '
              'right — no one can punish you for it.'),
    ),
    ConseilSecurite(
      tr('Protection contre les chutes', 'Fall protection'),
      Icons.height,
      tr(
          'Harnais, longe et point d\'ancrage dès qu\'il y a un risque de '
              'chute (généralement 3 m et plus, ou près d\'un danger). '
              'Vérifie ton équipement avant chaque usage.',
          'Harness, lanyard and anchor point whenever there\'s a fall risk '
              '(usually 3 m and up, or near a hazard). Check your gear before '
              'each use.'),
    ),
    ConseilSecurite(
      tr('Cadenassage', 'Lockout'),
      Icons.lock,
      tr(
          'Avant d\'intervenir sur une machine : couper l\'énergie, cadenasser '
              'et vérifier l\'arrêt (zéro énergie). Un cadenas, une clé, une '
              'personne.',
          'Before working on a machine: cut the energy, lock out and verify '
              'zero energy. One lock, one key, one person.'),
    ),
    ConseilSecurite(
      tr('Échafaudages', 'Scaffolds'),
      Icons.stairs,
      tr(
          'Monté par une personne compétente, garde-corps en place, planchers '
              'complets, bien appuyé et de niveau. Inspecter avant de monter.',
          'Erected by a competent person, guardrails in place, full decking, '
              'well supported and level. Inspect before climbing.'),
    ),
    ConseilSecurite(
      tr('EPI de base', 'Basic PPE'),
      Icons.health_and_safety,
      tr(
          'Casque, bottes à cap, lunettes, gants et protection auditive selon '
              'le risque. Le bon équipement, en bon état, porté comme il faut.',
          'Hard hat, safety boots, glasses, gloves and hearing protection per '
              'the risk. The right gear, in good shape, worn properly.'),
    ),
    ConseilSecurite(
      tr('SIMDUT / produits dangereux', 'WHMIS / hazardous products'),
      Icons.science,
      tr(
          'Connais les pictogrammes, lis les fiches de données de sécurité, '
              'entrepose et manipule les produits comme prescrit.',
          'Know the pictograms, read the safety data sheets, store and handle '
              'products as prescribed.'),
    ),
    ConseilSecurite(
      tr('Espaces clos', 'Confined spaces'),
      Icons.door_sliding,
      tr(
          'Jamais seul, jamais sans test d\'atmosphère et permis d\'entrée. '
              'Prévoir surveillance et plan de sauvetage.',
          'Never alone, never without an atmosphere test and entry permit. '
              'Have an attendant and a rescue plan.'),
    ),
    ConseilSecurite(
      tr('Excavation / tranchée', 'Excavation / trench'),
      Icons.terrain,
      tr(
          'Étançonnement ou pente sécuritaire dès 1,2 m. Garde les tas de '
              'terre loin du bord. Ne descends jamais dans une tranchée non '
              'protégée.',
          'Shoring or safe sloping from 1.2 m. Keep spoil piles away from the '
              'edge. Never enter an unprotected trench.'),
    ),
    ConseilSecurite(
      tr('Poussière de silice', 'Silica dust'),
      Icons.grain,
      tr(
          'Couper, meuler ou percer le béton, la brique ou la pierre dégage de '
              'la silice cristalline (cancérigène). Travaille à l\'eau ou avec '
              'aspiration à la source, et porte un appareil respiratoire '
              'adapté. Jamais à sec sans protection.',
          'Cutting, grinding or drilling concrete, brick or stone releases '
              'crystalline silica (carcinogenic). Work wet or with '
              'source capture, and wear a suitable respirator. Never dry '
              'without protection.'),
    ),
    ConseilSecurite(
      tr('Amiante', 'Asbestos'),
      Icons.warning_amber,
      tr(
          'Présent dans bien des bâtiments avant 1990 (isolants, tuiles, '
              'plâtre). Ne perce ni ne démolis sans avis : une évaluation est '
              'obligatoire. Travaux d\'amiante = procédure, confinement et '
              'protection stricts.',
          'Found in many pre-1990 buildings (insulation, tiles, plaster). '
              'Don\'t drill or demolish without notice: an assessment is '
              'mandatory. Asbestos work = strict procedure, containment and '
              'protection.'),
    ),
    ConseilSecurite(
      tr('Bruit et audition', 'Noise and hearing'),
      Icons.hearing,
      tr(
          'Au-delà du seuil réglementaire, porte des bouchons ou coquilles. '
              'La perte auditive est permanente et indolore. Règle simple : si '
              'tu dois crier pour être entendu à un bras de distance, c\'est '
              'trop fort.',
          'Above the regulatory limit, wear plugs or muffs. Hearing loss is '
              'permanent and painless. Simple rule: if you must shout to be '
              'heard an arm\'s length away, it\'s too loud.'),
    ),
    ConseilSecurite(
      tr('Coup de chaleur', 'Heat stroke'),
      Icons.wb_sunny,
      tr(
          'Par temps chaud : bois de l\'eau souvent (avant d\'avoir soif), '
              'prends des pauses à l\'ombre, acclimate-toi progressivement. '
              'Étourdissements, crampes, confusion, arrêt de sudation = '
              'urgence, appelle le 911.',
          'In hot weather: drink water often (before you\'re thirsty), take '
              'shade breaks, acclimatize gradually. Dizziness, cramps, '
              'confusion, stopping sweating = emergency, call 911.'),
    ),
    ConseilSecurite(
      tr('Froid et hiver', 'Cold and winter'),
      Icons.ac_unit,
      tr(
          'Habille-toi en couches, garde extrémités et tête au chaud, surveille '
              'engelures (peau blanche/engourdie) et hypothermie (frissons, '
              'confusion). Attention aux surfaces glacées et au déneigement des '
              'accès.',
          'Dress in layers, keep extremities and head warm, watch for '
              'frostbite (white/numb skin) and hypothermia (shivering, '
              'confusion). Beware icy surfaces and clearing access ways.'),
    ),
    ConseilSecurite(
      tr('Lignes électriques', 'Power lines'),
      Icons.bolt,
      tr(
          'Garde les distances d\'approche des lignes aériennes (selon la '
              'tension). Grues, échelles, échafaudages : repère les fils avant. '
              'En cas de contact, reste sur l\'équipement et éloigne tout le '
              'monde.',
          'Keep the approach distances from overhead lines (by voltage). '
              'Cranes, ladders, scaffolds: spot the wires first. On contact, '
              'stay on the equipment and keep everyone away.'),
    ),
    ConseilSecurite(
      tr('Levage et charges suspendues', 'Lifting and suspended loads'),
      Icons.precision_manufacturing,
      tr(
          'Ne circule et ne travaille jamais sous une charge suspendue. '
              'Élingues et crochets inspectés, capacité respectée, signaleur '
              'désigné. Communique clairement avec le grutier.',
          'Never walk or work under a suspended load. Inspected slings and '
              'hooks, rated capacity respected, designated signaller. '
              'Communicate clearly with the crane operator.'),
    ),
    ConseilSecurite(
      tr('Signalisation et circulation', 'Signage and traffic'),
      Icons.traffic,
      tr(
          'Sur la route ou près des engins : dossard haute visibilité, zone '
              'balisée, contact visuel avec les opérateurs. Attention aux '
              'angles morts et aux marches arrière (signaleur au besoin).',
          'On the road or near equipment: high-visibility vest, marked zone, '
              'eye contact with operators. Watch for blind spots and reversing '
              '(signaller as needed).'),
    ),
    ConseilSecurite(
      tr('Manutention et dos', 'Material handling and back'),
      Icons.fitness_center,
      tr(
          'Plie les genoux, garde la charge près du corps, ne te tord pas. '
              'Demande de l\'aide ou un moyen mécanique pour les charges '
              'lourdes. Le dos, ça ne se répare pas comme un outil.',
          'Bend your knees, keep the load close, don\'t twist. Ask for help or '
              'a mechanical aid for heavy loads. Your back doesn\'t fix like a '
              'tool.'),
    ),
    ConseilSecurite(
      tr('Outils et machines', 'Tools and machines'),
      Icons.handyman,
      tr(
          'Protecteurs en place, jamais retirés ni bloqués. Bon outil pour la '
              'tâche, en bon état. Débranche avant d\'ajuster ou de nettoyer. '
              'Lunettes et gants selon le risque.',
          'Guards in place, never removed or blocked. Right tool for the task, '
              'in good shape. Unplug before adjusting or cleaning. Glasses and '
              'gloves per the risk.'),
    ),
    ConseilSecurite(
      tr('Travail à chaud (soudage)', 'Hot work (welding)'),
      Icons.local_fire_department,
      tr(
          'Permis de travail à chaud, extincteur à portée, surveillance des '
              'étincelles et de la zone après coup. Ventilation contre les '
              'fumées de soudage. Écran et lunettes contre le rayonnement.',
          'Hot-work permit, extinguisher within reach, watch sparks and the '
              'area afterward. Ventilation against welding fumes. Screen and '
              'glasses against radiation.'),
    ),
    ConseilSecurite(
      tr('Premiers secours', 'First aid'),
      Icons.medical_services,
      tr(
          'Sache où sont la trousse et le secouriste désigné du chantier. '
              'En cas d\'accident : sécuriser les lieux, ne pas déplacer un '
              'blessé grave sans raison, appeler le 911, donner l\'adresse '
              'précise.',
          'Know where the first-aid kit and the site\'s designated first-aider '
              'are. On an accident: secure the area, don\'t move a seriously '
              'injured person without reason, call 911, give the exact '
              'address.'),
    ),
    ConseilSecurite(
      tr('Plan d\'urgence', 'Emergency plan'),
      Icons.emergency_share,
      tr(
          'Connais les sorties, le point de rassemblement et les moyens '
              'd\'alerte du chantier. En cas d\'évacuation : sortir vite, ne '
              'pas revenir, se compter au point de rassemblement.',
          'Know the exits, the muster point and the site\'s alarm systems. On '
              'evacuation: get out fast, don\'t go back, get counted at the '
              'muster point.'),
    ),
    ConseilSecurite(
      tr('Nouveau ou jeune travailleur', 'New or young worker'),
      Icons.school,
      tr(
          'Le risque est plus élevé les premiers mois. Pose des questions, '
              'demande la formation et l\'accueil santé-sécurité, n\'exécute '
              'pas une tâche que tu ne maîtrises pas. Aucune question n\'est '
              'niaiseuse.',
          'The risk is higher in the first months. Ask questions, request '
              'training and the safety orientation, don\'t do a task you '
              'haven\'t mastered. No question is a dumb one.'),
    ),
    ConseilSecurite(
      tr('Fatigue, alcool et drogues', 'Fatigue, alcohol and drugs'),
      Icons.nightlight,
      tr(
          'La fatigue et les substances (incluant le cannabis et certains '
              'médicaments) réduisent jugement et réflexes. Sur un chantier, '
              'c\'est un danger pour toi et les autres. Signale si tu n\'es pas '
              'en état.',
          'Fatigue and substances (including cannabis and some medications) '
              'reduce judgment and reflexes. On a site, that\'s a danger to you '
              'and others. Speak up if you\'re not fit for work.'),
    ),
  ];
}

class Metier {
  const Metier(this.nom, this.icon, this.apprentiPct, this._base,
      {this.libelleCompagnon = 'Compagnon', this.code});
  final String nom;
  final IconData icon;

  /// Code d'occupation CCQ (occupationId), pour interroger l'API des taux.
  final int? code;

  /// Pourcentages des périodes d'apprenti (ex. [60,70,85]). Vide = pas
  /// d'apprentissage (ex. manœuvre).
  final List<int> apprentiPct;
  final Map<Secteur, double> _base;
  final String libelleCompagnon;

  double baseCompagnon(Secteur s) => _base[s] ?? 0;

  /// Nom du métier dans la langue active (repli sur le français si absent).
  String get nomAffiche => tr(nom, metierEn[nom] ?? nom);

  /// Paliers du métier : apprentis puis compagnon (100 %).
  List<Palier> paliers() => [
        for (int i = 0; i < apprentiPct.length; i++)
          Palier('${tr('Apprenti', 'Apprentice')} ${i + 1}', apprentiPct[i]),
        Palier(
            tr(libelleCompagnon,
                libelleCompagnon == 'Taux' ? 'Rate' : 'Journeyman'),
            100),
      ];
}

class Palier {
  const Palier(this.nom, this.pourcentage);
  final String nom;
  final int pourcentage;
}

/// Noms anglais des métiers (clé = nom français exact). Une clé absente
/// retombe sur le français — jamais d'erreur.
const Map<String, String> metierEn = {
  'Boutefeu': 'Blaster',
  'Boutefeu classe 2': 'Blaster class 2',
  'Briqueteur-maçon': 'Bricklayer-mason',
  'Calorifugeur': 'Insulator',
  'Carreleur': 'Tile setter',
  'Charpentier-menuisier': 'Carpenter-joiner',
  'Chaudronnier': 'Boilermaker',
  'Chauffeur de chaudière classe IV': 'Boiler operator class IV',
  'Chauffeur de chaudière à vapeur': 'Steam boiler operator',
  'Cimentier-applicateur': 'Cement finisher-applicator',
  'Coffrage à béton (Charp-men)': 'Concrete formwork (Carpenter)',
  'Commis': 'Clerk',
  'Conducteur de camions classe A': 'Truck driver class A',
  'Conducteur de camions classe AA': 'Truck driver class AA',
  'Conducteur de camions classe B': 'Truck driver class B',
  'Conducteur de camions classe C': 'Truck driver class C',
  'Couvreur': 'Roofer',
  'Ferblantier': 'Sheet metal worker',
  'Ferrailleur': 'Reinforcing ironworker (rodman)',
  'Foreur': 'Driller',
  'Foreur classe 2': 'Driller class 2',
  'Frigoriste': 'Refrigeration mechanic',
  'Gardien': 'Watchman',
  'Grutier - classe A - 1er homme': 'Crane operator - class A - 1st operator',
  'Grutier - classe A - 2e homme': 'Crane operator - class A - 2nd operator',
  'Grutier - classe B': 'Crane operator - class B',
  'Grutier-classe A-1er homme (viaduc)': 'Crane operator class A-1st (overpass)',
  'Grutier-classe A-2e homme (viaduc)': 'Crane operator class A-2nd (overpass)',
  'Grutier-classe B (viaduc)': 'Crane operator class B (overpass)',
  'Homme service sur machinerie lourde': 'Heavy machinery service worker',
  'Inst plateformes élév (mécan d\'asc)': 'Elevating platform installer (elevator mech.)',
  'Inst. de systèmes de sécurité': 'Security systems installer',
  'Inst. miroir, montres-comptoirs': 'Mirror/showcase installer',
  'Jointoyeur (Peintre)': 'Taper (Painter)',
  'Jointoyeur (Plâtrier)': 'Taper (Plasterer)',
  'Magasinier': 'Storekeeper',
  'Manoeuvre': 'Labourer',
  'Manoeuvre (entr. & nett.)': 'Labourer (maint. & cleaning)',
  'Manoeuvre (travaux de couverture)': 'Labourer (roofing work)',
  'Manoeuvre canalisation souterraine': 'Underground piping labourer',
  'Manoeuvre en décontamination': 'Decontamination labourer',
  'Manoeuvre en maçonnerie': 'Masonry labourer',
  'Manoeuvre en échafaudage': 'Scaffolding labourer',
  'Manoeuvre nettoyage conduits d\'air': 'Air-duct cleaning labourer',
  'Manoeuvre pipeline': 'Pipeline labourer',
  'Manoeuvre sciage béton et asphalte': 'Concrete/asphalt sawing labourer',
  'Manoeuvre spéc.(trav. couverture)': 'Spec. labourer (roofing work)',
  'Manoeuvre spécialisé': 'Specialized labourer',
  'Manoeuvre spécialisé carreleur': 'Specialized tile-setter labourer',
  'Manœuvre (aqueduc et égouts) 1er poseur': 'Labourer (water & sewer) 1st layer',
  'Manœuvre (aqueduc et égouts) 1er poseur (classe 2)': 'Labourer (water & sewer) 1st layer (class 2)',
  'Manœuvre (aqueduc et égouts) 2ème poseur': 'Labourer (water & sewer) 2nd layer',
  'Manœuvre (aqueduc et égouts) 2ème poseur (classe 2)': 'Labourer (water & sewer) 2nd layer (class 2)',
  'Manœuvre à la préparation (top man)': 'Prep labourer (top man)',
  'Manœuvre à la préparation (top man)  (classe 2)': 'Prep labourer (top man) (class 2)',
  'Monteur-assembleur': 'Assembler-erector',
  'Monteur-mécanicien (vitrier)': 'Mechanic-erector (glazier)',
  'Monteur-mécanique porte et fenêtre': 'Door & window mechanic-erector',
  'Mécanicien d\'ascenseur': 'Elevator mechanic',
  'Mécanicien de chantier': 'Millwright',
  'Mécanicien de machines lourdes': 'Heavy equipment mechanic',
  'Mécanicien en protection-incendie': 'Fire-protection mechanic',
  'Op. pompe béton mât dist. -42m': 'Concrete pump op. boom <42m',
  'Op. pompe béton mât dist. 42m +': 'Concrete pump op. boom 42m+',
  'Op. pompe béton mât dist. 50m +': 'Concrete pump op. boom 50m+',
  'Op. pompe béton mât dist. 58m +': 'Concrete pump op. boom 58m+',
  'Opér. appareils levage - classe A': 'Hoisting equipment op. - class A',
  'Opér. appareils levage - classe B': 'Hoisting equipment op. - class B',
  'Opér. pelles mécaniques - classe A': 'Power shovel op. - class A',
  'Opér. pelles mécaniques - classe AA': 'Power shovel op. - class AA',
  'Opér. pelles mécaniques - classe B': 'Power shovel op. - class B',
  'Opérateur d\'usine fixe ou mobile': 'Fixed/mobile plant operator',
  'Opérateur d\'épandeuses': 'Spreader operator',
  'Opérateur de génératrice': 'Generator operator',
  'Opérateur de niveleuses': 'Grader operator',
  'Opérateur de pompe et compresseur': 'Pump & compressor operator',
  'Opérateur de rouleaux - classe A': 'Roller operator - class A',
  'Opérateur de rouleaux - classe B': 'Roller operator - class B',
  'Opérateur de rétrocaveuses classe A': 'Backhoe operator class A',
  'Opérateur de tracteurs - classe A': 'Tractor operator - class A',
  'Opérateur de tracteurs - classe B': 'Tractor operator - class B',
  'Opérateur de tracteurs classe AA': 'Tractor operator class AA',
  'Opérateur pompe à béton 63m': 'Concrete pump op. 63m',
  'Parqueteur-sableur (menuisier)': 'Floor layer-sander (carpenter)',
  'Peintre': 'Painter',
  'Plombier (Tuyauteur)': 'Plumber (Pipefitter)',
  'Plâtrier': 'Plasterer',
  'Pose de fondations profondes': 'Deep foundation work',
  'Poseur d\'appareils de chauffage': 'Heating appliance installer',
  'Poseur de portes de garage': 'Garage door installer',
  'Poseur de revêtements souples': 'Resilient flooring installer',
  'Poseur de systèmes intérieurs': 'Interior systems installer',
  'Préposé aux instruments d\'arpentage': 'Surveying instrument attendant',
  'Préposé aux pneus et au débosselage': 'Tire & dent-repair attendant',
  'Rateleur d\'asphalte': 'Asphalt raker',
  'Scaphandrier (plongeur prof)': 'Diver (professional)',
  'Scaphandrier (plongeur prof) CL2': 'Diver (professional) CL2',
  'Soudeur': 'Welder',
  'Soudeur chaudronnier': 'Boilermaker welder',
  'Soudeur de distribution': 'Distribution welder',
  'Soudeur de machinerie lourde': 'Heavy machinery welder',
  'Soudeur de pipeline': 'Pipeline welder',
  'Soudeur en tuyauterie': 'Pipe welder',
  'Soudeur monteur-assembleur': 'Assembler-erector welder',
  'Spéc. branchement immeuble(gaz fit)': 'Building connection spec. (gas fitter)',
  'Travailleur souterrain (mineur)': 'Underground worker (miner)',
  'Électricien': 'Electrician',
};

class JourFerie {
  const JourFerie(this.nom, this.detail);
  final String nom;
  final String detail;
}

class Ressource {
  const Ressource(
    this.nom,
    this.numero,
    this.description, {
    this.confirme = false,
    this.urgence = false,
    this.web = false,
  });
  final String nom;
  final String numero;
  final String description;
  final bool confirme;
  final bool urgence;
  final bool web;
}

class ConseilSecurite {
  const ConseilSecurite(this.titre, this.icon, this.details);
  final String titre;
  final IconData icon;
  final String details;
}
