import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/link_tile.dart';

/// Version affichée de l'app (à garder alignée avec `pubspec.yaml`).
const String kAppVersion = '1.1.0';

/// Page « À propos » : identité de l'app, version, crédits et sources.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurf = Theme.of(context).colorScheme.onSurface;
    return ToolScaffold(
      title: tr('À propos', 'About'),
      children: [
        const SizedBox(height: 8),
        // ── En-tête : logo + nom + version ──────────────────────────────
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppTheme.headerGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.engineering,
                    color: Colors.white, size: 46),
              ),
              const SizedBox(height: 14),
              const Text('Calculatrice CCQ',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text('v$kAppVersion',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onSurf.withValues(alpha: 0.6))),
              const SizedBox(height: 6),
              Text(tr('Ta boîte à outils de chantier', 'Your jobsite toolbox'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13.5, color: onSurf.withValues(alpha: 0.7))),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Crédit ──────────────────────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.handyman, color: AppColors.accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('Fait par', 'Made by'),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: onSurf.withValues(alpha: 0.6))),
                      const SizedBox(height: 2),
                      const Text('Alexandre Dickie',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Description + avertissement ─────────────────────────────────
        SectionTitle(tr('À propos de l\'app', 'About the app'),
            color: AppColors.infos),
        const SizedBox(height: 8),
        InfoBanner(
          text: tr(
              'Calculatrice CCQ regroupe des outils de chantier et des infos '
                  'utiles aux travailleurs de la construction du Québec : paie, '
                  'calculs, taux par métier, MÉDIC, sécurité, conventions et plus.',
              'Calculatrice CCQ bundles jobsite tools and useful info for Quebec '
                  'construction workers: pay, calculations, rates by trade, MÉDIC, '
                  'safety, agreements and more.'),
          icon: Icons.construction,
          color: AppColors.infos,
        ),
        const SizedBox(height: 8),
        InfoBanner(
          text: tr(
              'Outil NON officiel, sans lien avec la CCQ. Les chiffres sont '
                  'indicatifs : en cas d\'écart, la convention collective, les '
                  'bulletins officiels et ccq.org font foi.',
              'UNofficial tool, not affiliated with the CCQ. Figures are '
                  'indicative: in case of any discrepancy, the collective '
                  'agreement, official bulletins and ccq.org prevail.'),
          icon: Icons.info_outline,
          color: AppColors.warning,
        ),
        const SizedBox(height: 16),

        // ── Liens ───────────────────────────────────────────────────────
        SectionTitle(tr('Liens', 'Links'), color: AppColors.infos),
        LinkTile(
          icon: Icons.code,
          title: tr('Code source (GitHub)', 'Source code (GitHub)'),
          subtitle: 'github.com/CR4SH3UR/calculatrice_ccq',
          url: 'https://github.com/CR4SH3UR/calculatrice_ccq',
          color: AppColors.infos,
        ),
        LinkTile(
          icon: Icons.language,
          title: tr('Site officiel de la CCQ', 'Official CCQ website'),
          subtitle: 'ccq.org',
          url: 'https://www.ccq.org',
          color: AppColors.infos,
        ),
        const SizedBox(height: 18),
        Center(
          child: Text('© 2026 Alexandre Dickie',
              style: TextStyle(
                  fontSize: 12, color: onSurf.withValues(alpha: 0.5))),
        ),
      ],
    );
  }
}
