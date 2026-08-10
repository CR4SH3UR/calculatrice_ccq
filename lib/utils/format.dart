import 'dart:math' as math;

/// Utilitaires de formatage et de conversion pour le chantier.
///
/// Tout est en français québécois et pensé pour les métiers de la
/// construction (pouces fractionnaires, impérial/métrique, argent).
class Fmt {
  const Fmt._();

  static const double mmPerInch = 25.4;
  static const double inchesPerFoot = 12.0;
  static const double m3PerCubicYard = 0.764554857984;

  /// Formate un montant en dollars: 1234.5 -> "1 234,50 $".
  static String money(num value, {int decimals = 2}) {
    return '${number(value, decimals: decimals)} \$';
  }

  /// Formate un nombre à la québécoise: espace comme séparateur de
  /// milliers et virgule comme séparateur décimal.
  static String number(num value, {int decimals = 2}) {
    final bool negative = value < 0;
    final double abs = value.abs().toDouble();
    final String fixed = abs.toStringAsFixed(decimals);
    final List<String> parts = fixed.split('.');
    final String intPart = _groupThousands(parts[0]);
    final String result =
        parts.length > 1 ? '$intPart,${parts[1]}' : intPart;
    return negative ? '-$result' : result;
  }

  /// Enlève les zéros décimaux inutiles: 3.0 -> "3", 3.50 -> "3,5".
  static String trim(num value, {int maxDecimals = 4}) {
    String s = value.toStringAsFixed(maxDecimals);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return s.replaceAll('.', ',');
  }

  static String percent(num value, {int decimals = 1}) {
    return '${number(value, decimals: decimals)} %';
  }

  static const List<String> _moisCourts = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juill.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
  ];

  /// Date en français court: DateTime(2027,4,25) -> "25 avr. 2027".
  static String dateFr(DateTime d) {
    return '${d.day} ${_moisCourts[d.month - 1]} ${d.year}';
  }

  static String _groupThousands(String digits) {
    final StringBuffer sb = StringBuffer();
    final int len = digits.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) sb.write(' ');
      sb.write(digits[i]);
    }
    return sb.toString();
  }

  /// Convertit un nombre de pouces (décimal) en fraction lisible.
  ///
  /// Exemple: 3.375 -> "3 3/8".  Arrondi au plus proche 1/[denom].
  static String inchesToFraction(double inches, {int denom = 16}) {
    if (inches.isNaN || inches.isInfinite) return '—';
    final bool negative = inches < 0;
    double abs = inches.abs();

    int whole = abs.floor();
    double frac = abs - whole;
    int num = (frac * denom).round();

    if (num == denom) {
      whole += 1;
      num = 0;
    }

    String result;
    if (num == 0) {
      result = '$whole';
    } else {
      final int g = _gcd(num, denom);
      final int n = num ~/ g;
      final int d = denom ~/ g;
      result = whole == 0 ? '$n/$d' : '$whole $n/$d';
    }
    return negative ? '-$result po' : '$result po';
  }

  /// Convertit une longueur en pouces décimaux vers pieds-pouces.
  ///
  /// Exemple: 30.5 -> "2 pi 6 1/2 po".
  static String inchesToFeetInches(double inches, {int denom = 16}) {
    final bool negative = inches < 0;
    final double abs = inches.abs();
    final int feet = (abs / inchesPerFoot).floor();
    final double remInches = abs - feet * inchesPerFoot;
    final String inchStr = inchesToFraction(remInches, denom: denom);
    final String sign = negative ? '-' : '';
    if (feet == 0) return '$sign$inchStr';
    return '$sign$feet pi ${inchStr.replaceAll(' po', '')} po';
  }

  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

  /// Degrés depuis une pente rise/run (ex: 6 et 12 -> 26.57°).
  static double slopeToDegrees(double rise, double run) {
    if (run == 0) return 0;
    return math.atan(rise / run) * 180 / math.pi;
  }
}
