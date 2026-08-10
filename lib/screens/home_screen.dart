import 'package:flutter/material.dart';

import '../data/app_prefs.dart';
import '../data/ccq_data.dart';
import '../data/outils_registry.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'recherche_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: AppPrefs.favoris,
        builder: (context, _) {
          final List<Outil> favoris = AppPrefs.favoris.ids
              .map(outilParId)
              .whereType<Outil>()
              .toList();
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                sliver: SliverList.list(
                  children: [
                    if (favoris.isNotEmpty)
                      _SectionOutils(
                          titre: 'Favoris',
                          couleur: AppColors.accent,
                          outils: favoris),
                    for (final s in sectionsOutils)
                      _SectionOutils(
                          titre: s.titre,
                          couleur: s.couleur,
                          outils: s.outils),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  void _choisirTheme(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in const [
              (ThemeMode.system, 'Automatique', Icons.brightness_auto),
              (ThemeMode.light, 'Clair', Icons.light_mode),
              (ThemeMode.dark, 'Sombre', Icons.dark_mode),
            ])
              ListTile(
                leading: Icon(e.$3),
                title: Text(e.$2),
                trailing: AppPrefs.theme.value == e.$1
                    ? Icon(Icons.check,
                        color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  AppPrefs.setTheme(e.$1);
                  Navigator.of(ctx).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.engineering,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calculatrice CCQ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5)),
                        Text('Ta boîte à outils de chantier',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Rechercher',
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RechercheScreen())),
                  ),
                  IconButton(
                    tooltip: 'Thème',
                    icon: const Icon(Icons.brightness_6, color: Colors.white),
                    onPressed: () => _choisirTheme(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Taux CCQ officiels · ${CcqData.enVigueurTexte}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionOutils extends StatelessWidget {
  const _SectionOutils({
    required this.titre,
    required this.couleur,
    required this.outils,
  });

  final String titre;
  final Color couleur;
  final List<Outil> outils;

  static const double _hauteur = 106;
  static const double _gap = 10;

  Widget _tuile(BuildContext context, Outil o) {
    return SizedBox(
      height: _hauteur,
      child: ToolCard(
        icon: o.icon,
        title: o.titre,
        subtitle: o.sousTitre,
        color: couleur,
        favori: AppPrefs.favoris.contient(o.id),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: o.builder)),
        onLongPress: () {
          AppPrefs.favoris.basculer(o.id);
          final ajoute = AppPrefs.favoris.contient(o.id);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 1200),
            content: Text(ajoute
                ? '${o.titre} ajouté aux favoris ⭐'
                : '${o.titre} retiré des favoris'),
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> rangs = [];
    for (int i = 0; i < outils.length; i += 2) {
      if (rangs.isNotEmpty) rangs.add(const SizedBox(height: _gap));
      final a = outils[i];
      final b = i + 1 < outils.length ? outils[i + 1] : null;
      rangs.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _tuile(context, a)),
          const SizedBox(width: _gap),
          Expanded(child: b == null ? const SizedBox() : _tuile(context, b)),
        ],
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(titre, color: couleur),
          ...rangs,
        ],
      ),
    );
  }
}
