import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un représentant syndical saisi par l'utilisateur (données personnelles,
/// gardées **localement** sur l'appareil). L'app ne fournit aucun nom : c'est
/// l'utilisateur qui inscrit les vraies coordonnées de son représentant.
class Representant {
  Representant({
    required this.id,
    this.nom = '',
    this.poste = '',
    this.telephone = '',
    this.courriel = '',
    this.syndicat = '',
  });

  final String id;
  String nom;
  String poste;
  String telephone;
  String courriel;
  String syndicat; // sigle de l'allégeance

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'poste': poste,
        'telephone': telephone,
        'courriel': courriel,
        'syndicat': syndicat,
      };

  factory Representant.fromJson(Map<String, dynamic> j) => Representant(
        id: (j['id'] ?? '') as String,
        nom: (j['nom'] ?? '') as String,
        poste: (j['poste'] ?? '') as String,
        telephone: (j['telephone'] ?? '') as String,
        courriel: (j['courriel'] ?? '') as String,
        syndicat: (j['syndicat'] ?? '') as String,
      );
}

/// Liste des représentants personnels de l'utilisateur, persistée localement.
class RepresentantsStore extends ChangeNotifier {
  static const String _cle = 'representants_v1';
  final List<Representant> _list = [];

  List<Representant> get all => List.unmodifiable(_list);
  bool get estVide => _list.isEmpty;

  Future<void> charger() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cle);
    _list.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        for (final e in jsonDecode(raw) as List) {
          _list.add(Representant.fromJson(e as Map<String, dynamic>));
        }
      } catch (_) {
        // JSON corrompu : on repart d'une liste vide.
      }
    }
    notifyListeners();
  }

  Future<void> _sauver() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _cle, jsonEncode(_list.map((r) => r.toJson()).toList()));
  }

  /// Ajoute ou met à jour un représentant (selon son [Representant.id]).
  Future<void> enregistrer(Representant r) async {
    final i = _list.indexWhere((x) => x.id == r.id);
    if (i >= 0) {
      _list[i] = r;
    } else {
      _list.add(r);
    }
    await _sauver();
    notifyListeners();
  }

  Future<void> supprimer(String id) async {
    _list.removeWhere((x) => x.id == id);
    await _sauver();
    notifyListeners();
  }
}
