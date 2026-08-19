import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../l10n/lang.dart';

/// Enveloppe autour de FirebaseAuth : connexion e-mail/mot de passe et Google.
///
/// Sur le web, Google passe par une fenêtre popup Firebase ; sur mobile, par
/// le flux natif du fournisseur — aucune dépendance `google_sign_in` requise.
class AuthService {
  const AuthService._();
  static const AuthService instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Flux d'état de connexion (null = déconnecté).
  Stream<User?> get changements => _auth.authStateChanges();
  User? get utilisateur => _auth.currentUser;
  bool get connecte => _auth.currentUser != null;

  /// Courriel affichable de l'utilisateur connecté.
  String? get courriel => _auth.currentUser?.email;

  Future<void> connecter(String courriel, String motDePasse) =>
      _auth.signInWithEmailAndPassword(
          email: courriel.trim(), password: motDePasse);

  Future<void> inscrire(String courriel, String motDePasse) =>
      _auth.createUserWithEmailAndPassword(
          email: courriel.trim(), password: motDePasse);

  Future<void> reinitialiserMotDePasse(String courriel) =>
      _auth.sendPasswordResetEmail(email: courriel.trim());

  Future<void> connecterGoogle() async {
    final provider = GoogleAuthProvider();
    if (kIsWeb) {
      await _auth.signInWithPopup(provider);
    } else {
      await _auth.signInWithProvider(provider);
    }
  }

  Future<void> deconnecter() => _auth.signOut();

  /// Traduit une erreur d'authentification en message lisible (FR/EN).
  static String messageErreur(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return tr('Adresse courriel invalide.', 'Invalid email address.');
        case 'user-disabled':
          return tr('Ce compte est désactivé.', 'This account is disabled.');
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          return tr('Courriel ou mot de passe incorrect.',
              'Incorrect email or password.');
        case 'email-already-in-use':
          return tr('Un compte existe déjà avec ce courriel.',
              'An account already exists with this email.');
        case 'weak-password':
          return tr('Mot de passe trop faible (6 caractères minimum).',
              'Password too weak (6 characters minimum).');
        case 'network-request-failed':
          return tr('Pas de connexion Internet.', 'No internet connection.');
        case 'too-many-requests':
          return tr('Trop de tentatives. Réessaie plus tard.',
              'Too many attempts. Try again later.');
        case 'operation-not-allowed':
          return tr('Cette méthode de connexion n\'est pas activée.',
              'This sign-in method is not enabled.');
        case 'popup-closed-by-user':
        case 'cancelled-popup-request':
          return tr('Connexion annulée.', 'Sign-in cancelled.');
        default:
          return e.message ??
              tr('Erreur de connexion.', 'Sign-in error.');
      }
    }
    return tr('Erreur inattendue.', 'Unexpected error.');
  }
}
