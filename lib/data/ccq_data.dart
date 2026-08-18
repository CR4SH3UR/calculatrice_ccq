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

  static const List<JourFerie> feries = [
    JourFerie('Jour de l\'An', '1er janvier (et parfois le 2)'),
    JourFerie('Vendredi saint ou lundi de Pâques', 'Selon la convention'),
    JourFerie('Journée nationale des patriotes', 'Lundi avant le 25 mai'),
    JourFerie('Fête nationale du Québec', '24 juin (Saint-Jean)'),
    JourFerie('Fête du Canada', '1er juillet'),
    JourFerie('Fête du travail', '1er lundi de septembre'),
    JourFerie('Action de grâce', '2e lundi d\'octobre'),
    JourFerie('Noël', '25 décembre (et parfois les jours autour)'),
  ];

  static const List<JourFerie> vacancesConstruction = [
    JourFerie('Vacances d\'été',
        'Généralement les 2 dernières semaines de juillet'),
    JourFerie('Vacances d\'hiver',
        'Généralement 2 semaines autour de la période des Fêtes'),
  ];

  static const List<Ressource> ressources = [
    Ressource('Urgence', '911',
        'Accident grave, incendie, blessé — appeler tout de suite.',
        confirme: true, urgence: true),
    Ressource('Info-Santé / Info-Social', '811',
        'Conseil santé (option 1) ou psychosocial (option 2), 24 h/24.',
        confirme: true),
    Ressource('CNESST', '1 844 838-0808',
        'Santé et sécurité du travail, indemnisation, plaintes.',
        confirme: true),
    Ressource('CCQ', '1 888 842-8282',
        'Heures, avantages sociaux, carte de compétence, formation.',
        confirme: true),
    Ressource('Site web CCQ', 'ccq.org/salaire',
        'Taux de salaire officiels par secteur, conventions, relevés.',
        confirme: true, web: true),
  ];

  static const List<ConseilSecurite> securite = [
    ConseilSecurite(
      'Droit de refus',
      Icons.pan_tool,
      'Tu peux refuser un travail dangereux pour toi ou les autres. '
          'Avise ton supérieur et le représentant en santé-sécurité. '
          'C\'est un droit protégé — personne ne peut te punir pour ça.',
    ),
    ConseilSecurite(
      'Protection contre les chutes',
      Icons.height,
      'Harnais, longe et point d\'ancrage dès qu\'il y a un risque de '
          'chute (généralement 3 m et plus, ou près d\'un danger). '
          'Vérifie ton équipement avant chaque usage.',
    ),
    ConseilSecurite(
      'Cadenassage',
      Icons.lock,
      'Avant d\'intervenir sur une machine : couper l\'énergie, cadenasser '
          'et vérifier l\'arrêt (zéro énergie). Un cadenas, une clé, une '
          'personne.',
    ),
    ConseilSecurite(
      'Échafaudages',
      Icons.stairs,
      'Monté par une personne compétente, garde-corps en place, planchers '
          'complets, bien appuyé et de niveau. Inspecter avant de monter.',
    ),
    ConseilSecurite(
      'EPI de base',
      Icons.health_and_safety,
      'Casque, bottes à cap, lunettes, gants et protection auditive selon '
          'le risque. Le bon équipement, en bon état, porté comme il faut.',
    ),
    ConseilSecurite(
      'SIMDUT / produits dangereux',
      Icons.science,
      'Connais les pictogrammes, lis les fiches de données de sécurité, '
          'entrepose et manipule les produits comme prescrit.',
    ),
    ConseilSecurite(
      'Espaces clos',
      Icons.door_sliding,
      'Jamais seul, jamais sans test d\'atmosphère et permis d\'entrée. '
          'Prévoir surveillance et plan de sauvetage.',
    ),
    ConseilSecurite(
      'Excavation / tranchée',
      Icons.terrain,
      'Étançonnement ou pente sécuritaire dès 1,2 m. Garde les tas de '
          'terre loin du bord. Ne descends jamais dans une tranchée non '
          'protégée.',
    ),
    ConseilSecurite(
      'Poussière de silice',
      Icons.grain,
      'Couper, meuler ou percer le béton, la brique ou la pierre dégage de '
          'la silice cristalline (cancérigène). Travaille à l\'eau ou avec '
          'aspiration à la source, et porte un appareil respiratoire adapté. '
          'Jamais à sec sans protection.',
    ),
    ConseilSecurite(
      'Amiante',
      Icons.warning_amber,
      'Présent dans bien des bâtiments avant 1990 (isolants, tuiles, plâtre). '
          'Ne perce ni ne démolis sans avis : une évaluation est obligatoire. '
          'Travaux d\'amiante = procédure, confinement et protection stricts.',
    ),
    ConseilSecurite(
      'Bruit et audition',
      Icons.hearing,
      'Au-delà du seuil réglementaire, porte des bouchons ou coquilles. '
          'La perte auditive est permanente et indolore. Règle simple : si '
          'tu dois crier pour être entendu à un bras de distance, c\'est trop '
          'fort.',
    ),
    ConseilSecurite(
      'Coup de chaleur',
      Icons.wb_sunny,
      'Par temps chaud : bois de l\'eau souvent (avant d\'avoir soif), '
          'prends des pauses à l\'ombre, acclimate-toi progressivement. '
          'Étourdissements, crampes, confusion, arrêt de sudation = urgence, '
          'appelle le 911.',
    ),
    ConseilSecurite(
      'Froid et hiver',
      Icons.ac_unit,
      'Habille-toi en couches, garde extrémités et tête au chaud, surveille '
          'engelures (peau blanche/engourdie) et hypothermie (frissons, '
          'confusion). Attention aux surfaces glacées et au déneigement des '
          'accès.',
    ),
    ConseilSecurite(
      'Lignes électriques',
      Icons.bolt,
      'Garde les distances d\'approche des lignes aériennes (selon la '
          'tension). Grues, échelles, échafaudages : repère les fils avant. '
          'En cas de contact, reste sur l\'équipement et éloigne tout le '
          'monde.',
    ),
    ConseilSecurite(
      'Levage et charges suspendues',
      Icons.precision_manufacturing,
      'Ne circule et ne travaille jamais sous une charge suspendue. Élingues '
          'et crochets inspectés, capacité respectée, signaleur désigné. '
          'Communique clairement avec le grutier.',
    ),
    ConseilSecurite(
      'Signalisation et circulation',
      Icons.traffic,
      'Sur la route ou près des engins : dossard haute visibilité, zone '
          'balisée, contact visuel avec les opérateurs. Attention aux angles '
          'morts et aux marches arrière (signaleur au besoin).',
    ),
    ConseilSecurite(
      'Manutention et dos',
      Icons.fitness_center,
      'Plie les genoux, garde la charge près du corps, ne te tord pas. '
          'Demande de l\'aide ou un moyen mécanique pour les charges lourdes. '
          'Le dos, ça ne se répare pas comme un outil.',
    ),
    ConseilSecurite(
      'Outils et machines',
      Icons.handyman,
      'Protecteurs en place, jamais retirés ni bloqués. Bon outil pour la '
          'tâche, en bon état. Débranche avant d\'ajuster ou de nettoyer. '
          'Lunettes et gants selon le risque.',
    ),
    ConseilSecurite(
      'Travail à chaud (soudage)',
      Icons.local_fire_department,
      'Permis de travail à chaud, extincteur à portée, surveillance des '
          'étincelles et de la zone après coup. Ventilation contre les fumées '
          'de soudage. Écran et lunettes contre le rayonnement.',
    ),
    ConseilSecurite(
      'Premiers secours',
      Icons.medical_services,
      'Sache où sont la trousse et le secouriste désigné du chantier. '
          'En cas d\'accident : sécuriser les lieux, ne pas déplacer un '
          'blessé grave sans raison, appeler le 911, donner l\'adresse '
          'précise.',
    ),
    ConseilSecurite(
      'Plan d\'urgence',
      Icons.emergency_share,
      'Connais les sorties, le point de rassemblement et les moyens d\'alerte '
          'du chantier. En cas d\'évacuation : sortir vite, ne pas revenir, '
          'se compter au point de rassemblement.',
    ),
    ConseilSecurite(
      'Nouveau ou jeune travailleur',
      Icons.school,
      'Le risque est plus élevé les premiers mois. Pose des questions, '
          'demande la formation et l\'accueil santé-sécurité, n\'exécute pas '
          'une tâche que tu ne maîtrises pas. Aucune question n\'est niaiseuse.',
    ),
    ConseilSecurite(
      'Fatigue, alcool et drogues',
      Icons.nightlight,
      'La fatigue et les substances (incluant le cannabis et certains '
          'médicaments) réduisent jugement et réflexes. Sur un chantier, '
          'c\'est un danger pour toi et les autres. Signale si tu n\'es pas '
          'en état.',
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
