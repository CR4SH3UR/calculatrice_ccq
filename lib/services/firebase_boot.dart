import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import 'auth_service.dart';
import 'cloud_sync.dart';

/// Amorçage défensif de Firebase.
///
/// Si la config Firebase n'est pas renseignée (gabarit `firebase_options.dart`
/// encore en « REPLACE_ME »), on n'initialise RIEN : l'app reste 100 % locale
/// et l'entrée « Compte » est masquée. Une fois la vraie config en place,
/// [pret] passe à vrai et le login apparaît.
class FirebaseBoot {
  const FirebaseBoot._();

  /// Vrai quand Firebase est initialisé et prêt (donc login disponible).
  static final ValueNotifier<bool> pret = ValueNotifier(false);

  static Future<void> initialiser() async {
    if (!DefaultFirebaseOptions.estConfigure) {
      // Pas de config : on ne touche pas à Firebase. App locale, login masqué.
      return;
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      pret.value = true;

      // Démarre la synchro si une session est déjà ouverte, et suit les
      // changements d'état de connexion.
      if (AuthService.instance.connecte) {
        await CloudSync.instance.demarrer();
      }
      AuthService.instance.changements.listen((utilisateur) {
        if (utilisateur != null) {
          CloudSync.instance.demarrer();
        } else {
          CloudSync.instance.arreter();
        }
      });
    } catch (e) {
      // Init impossible (config incomplète, réseau…) : on reste en mode local.
      pret.value = false;
      debugPrint('Firebase non initialisé : $e');
    }
  }
}
