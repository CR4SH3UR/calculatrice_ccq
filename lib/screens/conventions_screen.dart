import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Une convention collective téléchargeable (PDF officiel de la CCQ).
class _Convention {
  const _Convention(
      this.secteur, this.sousTitre, this.code, this.url, this.taille);
  final String secteur;
  final String sousTitre;
  final String code; // nom du fichier local
  final String url;
  final String taille;
}

const String _base =
    'https://www.ccq.org/-/media/Project/Ccq/Ccq-Website/PDF/ConventionsCollectives/2025-2029';

const List<_Convention> _conventions = [
  _Convention('Résidentiel', 'Léger et lourd', 'residentiel-2025-2029',
      '$_base/110455-110439-PD5147.pdf', '3,9 Mo'),
  _Convention('Institutionnel-commercial', 'Secteur I.C.', 'ic-2025-2029',
      '$_base/110454-110438-PD5145.pdf', '3,4 Mo'),
  _Convention('Industriel', 'Usines et procédés', 'industriel-2025-2029',
      '$_base/110453-110437-PD5144.pdf', '4,6 Mo'),
  _Convention('Génie civil et voirie', 'Secteur G.C.V.', 'genie-civil-2025-2029',
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

  Future<File> _fichier(_Convention c) async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/conventions');
    if (!await d.exists()) await d.create(recursive: true);
    return File('${d.path}/${c.code}.pdf');
  }

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
      final resp = await http.get(Uri.parse(c.url),
          headers: {'User-Agent': 'CalculatriceCCQ'});
      if (resp.statusCode == 200 && resp.bodyBytes.length > 1000) {
        final f = await _fichier(c);
        await f.writeAsBytes(resp.bodyBytes);
        _telecharges.add(c.code);
        messenger.showSnackBar(SnackBar(
            content: Text('${c.secteur} — téléchargée, dispo hors ligne.')));
      } else {
        messenger.showSnackBar(SnackBar(
            content: Text('Échec du téléchargement (code ${resp.statusCode}).')));
      }
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Téléchargement impossible — vérifie ta connexion.')));
    } finally {
      if (mounted) setState(() => _enCours.remove(c.code));
    }
  }

  Future<void> _ouvrir(_Convention c) async {
    final messenger = ScaffoldMessenger.of(context);
    final f = await _fichier(c);
    final res = await OpenFilex.open(f.path, type: 'application/pdf');
    if (res.type != ResultType.done) {
      messenger.showSnackBar(const SnackBar(
          content: Text(
              'Aucun lecteur PDF trouvé — utilise « Partager » pour l\'enregistrer.')));
    }
  }

  Future<void> _partager(_Convention c) async {
    final f = await _fichier(c);
    await Share.shareXFiles([XFile(f.path, mimeType: 'application/pdf')],
        subject: 'Convention ${c.secteur}');
  }

  Future<void> _supprimer(_Convention c) async {
    final f = await _fichier(c);
    if (await f.exists()) await f.delete();
    if (mounted) setState(() => _telecharges.remove(c.code));
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Conventions collectives',
      children: [
        const InfoBanner(
          text:
              'Télécharge la convention de ton secteur : elle reste ensuite '
              'disponible hors ligne dans l\'app. Utilise « Partager » pour '
              'l\'enregistrer dans tes fichiers ou l\'ouvrir hors de l\'app.',
          color: AppColors.infos,
          icon: Icons.download_for_offline,
        ),
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
        const InfoBanner(
          text:
              'Conventions collectives 2025-2029 de l\'industrie de la '
              'construction (CCQ). Documents officiels — en cas d\'écart avec '
              'l\'app, c\'est la convention qui fait foi.',
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.offline_pin,
                            size: 14, color: AppColors.success),
                        SizedBox(width: 4),
                        Text('hors ligne',
                            style: TextStyle(
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
                  Text('Téléchargement…',
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
                      label: const Text('Ouvrir'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: onPartager,
                    icon: const Icon(Icons.ios_share, size: 20),
                    tooltip: 'Partager / enregistrer',
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onSupprimer,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Supprimer',
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: onTelecharger,
                  icon: const Icon(Icons.download, size: 18),
                  label: Text('Télécharger (${conv.taille})'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
