import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/backup.dart';
import '../data/heures_store.dart';
import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Sauvegarde et restauration de la feuille de temps (sans nuage) :
/// export d'un fichier JSON partageable + restauration par collage de texte.
class SauvegardeScreen extends StatefulWidget {
  const SauvegardeScreen({super.key});

  @override
  State<SauvegardeScreen> createState() => _SauvegardeScreenState();
}

class _SauvegardeScreenState extends State<SauvegardeScreen> {
  final _importCtrl = TextEditingController();

  @override
  void dispose() {
    _importCtrl.dispose();
    super.dispose();
  }

  Future<void> _restaurer() async {
    final BackupResult res = lireBackup(_importCtrl.text);
    final messenger = ScaffoldMessenger.of(context);
    if (!res.reussi) {
      messenger.showSnackBar(SnackBar(content: Text(res.erreur!)));
      return;
    }
    final int actuelles = HeuresStore.instance.entries.length;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Restaurer la sauvegarde ?', 'Restore the backup?')),
        content: Text(tr(
            'Cela remplacera tes $actuelles entrée(s) actuelle(s) par les '
                '${res.entries.length} de la sauvegarde. Cette action ne peut '
                'pas être annulée.',
            'This will replace your $actuelles current entr${actuelles == 1 ? 'y' : 'ies'} '
                'with the ${res.entries.length} from the backup. This cannot be '
                'undone.')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr('Annuler', 'Cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr('Restaurer', 'Restore'))),
        ],
      ),
    );
    if (ok != true) return;
    await HeuresStore.instance.remplacerTout(res.entries);
    _importCtrl.clear();
    messenger.showSnackBar(SnackBar(
        content: Text(
            '${res.entries.length} ${tr('entrée(s) restaurée(s).', 'entr${res.entries.length == 1 ? 'y' : 'ies'} restored.')}')));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HeuresStore.instance,
      builder: (context, _) {
        final int n = HeuresStore.instance.entries.length;
        return ToolScaffold(
          title: tr('Sauvegarde', 'Backup'),
          children: [
            InfoBanner(
              text: tr(
                  'Garde tes heures en sécurité. Exporte un fichier de '
                      'sauvegarde (à envoyer par courriel ou à garder dans tes '
                      'fichiers), puis restaure-le sur un autre téléphone.',
                  'Keep your hours safe. Export a backup file (email it or keep '
                      'it in your files), then restore it on another phone.'),
              color: AppColors.infos,
              icon: Icons.backup,
            ),
            const SizedBox(height: 18),
            SectionTitle(tr('Exporter', 'Export'), color: AppColors.paie),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '$n ${tr('journée(s) dans ta feuille de temps', 'day(s) in your timesheet')}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                        tr(
                            'Le fichier .json contient toutes tes entrées. '
                                'Garde-le précieusement.',
                            'The .json file holds all your entries. Keep it '
                                'safe.'),
                        style: TextStyle(
                            fontSize: 12.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6))),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: n == 0
                                ? null
                                : () => partagerBackup(
                                    context, HeuresStore.instance.entries),
                            icon: const Icon(Icons.ios_share, size: 18),
                            label: Text(tr('Exporter', 'Export')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filledTonal(
                          onPressed: n == 0
                              ? null
                              : () {
                                  Clipboard.setData(ClipboardData(
                                      text: genererBackupJson(
                                          HeuresStore.instance.entries)));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(tr('Sauvegarde copiée.',
                                            'Backup copied.'))),
                                  );
                                },
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: tr('Copier', 'Copy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SectionTitle(tr('Restaurer', 'Restore'), color: AppColors.paie),
            const SizedBox(height: 8),
            TextField(
              controller: _importCtrl,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText: tr('Colle ici le contenu d\'une sauvegarde…',
                    'Paste a backup\'s contents here…'),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _restaurer,
              icon: const Icon(Icons.restore, size: 18),
              label: Text(tr('Restaurer', 'Restore')),
            ),
            const SizedBox(height: 16),
            InfoBanner(
              text: tr(
                  'La restauration remplace la feuille de temps actuelle. '
                      'Exporte d\'abord une sauvegarde si tu veux garder tes '
                      'entrées actuelles.',
                  'Restoring replaces the current timesheet. Export a backup '
                      'first if you want to keep your current entries.'),
              color: AppColors.warning,
            ),
          ],
        );
      },
    );
  }
}
