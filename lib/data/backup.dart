import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/lang.dart';
import 'heures_store.dart';

const String _appTag = 'calculatrice_ccq';
const String _typeTag = 'feuille_temps';
const int _versionBackup = 1;

/// Encode toute la feuille de temps en JSON de sauvegarde.
String genererBackupJson(List<HeureEntry> entries) {
  return const JsonEncoder.withIndent('  ').convert({
    'app': _appTag,
    'type': _typeTag,
    'version': _versionBackup,
    'date': DateTime.now().toIso8601String(),
    'entries': entries.map((e) => e.toJson()).toList(),
  });
}

/// Résultat d'une lecture de sauvegarde.
class BackupResult {
  const BackupResult.ok(this.entries)
      : erreur = null;
  const BackupResult.echec(this.erreur) : entries = const [];

  final List<HeureEntry> entries;
  final String? erreur;

  bool get reussi => erreur == null;
}

/// Décode un texte de sauvegarde en liste d'entrées (ou une erreur lisible).
BackupResult lireBackup(String raw) {
  if (raw.trim().isEmpty) {
    return const BackupResult.echec('Aucun texte à restaurer.');
  }
  try {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return const BackupResult.echec('Format non reconnu.');
    }
    if (decoded['app'] != _appTag || decoded['type'] != _typeTag) {
      return const BackupResult.echec(
          'Ce fichier n\'est pas une sauvegarde de la feuille de temps.');
    }
    final Object? liste = decoded['entries'];
    if (liste is! List) {
      return const BackupResult.echec('Aucune entrée dans la sauvegarde.');
    }
    final entries = liste
        .map((e) => HeureEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return BackupResult.ok(entries);
  } catch (_) {
    return const BackupResult.echec('Texte illisible (JSON invalide).');
  }
}

/// Écrit la sauvegarde dans un fichier et ouvre la feuille de partage.
/// Copie dans le presse-papiers si le partage échoue.
Future<void> partagerBackup(
  BuildContext context,
  List<HeureEntry> entries,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final String json = genererBackupJson(entries);
  try {
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/sauvegarde_heures.json');
    await file.writeAsString(json, encoding: utf8);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: tr('Sauvegarde — feuille de temps', 'Backup — timesheet'),
    );
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: json));
    messenger.showSnackBar(
      SnackBar(
        content: Text(tr(
            'Partage indisponible — sauvegarde copiée dans le presse-papiers.',
            'Sharing unavailable — backup copied to the clipboard.')),
      ),
    );
  }
}
