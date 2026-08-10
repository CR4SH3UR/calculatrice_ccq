import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../data/ccq_data.dart';
import '../data/heures_store.dart';
import '../services/ccq_api_client.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/metier_picker.dart';

// ─────────────────────────────────────────────────────────────────────────
//  CALCULATEUR DE PAIE
// ─────────────────────────────────────────────────────────────────────────
class CalculateurPaieScreen extends StatefulWidget {
  const CalculateurPaieScreen({super.key});

  @override
  State<CalculateurPaieScreen> createState() => _CalculateurPaieScreenState();
}

class _CalculateurPaieScreenState extends State<CalculateurPaieScreen> {
  final _tauxCtrl = TextEditingController();
  final _normalCtrl = TextEditingController(text: '40');
  final _demiCtrl = TextEditingController();
  final _doubleCtrl = TextEditingController();

  String _mode = 'Mon taux';
  Metier _metier = CcqData.metiers[3];
  int _palierIndex = 999; // clampé au dernier palier (compagnon) par défaut
  Secteur _secteur = Secteur.institutionnelCommercial;

  final CcqApiClient _api = CcqApiClient();
  bool _sync = false;

  // Horaire de travail + prime (mode « Par métier »).
  ContexteTravail _contexte = ContexteTravail.jour;
  final _primeCtrl = TextEditingController();
  double? _compFetched; // taux compagnon récupéré pour un horaire non-jour
  ContexteTravail? _compFetchedCtx;

  // Estimation de la paie nette (repliée par défaut).
  bool _montrerNet = false;
  final _impotCtrl = TextEditingController(text: '18');
  final _rrqCtrl = TextEditingController(text: '6.4');
  final _aeCtrl = TextEditingController(text: '1.32');
  final _rqapCtrl = TextEditingController(text: '0.494');
  final _autresCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    _tauxCtrl.dispose();
    _normalCtrl.dispose();
    _demiCtrl.dispose();
    _doubleCtrl.dispose();
    _primeCtrl.dispose();
    _impotCtrl.dispose();
    _rrqCtrl.dispose();
    _aeCtrl.dispose();
    _rqapCtrl.dispose();
    _autresCtrl.dispose();
    _api.close();
    super.dispose();
  }

  Future<void> _noterHeures(double taux, double hN, double h15, double h2) async {
    if (hN + h15 + h2 <= 0) {
      _snack('Entre des heures avant de les noter.');
      return;
    }
    await HeuresStore.instance.ajouter(HeureEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      taux: taux,
      hNormal: hN,
      h15: h15,
      h2: h2,
      metier: _mode == 'Par métier' ? _metier.nom : '',
      secteur: _mode == 'Par métier' ? _secteur.court : '',
    ));
    _snack('Ajouté à ta feuille de temps ✓');
  }

  Future<void> _rafraichir() async {
    if (kIsWeb) {
      _snack('Le rafraîchissement en direct fonctionne sur mobile — '
          'le web bloque l\'appel à la CCQ (CORS).');
      return;
    }
    setState(() => _sync = true);
    final double? taux =
        await _api.tauxCompagnon(_metier, _secteur, contexte: _contexte);
    if (!mounted) return;
    setState(() => _sync = false);
    if (taux == null) {
      _snack('Impossible de récupérer le taux (réseau, ou horaire/occupation '
          'absent dans cette grille).');
      return;
    }
    setState(() {
      if (_contexte == ContexteTravail.jour) {
        CcqData.appliquerTauxLive(_metier, _secteur, taux);
        _compFetched = null;
        _compFetchedCtx = null;
      } else {
        _compFetched = taux;
        _compFetchedCtx = _contexte;
      }
    });
    _snack('Taux ${_contexte.label.toLowerCase()} récupéré : '
        '${Fmt.money(taux)}/h ✓');
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Index de palier valide pour le métier courant (compagnon par défaut).
  int get _idx {
    final int n = _metier.paliers().length;
    return _palierIndex.clamp(0, n - 1);
  }

  Palier get _palier => _metier.paliers()[_idx];

  double get _prime => parseNum(_primeCtrl.text) ?? 0;

  double get _tauxBase {
    if (_mode == 'Mon taux') return parseNum(_tauxCtrl.text) ?? 0;
    final double comp = (_contexte != ContexteTravail.jour &&
            _compFetchedCtx == _contexte &&
            _compFetched != null)
        ? _compFetched!
        : CcqData.tauxCompagnon(_metier, _secteur);
    return comp * _palier.pourcentage / 100;
  }

  double get _taux => _tauxBase + _prime;

  @override
  Widget build(BuildContext context) {
    final double taux = _taux;
    final double hN = parseNum(_normalCtrl.text) ?? 0;
    final double h15 = parseNum(_demiCtrl.text) ?? 0;
    final double h2 = parseNum(_doubleCtrl.text) ?? 0;

    final double payN = taux * hN;
    final double pay15 = taux * 1.5 * h15;
    final double pay2 = taux * 2 * h2;
    final double brut = payN + pay15 + pay2;
    final double heures = hN + h15 + h2;

    final double conges = brut * CcqData.indemniteCongesPct / 100;
    final double avecConges = brut + conges;

    final double impot = brut * (parseNum(_impotCtrl.text) ?? 0) / 100;
    final double rrq = brut * (parseNum(_rrqCtrl.text) ?? 0) / 100;
    final double ae = brut * (parseNum(_aeCtrl.text) ?? 0) / 100;
    final double rqap = brut * (parseNum(_rqapCtrl.text) ?? 0) / 100;
    final double autres = parseNum(_autresCtrl.text) ?? 0;
    final double retenues = impot + rrq + ae + rqap + autres;
    final double net = brut - retenues;

    return ToolScaffold(
      title: 'Calculateur de paie',
      children: [
        ChoiceSegments(
          options: const ['Mon taux', 'Par métier'],
          selected: _mode,
          onChanged: (v) => setState(() => _mode = v),
        ),
        const SizedBox(height: 16),
        if (_mode == 'Mon taux')
          NumberField(
            controller: _tauxCtrl,
            label: 'Mon taux horaire',
            suffix: '\$/h',
            hint: 'ex. 43,90',
            onChanged: (_) => setState(() {}),
          )
        else ...[
          _SecteurDropdown(
            secteur: _secteur,
            onChanged: (s) => setState(() {
              _secteur = s;
              _compFetched = null;
              _compFetchedCtx = null;
            }),
          ),
          const SizedBox(height: 12),
          MetierField(
            metier: _metier,
            color: AppColors.paie,
            onChanged: (m) => setState(() {
              _metier = m;
              _compFetched = null;
              _compFetchedCtx = null;
            }),
          ),
          const SizedBox(height: 12),
          _PalierDropdown(
            paliers: _metier.paliers(),
            selectedIndex: _idx,
            onChanged: (i) => setState(() => _palierIndex = i),
          ),
          const SizedBox(height: 12),
          Text('Horaire de travail',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7))),
          const SizedBox(height: 8),
          ChoiceSegments(
            options: ContexteTravail.values.map((c) => c.label).toList(),
            selected: _contexte.label,
            onChanged: (v) => setState(() => _contexte =
                ContexteTravail.values.firstWhere((c) => c.label == v)),
          ),
          const SizedBox(height: 12),
          InfoBanner(
            text:
                'Convention ${_secteur.nom} — horaire ${_contexte.label.toLowerCase()} · '
                'palier ${_palier.pourcentage} % = ${Fmt.money(_tauxBase)}/h. '
                '${CcqData.enVigueurTexte} · à valider sur ${CcqData.siteWeb}.'
                '${_secteur.note != null ? '\n${_secteur.note}' : ''}',
          ),
          if (_contexte != ContexteTravail.jour &&
              !(_compFetchedCtx == _contexte && _compFetched != null)) ...[
            const SizedBox(height: 8),
            InfoBanner(
              text:
                  'Taux ${_contexte.label.toLowerCase()} : touche « Rafraîchir » '
                  'pour le chiffre officiel (mobile). En attendant, le taux de '
                  'jour est affiché à titre indicatif.',
              icon: Icons.nightlight_round,
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _sync ? null : _rafraichir,
            icon: _sync
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync),
            label: Text(_sync
                ? 'Récupération…'
                : 'Rafraîchir le taux ${_contexte.label.toLowerCase()} (mobile)'),
            style:
                OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
          if ((_contexte == ContexteTravail.jour &&
                  CcqData.aTauxLive(_metier, _secteur)) ||
              (_compFetchedCtx == _contexte && _compFetched != null))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.verified,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text('Taux vérifié en direct auprès de la CCQ',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
        const SizedBox(height: 12),
        NumberField(
          controller: _primeCtrl,
          label: 'Prime horaire (nuit, hauteur, etc.)',
          suffix: '\$/h',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        const SectionTitle('Heures travaillées', color: AppColors.paie),
        NumberField(
          controller: _normalCtrl,
          label: 'Heures normales (×1)',
          suffix: 'h',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _demiCtrl,
          label: 'Temps et demi (×1,5)',
          suffix: 'h',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _doubleCtrl,
          label: 'Temps double (×2)',
          suffix: 'h',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Salaire brut',
          value: Fmt.money(brut),
          color: AppColors.paie,
          icon: Icons.payments,
          details: [
            ResultLine('Taux horaire', '${Fmt.money(taux)}/h'),
            ResultLine('Total des heures', '${Fmt.trim(heures)} h'),
            if (payN > 0)
              ResultLine('Normales (${Fmt.trim(hN)} h)', Fmt.money(payN)),
            if (pay15 > 0)
              ResultLine('Temps et demi (${Fmt.trim(h15)} h)', Fmt.money(pay15)),
            if (pay2 > 0)
              ResultLine('Temps double (${Fmt.trim(h2)} h)', Fmt.money(pay2)),
            ResultLine('Salaire brut', Fmt.money(brut), strong: true),
            ResultLine('Indemnité congés (13 %)', Fmt.money(conges)),
            ResultLine('Brut + congés', Fmt.money(avecConges), strong: true),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _noterHeures(taux, hN, h15, h2),
          style: FilledButton.styleFrom(backgroundColor: AppColors.paie),
          icon: const Icon(Icons.post_add),
          label: const Text('Noter ces heures'),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: _montrerNet,
              onExpansionChanged: (v) => setState(() => _montrerNet = v),
              leading: const Icon(Icons.account_balance_wallet,
                  color: AppColors.paie),
              title: const Text('Estimation de la paie nette',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Net estimé : ${Fmt.money(net)}',
                  style: const TextStyle(
                      color: AppColors.paie, fontWeight: FontWeight.w700)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const InfoBanner(
                  text:
                      '⚠️ Estimation. Ajuste les taux : ils dépendent des '
                      'paliers d\'impôt, des maximums annuels et des '
                      'prélèvements de ta convention (syndicat, régime, '
                      'assurances).',
                  color: AppColors.danger,
                ),
                const SizedBox(height: 12),
                _pct(_impotCtrl, 'Impôt combiné (féd. + prov.)'),
                _pct(_rrqCtrl, 'RRQ'),
                _pct(_aeCtrl, 'Assurance-emploi'),
                _pct(_rqapCtrl, 'RQAP'),
                NumberField(
                  controller: _autresCtrl,
                  label: 'Autres retenues (syndicat, régime…)',
                  suffix: '\$',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                ResultCard(
                  label: 'Paie nette estimée',
                  value: Fmt.money(net),
                  color: AppColors.paie,
                  icon: Icons.account_balance_wallet,
                  details: [
                    ResultLine('Salaire brut', Fmt.money(brut)),
                    ResultLine('Total des retenues', '- ${Fmt.money(retenues)}'),
                    ResultLine('Net estimé', Fmt.money(net), strong: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pct(TextEditingController ctrl, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: NumberField(
          controller: ctrl,
          label: label,
          suffix: '%',
          onChanged: (_) => setState(() {}),
        ),
      );
}

class _PalierDropdown extends StatelessWidget {
  const _PalierDropdown({
    required this.paliers,
    required this.selectedIndex,
    required this.onChanged,
  });
  final List<Palier> paliers;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: selectedIndex,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Palier'),
      items: [
        for (int i = 0; i < paliers.length; i++)
          DropdownMenuItem(
            value: i,
            child: Text('${paliers[i].nom}  (${paliers[i].pourcentage} %)'),
          ),
      ],
      onChanged: (i) => i == null ? null : onChanged(i),
    );
  }
}

class _SecteurDropdown extends StatelessWidget {
  const _SecteurDropdown({required this.secteur, required this.onChanged});
  final Secteur secteur;
  final ValueChanged<Secteur> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Secteur>(
      initialValue: secteur,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Convention (secteur)',
        prefixIcon: Icon(Icons.description_outlined),
      ),
      items: Secteur.values
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text('${s.nom} (${s.court})',
                    overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (s) => s == null ? null : onChanged(s),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  VACANCES / INDEMNITÉ DE CONGÉS
// ─────────────────────────────────────────────────────────────────────────
class VacancesScreen extends StatefulWidget {
  const VacancesScreen({super.key});

  @override
  State<VacancesScreen> createState() => _VacancesScreenState();
}

class _VacancesScreenState extends State<VacancesScreen> {
  final _brutCtrl = TextEditingController();
  final _pctCtrl =
      TextEditingController(text: Fmt.trim(CcqData.indemniteCongesPct));

  @override
  void dispose() {
    _brutCtrl.dispose();
    _pctCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double brut = parseNum(_brutCtrl.text) ?? 0;
    final double pct = parseNum(_pctCtrl.text) ?? 0;
    final double indemnite = brut * pct / 100;

    return ToolScaffold(
      title: 'Vacances & congés',
      children: [
        const InfoBanner(
          text:
              'Dans la construction, l\'indemnité de congés annuels et de '
              'jours fériés est généralement d\'environ 13 % du salaire brut. '
              'Le pourcentage exact dépend de ta convention — ajuste-le au '
              'besoin.',
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _brutCtrl,
          label: 'Salaire brut de la période',
          suffix: '\$',
          hint: 'ex. 2 500',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _pctCtrl,
          label: 'Pourcentage d\'indemnité',
          suffix: '%',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Indemnité de congés',
          value: Fmt.money(indemnite),
          color: AppColors.paie,
          icon: Icons.beach_access,
          details: [
            ResultLine('Salaire brut', Fmt.money(brut)),
            ResultLine('Taux appliqué', Fmt.percent(pct)),
            ResultLine('Indemnité', Fmt.money(indemnite), strong: true),
            ResultLine('Brut + indemnité', Fmt.money(brut + indemnite)),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  PAIE NETTE (ESTIMATION)
// ─────────────────────────────────────────────────────────────────────────
class PaieNetteScreen extends StatefulWidget {
  const PaieNetteScreen({super.key});

  @override
  State<PaieNetteScreen> createState() => _PaieNetteScreenState();
}

class _PaieNetteScreenState extends State<PaieNetteScreen> {
  final _brutCtrl = TextEditingController();
  final _impotCtrl = TextEditingController(text: '18');
  final _rrqCtrl = TextEditingController(text: '6.4');
  final _aeCtrl = TextEditingController(text: '1.32');
  final _rqapCtrl = TextEditingController(text: '0.494');
  final _autresCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    for (final c in [
      _brutCtrl,
      _impotCtrl,
      _rrqCtrl,
      _aeCtrl,
      _rqapCtrl,
      _autresCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double brut = parseNum(_brutCtrl.text) ?? 0;
    final double impot = brut * (parseNum(_impotCtrl.text) ?? 0) / 100;
    final double rrq = brut * (parseNum(_rrqCtrl.text) ?? 0) / 100;
    final double ae = brut * (parseNum(_aeCtrl.text) ?? 0) / 100;
    final double rqap = brut * (parseNum(_rqapCtrl.text) ?? 0) / 100;
    final double autres = parseNum(_autresCtrl.text) ?? 0;

    final double retenues = impot + rrq + ae + rqap + autres;
    final double net = brut - retenues;

    return ToolScaffold(
      title: 'Paie nette (estimation)',
      children: [
        const InfoBanner(
          text:
              '⚠️ ESTIMATION SEULEMENT. Les vraies retenues dépendent des '
              'paliers d\'imposition, des maximums annuels (RRQ, AE, RQAP) et '
              'des prélèvements de ta convention (syndicat, régime de '
              'retraite, assurances). Ajuste les taux et vois ton relevé de '
              'paie officiel.',
          color: AppColors.danger,
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _brutCtrl,
          label: 'Salaire brut',
          suffix: '\$',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        const SectionTitle('Retenues (taux ajustables)',
            color: AppColors.paie),
        _pctRow(_impotCtrl, 'Impôt combiné (féd. + prov.)'),
        _pctRow(_rrqCtrl, 'RRQ (régime de rentes)'),
        _pctRow(_aeCtrl, 'Assurance-emploi (AE)'),
        _pctRow(_rqapCtrl, 'RQAP'),
        const SizedBox(height: 12),
        NumberField(
          controller: _autresCtrl,
          label: 'Autres retenues (syndicat, régime, assurances)',
          suffix: '\$',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Paie nette estimée',
          value: Fmt.money(net),
          color: AppColors.paie,
          icon: Icons.account_balance_wallet,
          details: [
            ResultLine('Salaire brut', Fmt.money(brut)),
            ResultLine('Impôt', '- ${Fmt.money(impot)}'),
            ResultLine('RRQ', '- ${Fmt.money(rrq)}'),
            ResultLine('AE', '- ${Fmt.money(ae)}'),
            ResultLine('RQAP', '- ${Fmt.money(rqap)}'),
            if (autres > 0) ResultLine('Autres', '- ${Fmt.money(autres)}'),
            ResultLine('Total des retenues', '- ${Fmt.money(retenues)}'),
            ResultLine('Net estimé', Fmt.money(net), strong: true),
          ],
        ),
      ],
    );
  }

  Widget _pctRow(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NumberField(
        controller: ctrl,
        label: label,
        suffix: '%',
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  FRAIS DE DÉPLACEMENT
// ─────────────────────────────────────────────────────────────────────────
class DeplacementScreen extends StatefulWidget {
  const DeplacementScreen({super.key});

  @override
  State<DeplacementScreen> createState() => _DeplacementScreenState();
}

class _DeplacementScreenState extends State<DeplacementScreen> {
  final _kmCtrl = TextEditingController();
  final _tauxCtrl = TextEditingController(text: '0.72');
  final _joursCtrl = TextEditingController(text: '1');
  bool _allerRetour = true;

  @override
  void dispose() {
    _kmCtrl.dispose();
    _tauxCtrl.dispose();
    _joursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double km = parseNum(_kmCtrl.text) ?? 0;
    final double taux = parseNum(_tauxCtrl.text) ?? 0;
    final double jours = parseNum(_joursCtrl.text) ?? 0;
    final double kmParJour = _allerRetour ? km * 2 : km;
    final double total = kmParJour * taux * jours;

    return ToolScaffold(
      title: 'Frais de déplacement',
      children: [
        const InfoBanner(
          text:
              'Calcul simple : distance × taux du kilomètre × nombre de jours. '
              'Les conventions de la construction ont aussi des règles de '
              'zones, de transport et de pension (chambre/pension) — vérifie '
              'ta convention pour les indemnités exactes.',
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _kmCtrl,
          label: 'Distance (un sens)',
          suffix: 'km',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: _allerRetour,
          onChanged: (v) => setState(() => _allerRetour = v),
          title: const Text('Aller-retour'),
          subtitle: Text(_allerRetour
              ? 'La distance est comptée ×2'
              : 'Distance comptée une seule fois'),
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _tauxCtrl,
          label: 'Taux du kilomètre',
          suffix: '\$/km',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _joursCtrl,
          label: 'Nombre de jours',
          suffix: 'j',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: 'Indemnité de déplacement',
          value: Fmt.money(total),
          color: AppColors.paie,
          icon: Icons.directions_car,
          details: [
            ResultLine('Distance par jour', '${Fmt.trim(kmParJour)} km'),
            ResultLine('Taux', '${Fmt.money(taux)}/km'),
            ResultLine('Par jour', Fmt.money(kmParJour * taux)),
            ResultLine('Jours', Fmt.trim(jours)),
            ResultLine('Total', Fmt.money(total), strong: true),
          ],
        ),
      ],
    );
  }
}
