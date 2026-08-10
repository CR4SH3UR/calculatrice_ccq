import 'package:flutter/material.dart';

import 'data/app_prefs.dart';
import 'data/heures_store.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HeuresStore.instance.charger();
  await AppPrefs.charger();
  runApp(const CalculatriceCcqApp());
}

class CalculatriceCcqApp extends StatelessWidget {
  const CalculatriceCcqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppPrefs.theme,
      builder: (context, mode, _) => MaterialApp(
        title: 'Calculatrice CCQ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        home: const HomeScreen(),
      ),
    );
  }
}
