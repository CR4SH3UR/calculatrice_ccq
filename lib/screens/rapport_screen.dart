import 'package:flutter/material.dart';

import '../data/feuille_csv.dart';
import '../data/heures_store.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

/// Rapport d'heures : filtre la feuille de temps par période et par employeur,
/// affiche les totaux et permet l'export CSV du sous-ensemble.
class RapportHeuresScreen extends StatefulWidget {
  const RapportHeuresScreen({super.key});

  @override
  State<RapportHeuresScreen> createState() => _RapportHeuresScreenState();
}

class _RapportHeuresScreenState extends State<RapportHeuresScreen> {
  String _periode = 'Semaine';
  String _employeur = 'Tous';

  bool _dansPeriode(DateTime d) {
    final DateTime now = DateTime.now();
    switch (_periode) {
      case 'Semaine':
        return !d.isBefore(debutSemaine(now));
      case 'Mois':
        return d.year == now.year && d.month == now.month;
      case '30 j':
        return !d.isBefore(now.subtract(const Duration(days: 30)));
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HeuresStore.instance,
      builder: (context, _) {
        final List<HeureEntry> toutes = HeuresStore.instance.entries;

        // Liste des employeurs connus (pour le filtre).
        final List<String> employeurs = {
          for (final e in toutes)
            if (e.employeur.trim().isNotEmpty) e.employeur.trim()
        }.toList()
          ..sort();

        // Application des filtres.
        final List<HeureEntry> filtrees = toutes.where((e) {
          if (!_dansPeriode(e.date)) return false;
          if (_employeur != 'Tous' && e.employeur.trim() != _employeur) {
            return false;
          }
          return true;
        }).toList();

        // Totaux.
        double hN = 0, h15 = 0, h2 = 0, brut = 0, depl = 0, total = 0, km = 0;
        for (final e in filtrees) {
          hN += e.hNormal;
          h15 += e.h15;
          h2 += e.h2;
          brut += e.brut;
          depl += e.deplacement;
          total += e.total;
          km += e.km;
        }
        final double heures = hN + h15 + h2;

        return ToolScaffold(
          title: 'Rapport d\'heures',
          children: [
            Text('Période',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.75))),
            const SizedBox(height: 8),
            ChoiceSegments(
              options: const ['Semaine', 'Mois', '30 j', 'Tout'],
              selected: _periode,
              onChanged: (v) => setState(() => _periode = v),
            ),
            if (employeurs.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Employeur',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.75))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _employeur,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: ['Tous', ...employeurs]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) =>
                    v == null ? null : setState(() => _employeur = v),
              ),
            ],
            const SizedBox(height: 16),
            if (filtrees.isEmpty)
              const InfoBanner(
                text: 'Aucune heure pour cette sélection.',
                color: AppColors.infos,
              )
            else ...[
              ResultCard(
                label: 'Total de la période',
                value: Fmt.money(total),
                color: AppColors.paie,
                icon: Icons.summarize,
                details: [
                  ResultLine('Jours travaillés', '${filtrees.length}'),
                  ResultLine('Heures totales', '${Fmt.trim(heures)} h',
                      strong: true),
                  if (h15 > 0) ResultLine('  dont 1,5×', '${Fmt.trim(h15)} h'),
                  if (h2 > 0) ResultLine('  dont 2×', '${Fmt.trim(h2)} h'),
                  ResultLine('Salaire brut', Fmt.money(brut)),
                  if (depl > 0)
                    ResultLine('Déplacement (${Fmt.trim(km)} km)',
                        Fmt.money(depl)),
                  ResultLine('Total à recevoir', Fmt.money(total),
                      strong: true),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => partagerCsvFeuille(context, filtrees),
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: const Text('Exporter CSV'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SectionTitle('Détail', color: AppColors.paie),
              const SizedBox(height: 4),
              ...filtrees.map((e) => _LigneRapport(entry: e)),
            ],
            const SizedBox(height: 12),
            const InfoBanner(
              text:
                  'Le CSV s\'ouvre dans Excel ou Google Sheets. Montants bruts, '
                  'avant impôts et retenues.',
            ),
          ],
        );
      },
    );
  }
}

class _LigneRapport extends StatelessWidget {
  const _LigneRapport({required this.entry});
  final HeureEntry entry;

  @override
  Widget build(BuildContext context) {
    final Color onSurf = Theme.of(context).colorScheme.onSurface;
    final String sousTitre = [
      if (entry.employeur.trim().isNotEmpty) entry.employeur.trim(),
      if (entry.metier.trim().isNotEmpty) entry.metier.trim(),
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Fmt.dateFr(entry.date),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14.5)),
                  if (sousTitre.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(sousTitre,
                        style: TextStyle(
                            fontSize: 12.5,
                            color: onSurf.withValues(alpha: 0.6))),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${Fmt.trim(entry.heures)} h',
                    style: TextStyle(
                        fontSize: 13,
                        color: onSurf.withValues(alpha: 0.7))),
                const SizedBox(height: 2),
                Text(Fmt.money(entry.total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: AppColors.paie)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
