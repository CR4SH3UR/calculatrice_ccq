// Smoke tests de base pour la Calculatrice CCQ.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calculatrice_ccq/data/ccq_data.dart';
import 'package:calculatrice_ccq/data/backup.dart';
import 'package:calculatrice_ccq/data/feuille_csv.dart';
import 'package:calculatrice_ccq/data/heures_store.dart';
import 'package:calculatrice_ccq/l10n/lang.dart';
import 'package:calculatrice_ccq/main.dart';
import 'package:calculatrice_ccq/screens/calculs_plus.dart';
import 'package:calculatrice_ccq/screens/documentation_screen.dart';
import 'package:calculatrice_ccq/screens/paie_screens.dart';
import 'package:calculatrice_ccq/screens/retraite_screen.dart';
import 'package:calculatrice_ccq/screens/securite_plus.dart';
import 'package:calculatrice_ccq/services/ccq_api_client.dart';
import 'package:calculatrice_ccq/utils/format.dart';
import 'package:calculatrice_ccq/widgets/common.dart';
import 'package:calculatrice_ccq/widgets/metier_picker.dart';

void main() {
  testWidgets('L\'accueil affiche le titre et les 4 sections',
      (WidgetTester tester) async {
    // Largeur d'un téléphone (380) pour attraper tout débordement de la
    // grille, et fenêtre haute pour que les 4 sections soient rendues
    // (sinon le rendu paresseux du CustomScrollView en laisse hors écran).
    tester.view.physicalSize = const Size(380, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CalculatriceCcqApp());
    await tester.pumpAndSettle();

    expect(find.text('Calculatrice CCQ'), findsOneWidget);
    expect(find.text('Paie & salaire'), findsOneWidget);
    expect(find.text('Calculs de chantier'), findsOneWidget);
    expect(find.text('Charpente & finition'), findsOneWidget);
    expect(find.text('Infos pour les gars'), findsOneWidget);
  });

  testWidgets('Bascule de langue : l\'accueil passe FR → EN',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(() => langue.value = Lang.fr); // ne pas polluer les autres tests

    langue.value = Lang.fr;
    await tester.pumpWidget(const CalculatriceCcqApp());
    await tester.pumpAndSettle();
    expect(find.text('Paie & salaire'), findsOneWidget);
    expect(find.text('Calculateur de paie'), findsOneWidget);

    langue.value = Lang.en;
    await tester.pumpAndSettle();
    expect(find.text('Pay & wages'), findsOneWidget);
    expect(find.text('Pay calculator'), findsOneWidget);
    expect(find.text('Paie & salaire'), findsNothing);
  });

  testWidgets(
      'Documentation en anglais : le garde-fou valide toutes les clés '
      'et le rendu passe en anglais', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(() => langue.value = Lang.fr);

    langue.value = Lang.en;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr'), Locale('en')],
      home: const DocumentationScreen(),
    ));
    // L'assert dans DocumentationScreen.build parcourt toutes les catégories
    // et tous les articles : une clé EN manquante ferait échouer ce pump.
    await tester.pumpAndSettle();

    expect(find.text('Official documents & sites'), findsOneWidget);
    expect(find.text('Documents & sites officiels'), findsNothing);
  });

  testWidgets('Le titre de section colle à ses tuiles',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CalculatriceCcqApp());
    await tester.pumpAndSettle();

    final double titreBas =
        tester.getBottomLeft(find.text('Paie & salaire')).dy;
    final double tuileHaut =
        tester.getTopLeft(find.byType(ToolCard).first).dy;
    final double gap = tuileHaut - titreBas;
    // ignore: avoid_print
    print('GAP titre→tuile = $gap px');
    expect(gap, lessThan(16));
  });

  testWidgets(
      'Le bloc de tuiles n\'a pas d\'espace fantôme '
      '(non-régression : ex-bug GridView shrinkWrap)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CalculatriceCcqApp());
    await tester.pumpAndSettle();

    // Tuile 0 = 1re rangée gauche ; tuile 2 = 2e rangée gauche (même colonne).
    // Une tuile fait EXACTEMENT 106 px de haut, et l'écart entre deux rangées
    // = 106 + 10 (gap) = 116 px — pas d'espace fantôme (ex-bug GridView
    // shrinkWrap), quel que soit le nombre d'outils.
    final t0 = tester.getRect(find.byType(ToolCard).at(0));
    final t2 = tester.getRect(find.byType(ToolCard).at(2));
    // ignore: avoid_print
    print('Hauteur tuile = ${t0.height} px · écart rangées = ${t2.top - t0.top} px');
    expect(t0.height, closeTo(106, 1));
    expect(t2.top - t0.top, closeTo(116, 1));
  });

  testWidgets('Le calculateur de paie calcule un brut',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CalculateurPaieScreen()));
    await tester.pumpAndSettle();

    // Mode « Mon taux » : entrer 40 $/h.
    await tester.enterText(find.byType(TextField).first, '40');
    await tester.pumpAndSettle();

    // 40 $/h × 40 h normales (valeur par défaut) = 1 600 $.
    expect(find.textContaining('1 600'), findsWidgets);
  });

  test('Conversion de pouces décimaux en fraction', () {
    expect(Fmt.inchesToFraction(3.375), '3 3/8 po');
    expect(Fmt.inchesToFraction(0.5), '1/2 po');
    expect(Fmt.inchesToFraction(2.0), '2 po');
  });

  test('Formatage monétaire à la québécoise', () {
    expect(Fmt.money(1234.5), '1 234,50 \$');
    expect(Fmt.money(0), '0,00 \$');
  });

  group('Moteur de taux CCQ (données officielles)', () {
    Metier elec() =>
        CcqData.metiers.firstWhere((m) => m.nom == 'Électricien');

    test('Taux de compagnon actuel — I.C.', () {
      final r = CcqData.tauxCompagnon(elec(), Secteur.institutionnelCommercial,
          on: DateTime(2026, 8, 10));
      expect(r, closeTo(50.79, 0.001));
    });

    test('Prochains taux : 2 hausses à venir, +5 % le 25 avril 2027', () {
      final futures = CcqData.haussesFutures(Secteur.institutionnelCommercial,
          on: DateTime(2026, 8, 10));
      expect(futures.length, 2);
      expect(futures.first.date, DateTime(2027, 4, 25));

      final apres2027 = CcqData.tauxCompagnon(
          elec(), Secteur.institutionnelCommercial,
          on: DateTime(2027, 6, 1));
      expect(apres2027, closeTo(50.79 * 1.05, 0.001)); // ≈ 53,33 $
    });

    test('Les grilles ont des taux distincts par convention', () {
      final m = elec();
      expect(m.baseCompagnon(Secteur.residentielLeger), 47.85);
      expect(m.baseCompagnon(Secteur.residentielLourd), 50.20);
      expect(m.baseCompagnon(Secteur.genieCivilVoirie), 50.87);
    });

    test('Taux d\'apprenti = pourcentage du compagnon', () {
      final m = elec(); // apprentis 50/60/70/85
      final p1 = CcqData.taux(m, Secteur.institutionnelCommercial, 50,
          on: DateTime(2026, 8, 10));
      expect(p1, closeTo(50.79 * 0.50, 0.001));
    });

    test('La liste des métiers est étoffée', () {
      expect(CcqData.metiers.length, greaterThan(80));
    });
  });

  test('Recherche de métier insensible aux accents', () {
    expect(foldRecherche('Électricien'), 'electricien');
    final trouve =
        CcqData.metiers.where((m) => foldRecherche(m.nom).contains('electric'));
    expect(trouve, isNotEmpty);
  });

  test('CcqApiClient extrait le taux « règle générale jour »', () async {
    String? seenOcc;
    String? seenSector;
    final mock = MockClient((req) async {
      seenOcc = req.url.queryParameters['occupationId'];
      seenSector = req.url.queryParameters['sectorId'];
      return http.Response.bytes(
        utf8.encode(jsonEncode({
          'Annexes': [
            {'cd_annexe': 'C3', 'desc_annexe': 'REGLE GENERALE : TRAVAIL DE JOUR'},
            {'cd_annexe': 'C6', 'desc_annexe': 'CHANTIERS ISOLES : TRAVAIL DE JOUR'},
          ],
          'AnnexesRates': {
            'Taux horaire': [
              {
                'Name': 'Régulier',
                'Rates': {'C3': '50,79', 'C6': '53,2'},
              },
            ],
          },
        })),
        200,
      );
    });
    final api = CcqApiClient(client: mock);
    final elec = CcqData.metiers.firstWhere((m) => m.nom == 'Électricien');
    final r = await api.tauxCompagnon(elec, Secteur.institutionnelCommercial);
    expect(r, 50.79);
    expect(seenOcc, elec.code.toString());
    expect(seenSector, 'C');
  });

  test('HeureEntry — brut, déplacement, total et sérialisation', () {
    final e = HeureEntry(
      id: '1',
      date: DateTime(2026, 8, 10),
      taux: 40,
      hNormal: 8,
      h15: 2,
      h2: 0,
      prime: 10,
      km: 50,
      tauxKm: 0.72,
    );
    expect(e.heures, 10);
    // 40×8 + 40×1,5×2 + prime 10 = 320 + 120 + 10 = 450
    expect(e.brut, closeTo(450, 0.001));
    expect(e.deplacement, closeTo(36, 0.001)); // 50 × 0,72
    expect(e.total, closeTo(486, 0.001));

    // Aller-retour JSON
    final e2 = HeureEntry.fromJson(e.toJson());
    expect(e2.taux, e.taux);
    expect(e2.brut, closeTo(e.brut, 0.001));
    expect(e2.date, e.date);
  });

  test('CSV feuille : entête, tri par date croissante, échappement « ; »', () {
    final e1 = HeureEntry(
        id: 'a',
        date: DateTime(2026, 8, 10),
        taux: 40,
        hNormal: 8,
        h15: 0,
        h2: 0,
        employeur: 'Cie A');
    final e2 = HeureEntry(
        id: 'b',
        date: DateTime(2026, 8, 3),
        taux: 50,
        hNormal: 10,
        h15: 2,
        h2: 0,
        employeur: 'Cie B; Inc');
    final csv = genererCsvFeuille([e1, e2]);
    final lignes = csv.split('\r\n');

    expect(lignes.first.startsWith('Date;Métier;Secteur;Employeur'), isTrue);
    expect(lignes.length, 3); // entête + 2 entrées
    // Trié par date croissante : 3 août avant 10 août.
    expect(lignes[1].startsWith('2026-08-03'), isTrue);
    expect(lignes[2].startsWith('2026-08-10'), isTrue);
    // Le point-virgule interne de l'employeur est protégé par des guillemets.
    expect(lignes[1].contains('"Cie B; Inc"'), isTrue);
  });

  test('Projection retraite : valeur future (solde + cotisations)', () {
    // 50 000 $ à 4 % sur 10 ans = 50 000 × 1,04^10 ≈ 74 012 $.
    expect(
        projeterCompte(
            solde: 50000, cotisAnnuelle: 0, annees: 10, rendement: 0.04),
        closeTo(74012.2, 1));
    // Cotisations seules sans rendement = simple somme.
    expect(
        projeterCompte(
            solde: 0, cotisAnnuelle: 1000, annees: 5, rendement: 0),
        closeTo(5000, 0.001));
  });

  test('Sauvegarde : aller-retour JSON conserve les entrées', () {
    final e = HeureEntry(
      id: 'x',
      date: DateTime(2026, 8, 10),
      taux: 47.85,
      hNormal: 8,
      h15: 1,
      h2: 0,
      employeur: 'Cie Test',
      note: 'Guillemets " et accents é',
    );
    final json = genererBackupJson([e]);
    final res = lireBackup(json);
    expect(res.reussi, isTrue);
    expect(res.entries.length, 1);
    expect(res.entries.first.taux, 47.85);
    expect(res.entries.first.employeur, 'Cie Test');
    expect(res.entries.first.note, 'Guillemets " et accents é');
  });

  test('Sauvegarde : un texte non valide est rejeté proprement', () {
    expect(lireBackup('pas du json').reussi, isFalse);
    expect(lireBackup('{"app":"autre"}').reussi, isFalse);
    expect(lireBackup('').reussi, isFalse);
  });

  test('debutSemaine tombe sur le lundi', () {
    // 2026-08-10 est un lundi.
    expect(debutSemaine(DateTime(2026, 8, 13)), DateTime(2026, 8, 10));
    expect(debutSemaine(DateTime(2026, 8, 10)), DateTime(2026, 8, 10));
  });

  testWidgets('Loi d\'Ohm : 240 V et 20 A donnent 12 Ω et 4800 W',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        const MaterialApp(home: CalculsElectriquesScreen()));
    await tester.pumpAndSettle();

    // Champs dans l'ordre : V, I, R, P.
    await tester.enterText(find.byType(TextField).at(0), '240');
    await tester.enterText(find.byType(TextField).at(1), '20');
    await tester.pumpAndSettle();

    expect(find.textContaining('12 Ω'), findsWidgets);
    expect(find.textContaining('4800 W'), findsWidgets);
  });

  testWidgets('Couple : 100 lb·pi ≈ 135,58 N·m', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: CoupleSerrageScreen()));
    await tester.pumpAndSettle();

    // « lb·pi » est l'unité sélectionnée par défaut.
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.pumpAndSettle();

    expect(find.textContaining('135,58 N·m'), findsWidgets);
  });

  testWidgets('Rappel rétro : 100 h, 40 → 42 \$ avec 13 % = 226,00 \$',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: RappelRetroScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '100'); // heures
    await tester.enterText(find.byType(TextField).at(1), '40'); // ancien
    await tester.enterText(find.byType(TextField).at(2), '42'); // nouveau
    await tester.pumpAndSettle();

    // 100 × 2 = 200 brut ; +13 % = 226.
    expect(find.textContaining('226,00 \$'), findsWidgets);
  });

  test('CcqApiClient renvoie null sur réponse d\'erreur', () async {
    final mock = MockClient((req) async =>
        http.Response.bytes(utf8.encode(jsonEncode({'Message': 'Aucun taux'})), 200));
    final api = CcqApiClient(client: mock);
    final elec = CcqData.metiers.firstWhere((m) => m.nom == 'Électricien');
    final r = await api.tauxCompagnon(elec, Secteur.institutionnelCommercial);
    expect(r, isNull);
  });
}
