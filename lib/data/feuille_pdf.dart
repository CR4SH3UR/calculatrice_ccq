import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/format.dart';
import 'heures_store.dart';

/// Génère un PDF de la feuille de temps, groupé par semaine avec totaux.
Future<Uint8List> genererFeuillePdf(List<HeureEntry> entries) async {
  final doc = pw.Document();

  final Map<DateTime, List<HeureEntry>> parSem = {};
  for (final e in entries) {
    parSem.putIfAbsent(debutSemaine(e.date), () => []).add(e);
  }
  final semaines = parSem.keys.toList()..sort((a, b) => b.compareTo(a));

  double gHeures = 0, gBrut = 0, gDep = 0;
  for (final e in entries) {
    gHeures += e.heures;
    gBrut += e.brut;
    gDep += e.deplacement;
  }

  const bleu = PdfColor.fromInt(0xFF0B63CE);
  final gras = pw.TextStyle(fontWeight: pw.FontWeight.bold);

  String det(HeureEntry e) => [
        if (e.metier.isNotEmpty) e.metier,
        if (e.employeur.isNotEmpty) e.employeur,
        if (e.note.isNotEmpty) e.note,
      ].join(' — ');

  String heuresDetail(HeureEntry e) => [
        if (e.hNormal > 0) '${Fmt.trim(e.hNormal)}×1',
        if (e.h15 > 0) '${Fmt.trim(e.h15)}×1,5',
        if (e.h2 > 0) '${Fmt.trim(e.h2)}×2',
      ].join('  ');

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(28),
      build: (ctx) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Feuille de temps',
                style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: bleu)),
            pw.Text('Calculatrice CCQ',
                style: const pw.TextStyle(
                    fontSize: 11, color: PdfColors.grey600)),
          ],
        ),
        pw.Divider(color: bleu, thickness: 1.5),
        pw.SizedBox(height: 6),
        for (final s in semaines) ...[
          pw.SizedBox(height: 10),
          _enteteSemaine(s, parSem[s]!, gras, bleu),
          pw.SizedBox(height: 4),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: bleu),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
            },
            headers: ['Date', 'Détail', 'Heures', 'Taux', 'Brut', 'Dépl.'],
            data: [
              for (final e in (parSem[s]!..sort((a, b) => a.date.compareTo(b.date))))
                [
                  Fmt.dateFr(e.date),
                  det(e),
                  heuresDetail(e),
                  '${Fmt.money(e.taux)}/h',
                  Fmt.money(e.brut),
                  e.deplacement > 0 ? Fmt.money(e.deplacement) : '',
                ],
            ],
          ),
        ],
        pw.SizedBox(height: 14),
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
            pw.Text(
              '${Fmt.trim(gHeures)} h   ·   Brut ${Fmt.money(gBrut)}'
              '${gDep > 0 ? '   ·   Déplacement ${Fmt.money(gDep)}' : ''}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: bleu),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text('Brut + indemnité de congés 13 % : ${Fmt.money(gBrut * 1.13)}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _enteteSemaine(
    DateTime s, List<HeureEntry> list, pw.TextStyle gras, PdfColor bleu) {
  final fin = s.add(const Duration(days: 6));
  double h = 0, b = 0;
  for (final e in list) {
    h += e.heures;
    b += e.brut;
  }
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text('Semaine du ${Fmt.dateFr(s)} au ${Fmt.dateFr(fin)}', style: gras),
      pw.Text('${Fmt.trim(h)} h · ${Fmt.money(b)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: bleu)),
    ],
  );
}
