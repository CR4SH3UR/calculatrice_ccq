import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Une convention collective téléchargeable (PDF officiel de la CCQ).
class _Convention {
  const _Convention(this.secteurFr, this.secteurEn, this.sousTitreFr,
      this.sousTitreEn, this.code, this.url, this.taille);
  final String secteurFr, secteurEn;
  final String sousTitreFr, sousTitreEn;
  final String code;
  final String url;
  final String taille;

  String get secteur => tr(secteurFr, secteurEn);
  String get sousTitre => tr(sousTitreFr, sousTitreEn);
}

const String _base =
    'https://www.ccq.org/-/media/Project/Ccq/Ccq-Website/PDF/ConventionsCollectives/2025-2029';

const List<_Convention> _conventions = [
  _Convention('Résidentiel', 'Residential', 'Léger et lourd', 'Light and heavy',
      'residentiel-2025-2029', '$_base/110455-110439-PD5147.pdf', '3,9 Mo'),
  _Convention('Institutionnel-commercial', 'Institutional-commercial',
      'Secteur I.C.', 'I.C. sector', 'ic-2025-2029',
      '$_base/110454-110438-PD5145.pdf', '3,4 Mo'),
  _Convention('Industriel', 'Industrial', 'Usines et procédés',
      'Plants and processes', 'industriel-2025-2029',
      '$_base/110453-110437-PD5144.pdf', '4,6 Mo'),
  _Convention('Génie civil et voirie', 'Civil engineering and roads',
      'Secteur G.C.V.', 'C.E.R. sector', 'genie-civil-2025-2029',
      '$_base/110452-110436-PD5146.pdf', '4,3 Mo'),
];

class ConventionsScreen extends StatefulWidget {
  const ConventionsScreen({super.key});

  @override
  State<ConventionsScreen> createState() => _ConventionsScreenState();
}

class _ConventionsScreenState extends State<ConventionsScreen> {
  final Set<String> _telecharges = {};
  final Set<String> _enCours = {};

  @override
  void initState() {
    super.initState();
    _rafraichir();
  }

  /// Fichier local, distinct par langue (l'anglais et le français sont deux
  /// documents séparés côté CCQ).
  Future<File> _fichier(_Convention c) async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/conventions');
    if (!await d.exists()) await d.create(recursive: true);
    final lang = estAnglais ? 'en' : 'fr';
    return File('${d.path}/${c.code}-$lang.pdf');
  }

  /// URL de téléchargement : ajoute « ?sc_lang=en » en anglais. Tant que la
  /// CCQ n'a pas publié l'anglais, cette URL renvoie le français (repli).
  String _url(_Convention c) => estAnglais ? '${c.url}?sc_lang=en' : c.url;

  Future<void> _rafraichir() async {
    for (final c in _conventions) {
      final f = await _fichier(c);
      if (await f.exists() && await f.length() > 1000) _telecharges.add(c.code);
    }
    if (mounted) setState(() {});
  }

  Future<void> _telecharger(_Convention c) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _enCours.add(c.code));
    try {
      final resp = await http.get(Uri.parse(_url(c)),
          headers: {'User-Agent': 'CalculatriceCCQ'});
      if (resp.statusCode == 200 && resp.bodyBytes.length > 1000) {
        final f = await _fichier(c);
        await f.writeAsBytes(resp.bodyBytes);
        _telecharges.add(c.code);
        messenger.showSnackBar(SnackBar(
            content: Text(
                '${c.secteur} — ${tr('téléchargée, dispo hors ligne.', 'downloaded, available offline.')}')));
      } else {
        messenger.showSnackBar(SnackBar(
            content: Text(
                '${tr('Échec du téléchargement', 'Download failed')} (${resp.statusCode}).')));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(
          content: Text(tr('Téléchargement impossible — vérifie ta connexion.',
              'Download failed — check your connection.'))));
    } finally {
      if (mounted) setState(() => _enCours.remove(c.code));
    }
  }

  Future<void> _ouvrir(_Convention c) async {
    final messenger = ScaffoldMessenger.of(context);
    final f = await _fichier(c);
    final res = await OpenFilex.open(f.path, type: 'application/pdf');
    if (res.type != ResultType.done) {
      messenger.showSnackBar(SnackBar(
          content: Text(tr(
              'Aucun lecteur PDF trouvé — utilise « Partager » pour l\'enregistrer.',
              'No PDF reader found — use « Share » to save it.'))));
    }
  }

  Future<void> _partager(_Convention c) async {
    final f = await _fichier(c);
    await Share.shareXFiles([XFile(f.path, mimeType: 'application/pdf')],
        subject: '${tr('Convention', 'Agreement')} ${c.secteur}');
  }

  Future<void> _supprimer(_Convention c) async {
    final f = await _fichier(c);
    if (await f.exists()) await f.delete();
    if (mounted) setState(() => _telecharges.remove(c.code));
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: tr('Conventions collectives', 'Collective agreements'),
      children: [
        InfoBanner(
          text: tr(
              'Télécharge la convention de ton secteur : elle reste ensuite '
                  'disponible hors ligne dans l\'app. Utilise « Partager » pour '
                  'l\'enregistrer dans tes fichiers ou l\'ouvrir hors de l\'app.',
              'Download your sector\'s agreement: it then stays available '
                  'offline in the app. Use « Share » to save it to your files or '
                  'open it outside the app.'),
          color: AppColors.infos,
          icon: Icons.download_for_offline,
        ),
        if (estAnglais) ...[
          const SizedBox(height: 10),
          const InfoBanner(
            text:
                'The official English 2025-2029 agreements are « coming soon » '
                'from the CCQ. Meanwhile the French version (currently in force) '
                'is provided — the app will pick up the English one '
                'automatically once the CCQ publishes it.',
            color: AppColors.warning,
            icon: Icons.translate,
          ),
        ],
        const SizedBox(height: 16),
        ..._conventions.map((c) => _ConventionCard(
              conv: c,
              telecharge: _telecharges.contains(c.code),
              enCours: _enCours.contains(c.code),
              onTelecharger: () => _telecharger(c),
              onOuvrir: () => _ouvrir(c),
              onPartager: () => _partager(c),
              onSupprimer: () => _supprimer(c),
            )),
        const SizedBox(height: 8),
        InfoBanner(
          text: tr(
              'Conventions collectives 2025-2029 de l\'industrie de la '
                  'construction (CCQ). Documents officiels — en cas d\'écart '
                  'avec l\'app, c\'est la convention qui fait foi.',
              '2025-2029 collective agreements of the construction industry '
                  '(CCQ). Official documents — in case of any discrepancy with '
                  'the app, the agreement prevails.'),
        ),
      ],
    );
  }
}

class _ConventionCard extends StatelessWidget {
  const _ConventionCard({
    required this.conv,
    required this.telecharge,
    required this.enCours,
    required this.onTelecharger,
    required this.onOuvrir,
    required this.onPartager,
    required this.onSupprimer,
  });

  final _Convention conv;
  final bool telecharge;
  final bool enCours;
  final VoidCallback onTelecharger;
  final VoidCallback onOuvrir;
  final VoidCallback onPartager;
  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    final Color onSurf = Theme.of(context).colorScheme.onSurface;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.infos.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.gavel, color: AppColors.infos),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(conv.secteur,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('${conv.sousTitre} · PDF ${conv.taille}',
                          style: TextStyle(
                              fontSize: 12.5,
                              color: onSurf.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                if (telecharge && !enCours)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.offline_pin,
                            size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(tr('hors ligne', 'offline'),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (enCours)
              Row(
                children: [
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 12),
                  Text(tr('Téléchargement…', 'Downloading…'),
                      style: TextStyle(
                          fontSize: 13, color: onSurf.withValues(alpha: 0.7))),
                ],
              )
            else if (telecharge)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: onOuvrir,
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: Text(tr('Ouvrir', 'Open')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: onPartager,
                    icon: const Icon(Icons.ios_share, size: 20),
                    tooltip: tr('Partager / enregistrer', 'Share / save'),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onSupprimer,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: tr('Supprimer', 'Delete'),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: onTelecharger,
                  icon: const Icon(Icons.download, size: 18),
                  label: Text('${tr('Télécharger', 'Download')} (${conv.taille})'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
