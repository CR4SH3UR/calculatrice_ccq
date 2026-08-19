import 'dart:convert';

/// Profil de l'utilisateur : ses infos de travail, gardées **localement**
/// sur l'appareil (SharedPreferences). Rien n'est envoyé sur Internet.
class Profil {
  const Profil({
    this.metier = '',
    this.secteur = '',
    this.region = '',
    this.employeur = '',
    this.numeroCompetence = '',
    this.aspExpiration,
    this.tauxHoraire,
    this.syndicat = '',
    this.urgenceNom = '',
    this.urgenceTel = '',
    this.groupeSanguin = '',
    this.allergies = '',
  });

  /// Nom du métier (clé française de `CcqData.metiers`).
  final String metier;

  /// Nom technique du secteur (`Secteur.name`) ou vide.
  final String secteur;
  final String region;
  final String employeur;

  /// Numéro de certificat de compétence CCQ.
  final String numeroCompetence;

  /// Date d'expiration de la carte ASP Construction.
  final DateTime? aspExpiration;

  /// Taux horaire personnel (sert à pré-remplir la paie).
  final double? tauxHoraire;

  /// Sigle de l'allégeance syndicale (voir écran Syndicats).
  final String syndicat;

  final String urgenceNom;
  final String urgenceTel;
  final String groupeSanguin;
  final String allergies;

  bool get estVide =>
      metier.isEmpty &&
      secteur.isEmpty &&
      region.isEmpty &&
      employeur.isEmpty &&
      numeroCompetence.isEmpty &&
      aspExpiration == null &&
      tauxHoraire == null &&
      syndicat.isEmpty &&
      urgenceNom.isEmpty &&
      urgenceTel.isEmpty &&
      groupeSanguin.isEmpty &&
      allergies.isEmpty;

  /// Nombre de jours avant l'expiration de la carte ASP (négatif = expirée).
  /// `null` si aucune date n'est renseignée.
  int? get joursAvantAsp {
    final d = aspExpiration;
    if (d == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(d.year, d.month, d.day).difference(today).inDays;
  }

  Map<String, dynamic> toJson() => {
        'metier': metier,
        'secteur': secteur,
        'region': region,
        'employeur': employeur,
        'numeroCompetence': numeroCompetence,
        'aspExpiration': aspExpiration?.toIso8601String(),
        'tauxHoraire': tauxHoraire,
        'syndicat': syndicat,
        'urgenceNom': urgenceNom,
        'urgenceTel': urgenceTel,
        'groupeSanguin': groupeSanguin,
        'allergies': allergies,
      };

  factory Profil.fromJson(Map<String, dynamic> j) => Profil(
        metier: (j['metier'] ?? '') as String,
        secteur: (j['secteur'] ?? '') as String,
        region: (j['region'] ?? '') as String,
        employeur: (j['employeur'] ?? '') as String,
        numeroCompetence: (j['numeroCompetence'] ?? '') as String,
        aspExpiration: j['aspExpiration'] == null
            ? null
            : DateTime.tryParse(j['aspExpiration'] as String),
        tauxHoraire: (j['tauxHoraire'] as num?)?.toDouble(),
        syndicat: (j['syndicat'] ?? '') as String,
        urgenceNom: (j['urgenceNom'] ?? '') as String,
        urgenceTel: (j['urgenceTel'] ?? '') as String,
        groupeSanguin: (j['groupeSanguin'] ?? '') as String,
        allergies: (j['allergies'] ?? '') as String,
      );

  String encode() => jsonEncode(toJson());

  /// Décode un profil depuis le JSON stocké; profil vide si invalide.
  static Profil decode(String? s) {
    if (s == null || s.isEmpty) return const Profil();
    try {
      return Profil.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return const Profil();
    }
  }
}
