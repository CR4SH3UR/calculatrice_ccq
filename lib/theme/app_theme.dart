import 'package:flutter/material.dart';

/// Palette et thèmes de l'application.
///
/// Style « moderne épuré » : Material 3, propre et coloré, avec une
/// identité chantier (bleu professionnel + accent orange sécurité).
class AppColors {
  const AppColors._();

  /// Bleu « acier / CCQ » — couleur principale.
  static const Color primary = Color(0xFF0B63CE);
  static const Color primaryDark = Color(0xFF0A4EA3);

  /// Orange « sécurité chantier » — accent des actions et résultats.
  static const Color accent = Color(0xFFFF7A1A);
  static const Color accentSoft = Color(0xFFFFB067);

  /// Couleurs sémantiques des sections (une teinte par catégorie).
  static const Color paie = Color(0xFF2E7D32); // vert argent
  static const Color chantier = Color(0xFF0B63CE); // bleu
  static const Color charpente = Color(0xFFB26A00); // bois / ambre
  static const Color infos = Color(0xFF6A3DB8); // mauve
  static const Color syndicat = Color(0xFF00796B); // sarcelle
  static const Color medic = Color(0xFFC2185B); // rose / santé
  static const Color materiaux = Color(0xFF6D4C41); // brun / matériaux

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFC77700);
  static const Color danger = Color(0xFFC62828);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: isDark ? const Color(0xFF6AA9FF) : AppColors.primary,
      secondary: AppColors.accent,
      tertiary: AppColors.charpente,
    );

    final Color scaffold =
        isDark ? const Color(0xFF0E1116) : const Color(0xFFF4F6FB);
    final Color card = isDark ? const Color(0xFF171B22) : Colors.white;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFF0B1B33).withValues(alpha: 0.06),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF0E1116) : const Color(0xFFF4F6FB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.outline.withValues(alpha: 0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.15),
        thickness: 1,
      ),
    );
  }

  /// Dégradé d'en-tête utilisé sur l'accueil.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );
}
