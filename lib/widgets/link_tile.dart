import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/lang.dart';

/// Ouvre [url] dans le navigateur. Si l'ouverture échoue (ex. pas de
/// navigateur), copie le lien dans le presse-papiers et le signale.
Future<void> openUrl(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
  bool ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok) {
    await Clipboard.setData(ClipboardData(text: uri.toString()));
    messenger.showSnackBar(
      SnackBar(
          content:
              Text('${tr('Lien copié', 'Link copied')} : ${uri.toString()}')),
    );
  }
}

/// Carte-lien : icône + titre + sous-titre + flèche « ouvrir ». Ouvre [url].
class LinkTile extends StatelessWidget {
  const LinkTile({
    super.key,
    required this.icon,
    required this.title,
    required this.url,
    this.subtitle,
    this.color,
  });

  final IconData icon;
  final String title;
  final String url;
  final String? subtitle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => openUrl(context, url),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: c, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14.5)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6))),
                    ],
                  ],
                ),
              ),
              Icon(Icons.open_in_new,
                  size: 18,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
