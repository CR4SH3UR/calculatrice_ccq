import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/ccq_data.dart';

/// Contexte de travail (horaire) — sélectionne l'annexe de taux à lire.
enum ContexteTravail {
  jour('Jour'),
  nuit('Nuit'),
  chantierIsole('Isolé');

  const ContexteTravail(this.label);
  final String label;
}

/// Client de l'**API officielle des taux de salaire de la CCQ**
/// (`https://www.ccq.org/api/wagerates/Rates`). Récupère le taux de compagnon
/// (règle générale, travail de jour) d'un métier pour une grille donnée.
///
/// ⚠️ Sur le **web**, le navigateur bloque l'appel par CORS : n'appeler que
/// sur mobile (l'appelant vérifie `kIsWeb`). Aucune authentification — donnée
/// publique. Retourne `null` si l'appel échoue ou si l'occupation n'existe pas
/// dans cette grille.
class CcqApiClient {
  CcqApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _base = 'https://www.ccq.org/api/wagerates/Rates';
  static const Duration _timeout = Duration(seconds: 20);

  /// A = génie civil et voirie, B = industriel, C = institutionnel-commercial,
  /// D = résidentiel (léger et lourd, distingués par l'annexe R / R-1).
  static String _sectorId(Secteur s) {
    switch (s) {
      case Secteur.genieCivilVoirie:
        return 'A';
      case Secteur.industriel:
        return 'B';
      case Secteur.institutionnelCommercial:
        return 'C';
      case Secteur.residentielLeger:
      case Secteur.residentielLourd:
        return 'D';
    }
  }

  Uri _uri(int code, String sector, int skill, DateTime date) {
    final String d = '${date.year}-${date.month}-${date.day}';
    return Uri.parse('$_base?ratesToDate=$d&occupationId=$code'
        '&sectorId=$sector&skillId=$skill&annexId=ALL');
  }

  Future<Map<String, dynamic>?> _get(
      int code, String sector, int skill, DateTime date) async {
    try {
      final http.Response r =
          await _client.get(_uri(code, sector, skill, date)).timeout(_timeout);
      if (r.statusCode != 200) return null;
      // L'API renvoie de l'UTF-8 brut ; on décode les octets directement pour
      // ne pas dépendre du charset (parfois absent) de l'en-tête.
      final Object? body = jsonDecode(utf8.decode(r.bodyBytes));
      // Les erreurs de l'API arrivent en 200 avec une seule clé "Message".
      if (body is! Map<String, dynamic> || body.containsKey('Message')) {
        return null;
      }
      return body;
    } catch (_) {
      return null; // réseau coupé, CORS (web), délai dépassé…
    }
  }

  /// Le taux de compagnon (règle générale, jour) d'un [metier] pour une
  /// [secteur] à une [date] (défaut = aujourd'hui). On tente la compétence
  /// compagnon (6) puis, à défaut, l'occupation (0). `null` si indisponible.
  Future<double?> tauxCompagnon(Metier metier, Secteur secteur,
      {DateTime? date, ContexteTravail contexte = ContexteTravail.jour}) async {
    final int? code = metier.code;
    if (code == null) return null;
    final DateTime d = date ?? DateTime.now();
    final String sector = _sectorId(secteur);
    for (final int skill in const [6, 0]) {
      final Map<String, dynamic>? data = await _get(code, sector, skill, d);
      if (data == null) continue;
      final double? rate = _extraire(data, secteur, contexte);
      if (rate != null) return rate;
    }
    return null;
  }

  double? _extraire(
      Map<String, dynamic> data, Secteur secteur, ContexteTravail contexte) {
    final Object? annexes = data['Annexes'];
    final Map? rates = _regulier(data);
    if (annexes is! List || rates == null) return null;

    for (final bool Function(String) pred in _predicats(secteur, contexte)) {
      for (final Object? a in annexes) {
        if (a is! Map) continue;
        final String desc = (a['desc_annexe'] as String? ?? '').toUpperCase();
        if (pred(desc)) {
          final double? r = _num(rates[a['cd_annexe']]);
          if (r != null) return r;
        }
      }
    }
    return null;
  }

  /// Prédicats d'annexe à essayer dans l'ordre, selon la grille et l'horaire.
  List<bool Function(String)> _predicats(
      Secteur secteur, ContexteTravail contexte) {
    if (secteur == Secteur.residentielLeger) {
      return [(d) => d.contains('RESIDENTIELLE LEGERE') && !d.contains('ISOLE')];
    }
    if (secteur == Secteur.residentielLourd) {
      return [(d) => d.contains('RESIDENTIELLE LOURDE') && !d.contains('ISOLE')];
    }
    switch (contexte) {
      case ContexteTravail.nuit:
        return [
          (d) => d.contains('REGLE GENERAL') && d.contains('NUIT'),
          (d) => d.contains('NUIT') && !d.contains('ISOLE'),
        ];
      case ContexteTravail.chantierIsole:
        return [
          (d) => d.contains('ISOLE') && d.contains('JOUR'),
          (d) => d.contains('ISOLE') || d.contains('BAIE'),
        ];
      case ContexteTravail.jour:
        return [
          (d) => d.contains('REGLE GENERAL') && d.contains('JOUR'),
          (d) => d.contains('REGLE GENERAL') && !d.contains('NUIT'),
          (d) => !d.contains('NUIT') &&
              !d.contains('ISOLE') &&
              !d.contains('BARAQ') &&
              !d.contains('EOLIEN') &&
              !d.contains('PIPELINE') &&
              !d.contains('BAIE') &&
              !d.contains('RESEAUX'),
        ];
    }
  }

  Map? _regulier(Map<String, dynamic> data) {
    final Object? ar = data['AnnexesRates'];
    if (ar is! Map) return null;
    final Object? th = ar['Taux horaire'];
    if (th is! List) return null;
    for (final Object? s in th) {
      if (s is Map && (s['Name'] as String?)?.toLowerCase() == 'régulier') {
        final Object? r = s['Rates'];
        return r is Map ? r : null;
      }
    }
    return null;
  }

  double? _num(Object? v) {
    if (v is num) return v.toDouble();
    if (v is! String) return null;
    final String s = v.trim().replaceAll(' ', '').replaceAll(',', '.');
    return s.isEmpty ? null : double.tryParse(s);
  }

  void close() => _client.close();
}
