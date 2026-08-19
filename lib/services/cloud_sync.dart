import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/app_prefs.dart';
import '../data/heures_store.dart';
import '../data/profil.dart';
import '../data/representants.dart';
import 'auth_service.dart';

/// Synchronise les données de l'utilisateur avec Firestore.
///
/// Modèle : un document par utilisateur dans `utilisateurs/{uid}`, contenant
/// le profil, la feuille de temps et les représentants perso (en JSON).
///
/// - À la connexion : on télécharge le document distant et on l'applique au
///   local (ou, s'il n'existe pas encore, on téléverse le local pour l'amorcer).
/// - Ensuite : tout changement local est renvoyé (avec un léger délai pour
///   regrouper les modifications rapprochées).
class CloudSync {
  CloudSync._();
  static final CloudSync instance = CloudSync._();

  /// Horodatage de la dernière synchro réussie (pour l'UI).
  final ValueNotifier<DateTime?> derniereSync = ValueNotifier(null);

  /// Vrai pendant une opération réseau (pour l'UI).
  final ValueNotifier<bool> enCours = ValueNotifier(false);

  bool _actif = false;
  bool _applique = false; // vrai pendant qu'on applique le distant
  Timer? _debounce;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final u = AuthService.instance.utilisateur;
    if (u == null) return null;
    return FirebaseFirestore.instance.collection('utilisateurs').doc(u.uid);
  }

  /// Démarre la synchro pour la session en cours.
  Future<void> demarrer() async {
    final doc = _doc;
    if (doc == null || _actif) return;
    _actif = true;
    enCours.value = true;
    try {
      final snap = await doc.get();
      final data = snap.data();
      if (snap.exists && data != null) {
        await _appliquerDistant(data);
      } else {
        await _pousser();
      }
      derniereSync.value = DateTime.now();
    } catch (e) {
      debugPrint('CloudSync.demarrer: $e');
    } finally {
      enCours.value = false;
    }
    _brancherEcouteurs();
  }

  /// Arrête la synchro (déconnexion).
  void arreter() {
    _debrancherEcouteurs();
    _debounce?.cancel();
    _actif = false;
  }

  void _brancherEcouteurs() {
    HeuresStore.instance.addListener(_planifierPush);
    AppPrefs.profil.addListener(_planifierPush);
    AppPrefs.representants.addListener(_planifierPush);
  }

  void _debrancherEcouteurs() {
    HeuresStore.instance.removeListener(_planifierPush);
    AppPrefs.profil.removeListener(_planifierPush);
    AppPrefs.representants.removeListener(_planifierPush);
  }

  void _planifierPush() {
    if (_applique) return; // le changement vient du distant : ne pas renvoyer
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), _pousser);
  }

  /// Force un envoi immédiat (bouton « Synchroniser maintenant »).
  Future<void> synchroniserMaintenant() async {
    _debounce?.cancel();
    await _pousser();
  }

  Future<void> _pousser() async {
    final doc = _doc;
    if (doc == null) return;
    enCours.value = true;
    try {
      await doc.set(_donneesLocales(), SetOptions(merge: true));
      derniereSync.value = DateTime.now();
    } catch (e) {
      debugPrint('CloudSync._pousser: $e');
    } finally {
      enCours.value = false;
    }
  }

  Map<String, dynamic> _donneesLocales() => {
        'profil': AppPrefs.profil.value.toJson(),
        'heures': HeuresStore.instance.entries.map((e) => e.toJson()).toList(),
        'representants':
            AppPrefs.representants.all.map((r) => r.toJson()).toList(),
        'maj': FieldValue.serverTimestamp(),
      };

  Future<void> _appliquerDistant(Map<String, dynamic> data) async {
    _applique = true;
    try {
      final p = data['profil'];
      if (p is Map) {
        await AppPrefs.setProfil(
            Profil.fromJson(Map<String, dynamic>.from(p)));
      }
      final h = data['heures'];
      if (h is List) {
        await HeuresStore.instance.remplacerTout([
          for (final e in h)
            HeureEntry.fromJson(Map<String, dynamic>.from(e as Map)),
        ]);
      }
      final r = data['representants'];
      if (r is List) {
        await AppPrefs.representants.remplacerTout([
          for (final e in r)
            Representant.fromJson(Map<String, dynamic>.from(e as Map)),
        ]);
      }
    } finally {
      _applique = false;
    }
  }
}
