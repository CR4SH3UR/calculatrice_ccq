import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/link_tile.dart';

// ─────────────────────────────────────────────────────────────────────────
//  SIMDUT 2015 — pictogrammes de danger (référence)
//  Source : Centre canadien d'hygiène et de sécurité au travail (CCHST).
// ─────────────────────────────────────────────────────────────────────────
class _Pictogramme {
  const _Pictogramme(this.nom, this.icon, this.dangers);
  final String nom;
  final IconData icon;
  final List<String> dangers;
}

const List<_Pictogramme> _pictos = [
  _Pictogramme('Flamme', Icons.local_fire_department, [
    'Gaz, aérosols, liquides et solides inflammables',
    'Matières pyrophoriques et auto-échauffantes',
    'Matières autoréactives et peroxydes organiques',
    'Dégagent des gaz inflammables au contact de l\'eau',
  ]),
  _Pictogramme('Flamme sur un cercle', Icons.whatshot, [
    'Comburants : gaz, liquides et solides',
    'Peuvent intensifier un incendie ou provoquer une explosion',
  ]),
  _Pictogramme('Bouteille à gaz', Icons.propane_tank, [
    'Gaz sous pression (comprimés, liquéfiés, dissous)',
    'La bonbonne peut exploser si chauffée; gaz réfrigérés = froid extrême',
  ]),
  _Pictogramme('Corrosion', Icons.science, [
    'Corrosif pour les métaux',
    'Corrosion cutanée (brûlures de la peau)',
    'Lésions oculaires graves',
  ]),
  _Pictogramme('Bombe qui explose', Icons.bolt, [
    'Explosifs',
    'Matières autoréactives (types A et B)',
    'Peroxydes organiques (types A et B)',
  ]),
  _Pictogramme('Tête de mort', Icons.dangerous, [
    'Toxicité aiguë (mortel ou toxique)',
    'Par voie orale, cutanée ou par inhalation',
  ]),
  _Pictogramme('Danger pour la santé', Icons.personal_injury, [
    'Cancérogènes, mutagènes',
    'Toxiques pour la reproduction',
    'Sensibilisants respiratoires',
    'Toxicité pour un organe cible; danger par aspiration',
  ]),
  _Pictogramme('Point d\'exclamation', Icons.priority_high, [
    'Irritation de la peau ou des yeux',
    'Sensibilisation cutanée',
    'Toxicité aiguë (nocif) — catégorie moindre',
  ]),
  _Pictogramme('Danger biologique', Icons.coronavirus, [
    'Matières infectieuses présentant un danger biologique',
  ]),
];

class SimdutScreen extends StatelessWidget {
  const SimdutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'SIMDUT 2015',
      children: [
        const InfoBanner(
          text:
              'Les 9 pictogrammes du SIMDUT 2015. Chacun se présente dans un '
              'losange à bordure rouge. La formation SIMDUT est obligatoire — '
              'consulte toujours la fiche de données de sécurité (FDS) du produit.',
          color: AppColors.infos,
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 16),
        ..._pictos.map((p) => _PictoCard(picto: p)),
        const SizedBox(height: 8),
        const InfoBanner(
          text:
              'Source : Centre canadien d\'hygiène et de sécurité au travail '
              '(CCHST). Référence pédagogique — ce n\'est pas la FDS officielle '
              'd\'un produit.',
        ),
        const SizedBox(height: 10),
        LinkTile(
          icon: Icons.open_in_new,
          title: 'CCHST — Pictogrammes du SIMDUT',
          subtitle: 'cchst.ca',
          color: AppColors.infos,
          url: 'https://www.cchst.ca/oshanswers/chemicals/whmis_ghs/pictograms.html',
        ),
      ],
    );
  }
}

/// Petit losange rouge (bordure) façon SIMDUT, avec le symbole au centre.
class _Losange extends StatelessWidget {
  const _Losange(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const rouge = Color(0xFFD32F2F);
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                border: Border.all(color: rouge, width: 2.5),
                color: rouge.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Icon(icon, color: rouge, size: 20),
        ],
      ),
    );
  }
}

class _PictoCard extends StatelessWidget {
  const _PictoCard({required this.picto});
  final _Pictogramme picto;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: _Losange(picto.icon),
          title: Text(picto.nom,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          subtitle: Text('${picto.dangers.length} classe(s) de danger',
              style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: picto.dangers
              .map((d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 5, right: 8),
                          child: Icon(Icons.circle,
                              size: 6, color: Color(0xFFD32F2F)),
                        ),
                        Expanded(
                          child: Text(d,
                              style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.35,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.8))),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  DISTANCES D'APPROCHE DES LIGNES ÉLECTRIQUES
//  Source : Code de sécurité pour les travaux de construction, art. 5.2.1.
// ─────────────────────────────────────────────────────────────────────────
class _PalierTension {
  const _PalierTension(this.tension, this.distance, this.max);
  final String tension;
  final String distance;

  /// Borne haute de la plage en kV (pour le mini-outil). null = pas de max.
  final double? max;
}

const List<_PalierTension> _paliersLigne = [
  _PalierTension('Moins de 125 kV', '3 m', 125),
  _PalierTension('125 kV à 250 kV', '5 m', 250),
  _PalierTension('250 kV à 550 kV', '8 m', 550),
  _PalierTension('Plus de 550 kV', '12 m', null),
];

class LignesElectriquesScreen extends StatefulWidget {
  const LignesElectriquesScreen({super.key});

  @override
  State<LignesElectriquesScreen> createState() =>
      _LignesElectriquesScreenState();
}

class _LignesElectriquesScreenState extends State<LignesElectriquesScreen> {
  final _kvCtrl = TextEditingController();
  String? _distance;

  @override
  void dispose() {
    _kvCtrl.dispose();
    super.dispose();
  }

  void _calculer() {
    final double? kv = parseNum(_kvCtrl.text);
    if (kv == null) {
      setState(() => _distance = null);
      return;
    }
    // Le seuil « 125 à 250 » se lit « 125 000 à 250 000 V », borne haute incluse.
    String d = '12 m';
    if (kv < 125) {
      d = '3 m';
    } else if (kv <= 250) {
      d = '5 m';
    } else if (kv <= 550) {
      d = '8 m';
    }
    setState(() => _distance = d);
  }

  @override
  Widget build(BuildContext context) {
    final Color onSurf = Theme.of(context).colorScheme.onSurface;
    return ToolScaffold(
      title: 'Lignes électriques',
      children: [
        // Bannière rouge « danger de mort ».
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.flash_on, color: AppColors.danger, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Danger de mort',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: AppColors.danger)),
                    Text(
                        'Pas besoin de toucher : le courant peut sauter. Respecte '
                        'la distance d\'approche minimale en tout temps.',
                        style: TextStyle(
                            fontSize: 12.5,
                            color: onSurf.withValues(alpha: 0.8))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionTitle('Distances d\'approche minimales',
            color: AppColors.chantier),
        const SizedBox(height: 8),
        // Tableau des paliers.
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (int i = 0; i < _paliersLigne.length; i++) ...[
                  if (i > 0)
                    Divider(
                        height: 1,
                        color: onSurf.withValues(alpha: 0.08),
                        indent: 16,
                        endIndent: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_paliersLigne[i].tension,
                              style: TextStyle(
                                  fontSize: 14.5,
                                  color: onSurf.withValues(alpha: 0.85))),
                        ),
                        Text(_paliersLigne[i].distance,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.chantier)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const SectionTitle('Vérifier une tension', color: AppColors.chantier),
        const SizedBox(height: 8),
        NumberField(
          controller: _kvCtrl,
          label: 'Tension de la ligne',
          suffix: 'kV',
          hint: 'ex. 25',
          onChanged: (_) => _calculer(),
        ),
        const SizedBox(height: 6),
        Text(
            'En cas de doute sur la tension, communique avec Hydro-Québec '
            'avant de commencer.',
            style: TextStyle(
                fontSize: 12, color: onSurf.withValues(alpha: 0.55))),
        if (_distance != null) ...[
          const SizedBox(height: 14),
          ResultCard(
            label: 'Distance d\'approche minimale',
            value: _distance!,
            color: AppColors.danger,
            icon: Icons.social_distance,
          ),
        ],
        const SizedBox(height: 20),
        const SectionTitle('Si tu ne peux pas respecter la distance',
            color: AppColors.chantier),
        const SizedBox(height: 8),
        ..._mesures.map((m) => _PucePoint(texte: m, couleur: AppColors.chantier)),
        const SizedBox(height: 16),
        const SectionTitle('Contact accidentel avec une ligne',
            color: AppColors.danger),
        const SizedBox(height: 8),
        ..._contact.map((m) => _PucePoint(texte: m, couleur: AppColors.danger)),
        const SizedBox(height: 16),
        const InfoBanner(
          text:
              'Distances tirées du Code de sécurité pour les travaux de '
              'construction (CSTC), art. 5.2.1. Les consignes en cas de contact '
              'sont des rappels généraux — suis toujours la procédure de ton '
              'employeur et les directives de la CNESST.',
        ),
        const SizedBox(height: 10),
        LinkTile(
          icon: Icons.open_in_new,
          title: 'CNESST — Travaux près des lignes électriques',
          subtitle: 'cnesst.gouv.qc.ca',
          color: AppColors.chantier,
          url:
              'https://www.cnesst.gouv.qc.ca/fr/prevention-securite/identifier-corriger-risques/liste-informations-prevention/travaux-proximite-lignes',
        ),
      ],
    );
  }
}

const List<String> _mesures = [
  'Faire mettre la ligne hors tension par Hydro-Québec.',
  'Établir une entente écrite avec Hydro-Québec sur les mesures de sécurité, '
      'accessible au personnel.',
  'Installer un dispositif limiteur de portée sur l\'équipement mobile ou '
      'déployable pour respecter la distance.',
  'Signaler les travaux à la CNESST (avis d\'ouverture de chantier) quand '
      'requis.',
];

const List<String> _contact = [
  'Reste sur la machine : ne descends pas si tu n\'es pas obligé.',
  'Avertis tout le monde de ne pas s\'approcher ni de toucher l\'équipement.',
  'Appelle le 911 et Hydro-Québec.',
  'Si tu dois absolument sortir (ex. feu) : saute à pieds joints, sans toucher '
      'la machine et le sol en même temps, puis éloigne-toi à petits pas '
      'glissés, pieds collés.',
];

class _PucePoint extends StatelessWidget {
  const _PucePoint({required this.texte, required this.couleur});
  final String texte;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(Icons.check_circle, size: 18, color: couleur),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texte,
                style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.85))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  CALCULS ÉLECTRIQUES — loi d'Ohm + chute de tension
// ─────────────────────────────────────────────────────────────────────────
class CalculsElectriquesScreen extends StatefulWidget {
  const CalculsElectriquesScreen({super.key});

  @override
  State<CalculsElectriquesScreen> createState() =>
      _CalculsElectriquesScreenState();
}

class _CalculsElectriquesScreenState extends State<CalculsElectriquesScreen> {
  String _mode = 'Loi d\'Ohm';

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Calculs électriques',
      children: [
        ChoiceSegments(
          options: const ['Loi d\'Ohm', 'Chute de tension'],
          selected: _mode,
          onChanged: (v) => setState(() => _mode = v),
        ),
        const SizedBox(height: 16),
        if (_mode == 'Loi d\'Ohm')
          const _OhmSection()
        else
          const _ChuteSection(),
      ],
    );
  }
}

// ── Loi d'Ohm ──────────────────────────────────────────────────────────
class _OhmSection extends StatefulWidget {
  const _OhmSection();

  @override
  State<_OhmSection> createState() => _OhmSectionState();
}

class _OhmSectionState extends State<_OhmSection> {
  final _v = TextEditingController();
  final _i = TextEditingController();
  final _r = TextEditingController();
  final _p = TextEditingController();

  @override
  void dispose() {
    _v.dispose();
    _i.dispose();
    _r.dispose();
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double? v = parseNum(_v.text);
    final double? i = parseNum(_i.text);
    final double? r = parseNum(_r.text);
    final double? p = parseNum(_p.text);

    final _OhmResultat? res = _resoudre(v: v, i: i, r: r, p: p);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InfoBanner(
          text:
              'Entre deux valeurs, l\'app calcule les deux autres. '
              'V = tension (volts), I = courant (ampères), R = résistance '
              '(ohms), P = puissance (watts).',
          color: AppColors.infos,
        ),
        const SizedBox(height: 14),
        NumberField(controller: _v, label: 'Tension (V)', suffix: 'V',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(controller: _i, label: 'Courant (I)', suffix: 'A',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(controller: _r, label: 'Résistance (R)', suffix: 'Ω',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(controller: _p, label: 'Puissance (P)', suffix: 'W',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),
        if (res != null)
          ResultCard(
            label: 'Résultat',
            value: '${Fmt.trim(res.v, maxDecimals: 2)} V',
            color: AppColors.charpente,
            icon: Icons.electric_bolt,
            details: [
              ResultLine('Tension (V)', '${Fmt.trim(res.v, maxDecimals: 2)} V',
                  strong: true),
              ResultLine('Courant (I)', '${Fmt.trim(res.i, maxDecimals: 3)} A'),
              ResultLine('Résistance (R)', '${Fmt.trim(res.r, maxDecimals: 3)} Ω'),
              ResultLine('Puissance (P)', '${Fmt.trim(res.p, maxDecimals: 2)} W'),
            ],
          )
        else
          InfoBanner(
            text: (v != null ? 1 : 0) +
                        (i != null ? 1 : 0) +
                        (r != null ? 1 : 0) +
                        (p != null ? 1 : 0) <
                    2
                ? 'Entre au moins deux valeurs.'
                : 'Combinaison impossible (division par zéro?). Vérifie tes '
                    'valeurs.',
            icon: Icons.info_outline,
            color: AppColors.infos,
          ),
      ],
    );
  }
}

class _OhmResultat {
  const _OhmResultat(this.v, this.i, this.r, this.p);
  final double v, i, r, p;
}

/// Résout V, I, R, P à partir de deux valeurs connues (ordre V,I,R,P).
_OhmResultat? _resoudre({double? v, double? i, double? r, double? p}) {
  double? V = v, I = i, R = r, P = p;
  try {
    if (V != null && I != null) {
      R = I == 0 ? null : V / I;
      P = V * I;
    } else if (V != null && R != null) {
      if (R == 0) return null;
      I = V / R;
      P = V * V / R;
    } else if (V != null && P != null) {
      if (V == 0) return null;
      I = P / V;
      R = V * V / P;
    } else if (I != null && R != null) {
      V = I * R;
      P = I * I * R;
    } else if (I != null && P != null) {
      if (I == 0) return null;
      V = P / I;
      R = P / (I * I);
    } else if (R != null && P != null) {
      if (R < 0 || P < 0) return null;
      V = math.sqrt(P * R);
      I = R == 0 ? null : math.sqrt(P / R);
    } else {
      return null;
    }
    // Seuls I (branche R&P) et R (branche V&I) peuvent rester nuls ici.
    if (I == null || R == null) return null;
    if (!V.isFinite || !I.isFinite || !R.isFinite || !P.isFinite) return null;
    return _OhmResultat(V, I, R, P);
  } catch (_) {
    return null;
  }
}

// ── Chute de tension ──────────────────────────────────────────────────
class _ChuteSection extends StatefulWidget {
  const _ChuteSection();

  @override
  State<_ChuteSection> createState() => _ChuteSectionState();
}

class _ChuteSectionState extends State<_ChuteSection> {
  final _courant = TextEditingController();
  final _longueur = TextEditingController();
  final _section = TextEditingController();
  final _source = TextEditingController(text: '120');
  String _materiau = 'Cuivre';
  String _phase = 'Monophasé';

  // Résistivité en Ω·mm²/m à 20 °C.
  static const double _rhoCuivre = 0.0172;
  static const double _rhoAlu = 0.0282;

  @override
  void dispose() {
    _courant.dispose();
    _longueur.dispose();
    _section.dispose();
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double? i = parseNum(_courant.text);
    final double? l = parseNum(_longueur.text);
    final double? a = parseNum(_section.text);
    final double? vs = parseNum(_source.text);

    double? vd;
    double? pct;
    if (i != null && l != null && a != null && a > 0) {
      final double rho = _materiau == 'Cuivre' ? _rhoCuivre : _rhoAlu;
      final double facteur = _phase == 'Monophasé' ? 2 : math.sqrt(3);
      vd = facteur * i * rho * l / a;
      if (vs != null && vs > 0) pct = vd / vs * 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InfoBanner(
          text:
              'Estimation de la chute de tension d\'un conducteur selon sa '
              'longueur, son courant et sa section. Longueur = distance simple '
              '(aller) de la source à la charge.',
          color: AppColors.infos,
        ),
        const SizedBox(height: 14),
        Text('Matériau',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75))),
        const SizedBox(height: 8),
        ChoiceSegments(
          options: const ['Cuivre', 'Aluminium'],
          selected: _materiau,
          onChanged: (v) => setState(() => _materiau = v),
        ),
        const SizedBox(height: 12),
        Text('Type de circuit',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75))),
        const SizedBox(height: 8),
        ChoiceSegments(
          options: const ['Monophasé', 'Triphasé'],
          selected: _phase,
          onChanged: (v) => setState(() => _phase = v),
        ),
        const SizedBox(height: 14),
        NumberField(controller: _courant, label: 'Courant', suffix: 'A',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(controller: _longueur, label: 'Longueur (aller)', suffix: 'm',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(controller: _section, label: 'Section du conducteur',
            suffix: 'mm²', hint: 'ex. 8,37 (n° 8 AWG)',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        NumberField(controller: _source, label: 'Tension de source', suffix: 'V',
            hint: '120, 240, 347, 600…', onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),
        if (vd != null)
          ResultCard(
            label: 'Chute de tension',
            value: '${Fmt.trim(vd, maxDecimals: 2)} V',
            color: pct != null && pct > 3 ? AppColors.danger : AppColors.charpente,
            icon: Icons.trending_down,
            details: [
              if (pct != null)
                ResultLine('Pourcentage', '${Fmt.trim(pct, maxDecimals: 2)} %',
                    strong: true),
              if (vs != null && vs > 0)
                ResultLine('Tension au bout',
                    '${Fmt.trim(vs - vd, maxDecimals: 2)} V'),
              ResultLine('Matériau', _materiau),
              ResultLine('Circuit', _phase),
            ],
          ),
        if (pct != null && pct > 3) ...[
          const SizedBox(height: 12),
          const InfoBanner(
            text:
                'Plus de 3 % de chute : en général on vise un maximum de 3 % '
                'sur une dérivation (5 % au total avec l\'artère). Envisage un '
                'conducteur plus gros.',
            color: AppColors.warning,
          ),
        ],
        const SizedBox(height: 16),
        const InfoBanner(
          text:
              'Estimation basée sur la résistance en courant continu à 20 °C '
              '(cuivre 0,0172 · aluminium 0,0282 Ω·mm²/m). N\'inclut pas la '
              'température réelle ni la réactance. Le choix final des '
              'conducteurs doit suivre le Code canadien de l\'électricité (CCÉ).',
        ),
      ],
    );
  }
}
