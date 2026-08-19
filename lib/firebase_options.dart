// GABARIT de configuration Firebase — À REMPLACER par la vraie config.
//
// Génère la vraie version (qui écrase ce fichier) avec :
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=calculatriceccq
//
// Tant que les valeurs restent « REPLACE_ME », `estConfigure` est faux :
// l'app démarre normalement, la connexion (login) est simplement masquée et
// AUCUNE donnée n'est envoyée sur Internet. Voir docs/FIREBASE_LOGIN.md.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Options Firebase par plateforme (gabarit).
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static const String _placeholder = 'REPLACE_ME';

  /// Vrai seulement quand la vraie config a été renseignée (via flutterfire).
  /// Tant que c'est faux, l'app reste 100 % locale (login masqué).
  static bool get estConfigure => web.apiKey != _placeholder;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC77zdWY8ZoGZ2dfmfY9TxGtW0XAHwjf0c',
    appId: '1:1038075848555:web:91c2defb4ead17f5650e2e',
    messagingSenderId: '1038075848555',
    projectId: 'calculatriceccq',
    authDomain: 'calculatriceccq.firebaseapp.com',
    storageBucket: 'calculatriceccq.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCw0onpXpB9AkTnubuAgxVS6Kqsfmec7sA',
    appId: '1:1038075848555:android:c064ac6fd174d058650e2e',
    messagingSenderId: '1038075848555',
    projectId: 'calculatriceccq',
    storageBucket: 'calculatriceccq.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _placeholder,
    appId: _placeholder,
    messagingSenderId: _placeholder,
    projectId: 'calculatriceccq',
    storageBucket: 'calculatriceccq.appspot.com',
    iosBundleId: 'org.calculatriceccq.app',
  );
}
