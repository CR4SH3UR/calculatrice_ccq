import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/lang.dart';
import 'profil.dart';
import 'representants.dart';

/// Préférences de l'app : thème et outils favoris, persistés localement.
class AppPrefs {
  const AppPrefs._();

  static const String _cleTheme = 'theme_mode_v1';
  static const String _cleFavoris = 'favoris_v1';
  static const String _cleObjectif = 'objectif_hebdo_v1';
  static const String _cleLangue = 'langue_v1';
  static const String _cleProfil = 'profil_v1';

  /// Mode de thème choisi (clair / sombre / système).
  static final ValueNotifier<ThemeMode> theme =
      ValueNotifier(ThemeMode.system);

  /// Objectif d'heures par semaine (feuille de temps).
  static final ValueNotifier<double> objectifHebdo = ValueNotifier(40);

  /// Profil de l'utilisateur (infos de travail, local uniquement).
  static final ValueNotifier<Profil> profil = ValueNotifier(const Profil());

  /// Ensemble des identifiants d'outils favoris.
  static final FavorisStore favoris = FavorisStore._();

  /// Représentants syndicaux saisis par l'utilisateur (local uniquement).
  static final RepresentantsStore representants = RepresentantsStore();

  static Future<void> charger() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_cleTheme);
    theme.value = switch (t) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    objectifHebdo.value = prefs.getDouble(_cleObjectif) ?? 40;
    langue.value = prefs.getString(_cleLangue) == 'en' ? Lang.en : Lang.fr;
    profil.value = Profil.decode(prefs.getString(_cleProfil));
    favoris._charger(prefs.getStringList(_cleFavoris) ?? const []);
    await representants.charger();
  }

  /// Enregistre le profil de l'utilisateur.
  static Future<void> setProfil(Profil p) async {
    profil.value = p;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleProfil, p.encode());
  }

  /// Change la langue de l'interface (FR/EN) et la persiste.
  static Future<void> setLangue(Lang l) async {
    langue.value = l;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleLangue, l == Lang.en ? 'en' : 'fr');
  }

  static Future<void> setObjectif(double h) async {
    objectifHebdo.value = h;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_cleObjectif, h);
  }

  static Future<void> setTheme(ThemeMode m) async {
    theme.value = m;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleTheme,
        switch (m) { ThemeMode.light => 'light', ThemeMode.dark => 'dark', _ => 'system' });
  }

  static Future<void> _sauverFavoris(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_cleFavoris, ids.toList());
  }
}

/// Gère la liste des favoris (identifiants d'outils). [ChangeNotifier] pour
/// que l'accueil se reconstruise quand ça change.
class FavorisStore extends ChangeNotifier {
  FavorisStore._();
  final Set<String> _ids = {};

  List<String> get ids => _ids.toList();
  bool contient(String id) => _ids.contains(id);
  bool get estVide => _ids.isEmpty;

  void _charger(List<String> ids) {
    _ids
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  Future<void> basculer(String id) async {
    if (!_ids.remove(id)) _ids.add(id);
    await AppPrefs._sauverFavoris(_ids);
    notifyListeners();
  }
}
