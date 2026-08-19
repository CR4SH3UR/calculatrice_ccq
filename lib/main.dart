import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/app_prefs.dart';
import 'data/heures_store.dart';
import 'l10n/lang.dart';
import 'screens/home_screen.dart';
import 'services/firebase_boot.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HeuresStore.instance.charger();
  await AppPrefs.charger();
  // N'initialise Firebase que si la config est en place ; sinon l'app reste
  // 100 % locale et l'entrée « Compte » est masquée (voir FirebaseBoot).
  await FirebaseBoot.initialiser();
  runApp(const CalculatriceCcqApp());
}

class CalculatriceCcqApp extends StatelessWidget {
  const CalculatriceCcqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Lang>(
      valueListenable: langue,
      builder: (context, lg, _) => ValueListenableBuilder<ThemeMode>(
        valueListenable: AppPrefs.theme,
        builder: (context, mode, _) => MaterialApp(
          title: 'Calculatrice CCQ',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          locale: Locale(lg == Lang.en ? 'en' : 'fr'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fr'), Locale('en')],
          // La clé liée à la langue force la reconstruction de l'accueil
          // (et de son en-tête const) quand on bascule FR/EN.
          home: HomeScreen(key: ValueKey(lg)),
        ),
      ),
    );
  }
}
