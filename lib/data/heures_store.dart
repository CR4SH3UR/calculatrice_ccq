import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Une entrée de la feuille de temps : une journée de travail, avec ses heures,
/// son taux, ses primes et son déplacement.
class HeureEntry {
  HeureEntry({
    required this.id,
    required this.date,
    required this.taux,
    required this.hNormal,
    required this.h15,
    required this.h2,
    this.prime = 0,
    this.km = 0,
    this.tauxKm = 0,
    this.metier = '',
    this.secteur = '',
    this.employeur = '',
    this.note = '',
  });

  final String id;
  final DateTime date;
  final double taux;
  final double hNormal; // ×1
  final double h15; // temps et demi ×1,5
  final double h2; // temps double ×2
  final double prime; // prime en $ pour la journée
  final double km; // distance
  final double tauxKm; // $/km
  final String metier;
  final String secteur;
  final String employeur;
  final String note;

  double get heures => hNormal + h15 + h2;

  /// Salaire brut de la journée (heures × taux avec majorations + prime).
  double get brut => taux * hNormal + taux * 1.5 * h15 + taux * 2 * h2 + prime;

  /// Indemnité de déplacement (km × taux/km).
  double get deplacement => km * tauxKm;

  /// Total à recevoir avant retenues (brut + déplacement).
  double get total => brut + deplacement;

  HeureEntry copyWith({
    DateTime? date,
    double? taux,
    double? hNormal,
    double? h15,
    double? h2,
    double? prime,
    double? km,
    double? tauxKm,
    String? metier,
    String? secteur,
    String? employeur,
    String? note,
  }) =>
      HeureEntry(
        id: id,
        date: date ?? this.date,
        taux: taux ?? this.taux,
        hNormal: hNormal ?? this.hNormal,
        h15: h15 ?? this.h15,
        h2: h2 ?? this.h2,
        prime: prime ?? this.prime,
        km: km ?? this.km,
        tauxKm: tauxKm ?? this.tauxKm,
        metier: metier ?? this.metier,
        secteur: secteur ?? this.secteur,
        employeur: employeur ?? this.employeur,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'taux': taux,
        'hN': hNormal,
        'h15': h15,
        'h2': h2,
        'prime': prime,
        'km': km,
        'tauxKm': tauxKm,
        'metier': metier,
        'secteur': secteur,
        'employeur': employeur,
        'note': note,
      };

  static double _d(Object? v) => v is num ? v.toDouble() : 0.0;
  static String _s(Object? v) => v is String ? v : '';

  static HeureEntry fromJson(Map<String, dynamic> j) => HeureEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        taux: _d(j['taux']),
        hNormal: _d(j['hN']),
        h15: _d(j['h15']),
        h2: _d(j['h2']),
        prime: _d(j['prime']),
        km: _d(j['km']),
        tauxKm: _d(j['tauxKm']),
        metier: _s(j['metier']),
        secteur: _s(j['secteur']),
        employeur: _s(j['employeur']),
        note: _s(j['note']),
      );
}

/// Stockage local de la feuille de temps (persisté via shared_preferences).
/// Singleton et [ChangeNotifier] : l'UI se reconstruit quand ça change.
class HeuresStore extends ChangeNotifier {
  HeuresStore._();
  static final HeuresStore instance = HeuresStore._();

  static const String _cle = 'feuille_temps_v1';

  final List<HeureEntry> _entries = [];
  bool _charge = false;

  /// Entrées, de la plus récente à la plus ancienne.
  List<HeureEntry> get entries {
    final copie = [..._entries];
    copie.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(copie);
  }

  bool get estVide => _entries.isEmpty;

  Future<void> charger() async {
    if (_charge) return;
    _charge = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cle);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _entries
          ..clear()
          ..addAll(
              list.map((e) => HeureEntry.fromJson(e as Map<String, dynamic>)));
      }
    } catch (_) {
      // Données illisibles : on repart d'une feuille vide.
    }
    notifyListeners();
  }

  Future<void> ajouter(HeureEntry e) async {
    _entries.add(e);
    await _persister();
    notifyListeners();
  }

  Future<void> remplacer(HeureEntry e) async {
    final i = _entries.indexWhere((x) => x.id == e.id);
    if (i >= 0) {
      _entries[i] = e;
    } else {
      _entries.add(e);
    }
    await _persister();
    notifyListeners();
  }

  Future<void> supprimer(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _persister();
    notifyListeners();
  }

  /// Remplace toute la feuille (utilisé par la restauration de sauvegarde).
  Future<void> remplacerTout(List<HeureEntry> nouvelles) async {
    _entries
      ..clear()
      ..addAll(nouvelles);
    await _persister();
    notifyListeners();
  }

  Future<void> _persister() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _cle, jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }
}

/// Le lundi (début de semaine) de la date donnée, à minuit.
DateTime debutSemaine(DateTime d) {
  final jour = DateTime(d.year, d.month, d.day);
  return jour.subtract(Duration(days: jour.weekday - 1));
}
