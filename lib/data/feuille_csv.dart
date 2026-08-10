import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/format.dart';
import 'heures_store.dart';

const List<String> _entetes = [
  'Date',
  'Métier',
  'Secteur',
  'Employeur',
  'H normales',
  'H 1,5×',
  'H 2×',
  'Total h',
  'Taux',
  'Prime',
  'Km',
  'Taux/km',
  'Déplacement',
  'Brut',
  'Total',
  'Note',
];

String _deux(int n) => n.toString().padLeft(2, '0');
String _dateIso(DateTime d) => '${d.year}-${_deux(d.month)}-${_deux(d.day)}';

/// Génère le contenu CSV de la feuille de temps.
///
/// Délimiteur « ; » et décimales à virgule pour s'ouvrir proprement dans
/// Excel en français. Les champs texte sont entre guillemets.
String genererCsvFeuille(List<HeureEntry> entries) {
  String q(String s) => '"${s.replaceAll('"', '""')}"';
  String n(double v) => Fmt.trim(v, maxDecimals: 2);

  final List<HeureEntry> tri = [...entries]
    ..sort((a, b) => a.date.compareTo(b.date));

  final List<String> lignes = [_entetes.join(';')];
  for (final e in tri) {
    lignes.add([
      _dateIso(e.date),
      q(e.metier),
      q(e.secteur),
      q(e.employeur),
      n(e.hNormal),
      n(e.h15),
      n(e.h2),
      n(e.heures),
      n(e.taux),
      n(e.prime),
      n(e.km),
      n(e.tauxKm),
      n(e.deplacement),
      n(e.brut),
      n(e.total),
      q(e.note),
    ].join(';'));
  }
  return lignes.join('\r\n');
}

/// Écrit le CSV dans un fichier temporaire et ouvre la feuille de partage.
/// En cas d'échec, copie le CSV dans le presse-papiers.
Future<void> partagerCsvFeuille(
  BuildContext context,
  List<HeureEntry> entries, {
  String nomFichier = 'feuille_temps.csv',
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final String csv = genererCsvFeuille(entries);
  try {
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/$nomFichier');
    // BOM UTF-8 pour que les accents s'affichent dans Excel.
    await file.writeAsString('\u{FEFF}$csv', encoding: utf8);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Feuille de temps',
    );
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: csv));
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Partage indisponible — CSV copié dans le presse-papiers.'),
      ),
    );
  }
}
