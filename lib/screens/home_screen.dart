import 'package:flutter/material.dart';

import '../data/app_prefs.dart';
import '../data/ccq_data.dart';
import '../data/outils_registry.dart';
import '../data/profil.dart';
import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'profil_screen.dart';
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
                    const _CarteAccueil(),
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
              (ThemeMode.system, 'Automatique', 'Automatic', Icons.brightness_auto),
              (ThemeMode.light, 'Clair', 'Light', Icons.light_mode),
              (ThemeMode.dark, 'Sombre', 'Dark', Icons.dark_mode),
            ])
              ListTile(
                leading: Icon(e.$4),
                title: Text(tr(e.$2, e.$3)),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Calculatrice CCQ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5)),
                        Text(
                            tr('Ta boîte à outils de chantier',
                                'Your jobsite toolbox'),
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: tr('Mon profil', 'My profile'),
                    icon: const Icon(Icons.account_circle_outlined,
                        color: Colors.white),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ProfilScreen())),
                  ),
                  IconButton(
                    tooltip: tr('Rechercher', 'Search'),
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RechercheScreen())),
                  ),
                  IconButton(
                    tooltip: tr('English', 'Français'),
                    icon: Text(estAnglais ? 'FR' : 'EN',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14)),
                    onPressed: () =>
                        AppPrefs.setLangue(estAnglais ? Lang.fr : Lang.en),
                  ),
                  IconButton(
                    tooltip: tr('Thème', 'Theme'),
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
                        '${tr('Taux CCQ officiels', 'Official CCQ rates')} · ${CcqData.enVigueurTexte}',
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

/// Carte d'accueil : résumé du profil + infos pertinentes (prochaine hausse
/// de taux, alerte carte ASP). Se met à jour quand le profil change.
class _CarteAccueil extends StatelessWidget {
  const _CarteAccueil();

  Widget _ligne(BuildContext context, IconData icon, Color color, String texte) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texte,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Profil>(
      valueListenable: AppPrefs.profil,
      builder: (context, p, _) {
        final onSurf = Theme.of(context).colorScheme.onSurface;

        // Secteur du profil (sinon I.C. par défaut) pour la prochaine hausse.
        Secteur secteur = Secteur.institutionnelCommercial;
        if (p.secteur.isNotEmpty) {
          for (final s in Secteur.values) {
            if (s.name == p.secteur) {
              secteur = s;
              break;
            }
          }
        }
        final futures = CcqData.haussesFutures(secteur);
        final prochaine = futures.isEmpty ? null : futures.first;

        String? metierLabel;
        if (p.metier.isNotEmpty) {
          final m = CcqData.metiers.where((x) => x.nom == p.metier);
          if (m.isNotEmpty) metierLabel = m.first.nomAffiche;
        }
        final sousTitre = [
          if (p.tauxHoraire != null) '${Fmt.money(p.tauxHoraire!)}/h',
          if (p.region.isNotEmpty) p.region,
        ].join(' · ');
        final int? aspJours = p.joursAvantAsp;

        return Card(
          margin: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilScreen())),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.paie.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_circle,
                            color: AppColors.paie, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                metierLabel ??
                                    (p.estVide
                                        ? tr('Compléter mon profil',
                                            'Complete my profile')
                                        : tr('Mon profil', 'My profile')),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 15)),
                            Text(
                                sousTitre.isNotEmpty
                                    ? sousTitre
                                    : tr('Métier, taux, contacts d\'urgence…',
                                        'Trade, rate, emergency contacts…'),
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: onSurf.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: onSurf.withValues(alpha: 0.3)),
                    ],
                  ),
                ),
              ),
              if (prochaine != null || (aspJours != null && aspJours <= 60))
                Divider(
                    height: 1, color: onSurf.withValues(alpha: 0.08)),
              if (prochaine != null)
                _ligne(
                    context,
                    Icons.trending_up,
                    AppColors.success,
                    '${tr('Prochaine hausse', 'Next raise')} : '
                        '${Fmt.dateFr(prochaine.date)} · +${Fmt.trim(prochaine.pct)} %'),
              if (aspJours != null && aspJours <= 60)
                _ligne(
                    context,
                    Icons.event_available,
                    aspJours < 0 ? AppColors.danger : AppColors.warning,
                    aspJours < 0
                        ? tr('Ta carte ASP est expirée',
                            'Your ASP card has expired')
                        : '${tr('Carte ASP expire dans', 'ASP card expires in')} $aspJours ${tr('jours', 'days')}'),
            ],
          ),
        );
      },
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
        title: outilTitre(o),
        subtitle: outilSousTitre(o),
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
                ? '${outilTitre(o)} ${tr('ajouté aux favoris', 'added to favorites')}'
                : '${outilTitre(o)} ${tr('retiré des favoris', 'removed from favorites')}'),
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
          SectionTitle(sectionTitre(titre), color: couleur),
          ...rangs,
        ],
      ),
    );
  }
}
