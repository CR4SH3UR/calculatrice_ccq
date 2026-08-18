import 'package:flutter/foundation.dart';

/// Langue de l'interface.
enum Lang { fr, en }

/// Langue active de l'app. Pilotée et persistée par `AppPrefs`; lue par [tr].
final ValueNotifier<Lang> langue = ValueNotifier(Lang.fr);

bool get estAnglais => langue.value == Lang.en;

/// Traduction « en place » : renvoie [fr] ou [en] selon la langue active.
///
/// Exemple : `Text(tr('Calculateur de paie', 'Pay calculator'))`.
/// L'arbre de widgets se reconstruit quand la langue change (voir `main.dart`).
String tr(String fr, String en) => langue.value == Lang.en ? en : fr;
