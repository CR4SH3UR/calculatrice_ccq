import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../data/ccq_data.dart';
import '../data/heures_store.dart';
import '../l10n/lang.dart';
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

  bool _parMetier = false;
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
      _snack(tr('Entre des heures avant de les noter.',
          'Enter hours before logging them.'));
      return;
    }
    await HeuresStore.instance.ajouter(HeureEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      taux: taux,
      hNormal: hN,
      h15: h15,
      h2: h2,
      metier: _parMetier ? _metier.nom : '',
      secteur: _parMetier ? _secteur.court : '',
    ));
    _snack(tr('Ajouté à ta feuille de temps ✓', 'Added to your timesheet ✓'));
  }

  Future<void> _rafraichir() async {
    if (kIsWeb) {
      _snack(tr(
          'Le rafraîchissement en direct fonctionne sur mobile — le web bloque '
              'l\'appel à la CCQ (CORS).',
          'Live refresh works on mobile — the web blocks the CCQ call (CORS).'));
      return;
    }
    setState(() => _sync = true);
    final double? taux =
        await _api.tauxCompagnon(_metier, _secteur, contexte: _contexte);
    if (!mounted) return;
    setState(() => _sync = false);
    if (taux == null) {
      _snack(tr(
          'Impossible de récupérer le taux (réseau, ou horaire/occupation '
              'absent dans cette grille).',
          'Could not fetch the rate (network, or schedule/occupation not in '
              'this grid).'));
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
    _snack(
        '${tr('Taux', 'Rate')} ${_contexte.label.toLowerCase()} ${tr('récupéré', 'fetched')} : '
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
    if (!_parMetier) return parseNum(_tauxCtrl.text) ?? 0;
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

    final String monTaux = tr('Mon taux', 'My rate');
    final String parMetier = tr('Par métier', 'By trade');

    return ToolScaffold(
      title: tr('Calculateur de paie', 'Pay calculator'),
      children: [
        ChoiceSegments(
          options: [monTaux, parMetier],
          selected: _parMetier ? parMetier : monTaux,
          onChanged: (v) => setState(() => _parMetier = v == parMetier),
        ),
        const SizedBox(height: 16),
        if (!_parMetier)
          NumberField(
            controller: _tauxCtrl,
            label: tr('Mon taux horaire', 'My hourly rate'),
            suffix: '\$/h',
            hint: tr('ex. 43,90', 'e.g. 43.90'),
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
          Text(tr('Horaire de travail', 'Work schedule'),
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
                '${tr('Convention', 'Agreement')} ${_secteur.nom} — ${tr('horaire', 'schedule')} ${_contexte.label.toLowerCase()} · '
                '${tr('palier', 'level')} ${_palier.pourcentage} % = ${Fmt.money(_tauxBase)}/h. '
                '${CcqData.enVigueurTexte} · ${tr('à valider sur', 'verify at')} ${CcqData.siteWeb}.'
                '${_secteur.note != null ? '\n${_secteur.note}' : ''}',
          ),
          if (_contexte != ContexteTravail.jour &&
              !(_compFetchedCtx == _contexte && _compFetched != null)) ...[
            const SizedBox(height: 8),
            InfoBanner(
              text: tr(
                  'Taux ${_contexte.label.toLowerCase()} : touche « Rafraîchir » '
                      'pour le chiffre officiel (mobile). En attendant, le taux '
                      'de jour est affiché à titre indicatif.',
                  'Tap « Refresh » for the official ${_contexte.label.toLowerCase()} '
                      'rate (mobile). Meanwhile, the day rate is shown as a guide.'),
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
                ? tr('Récupération…', 'Fetching…')
                : '${tr('Rafraîchir le taux', 'Refresh the')} ${_contexte.label.toLowerCase()} ${tr('(mobile)', 'rate (mobile)')}'),
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
                  Text(
                      tr('Taux vérifié en direct auprès de la CCQ',
                          'Rate verified live with the CCQ'),
                      style: const TextStyle(
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
          label: tr('Prime horaire (nuit, hauteur, etc.)',
              'Hourly premium (night, height, etc.)'),
          suffix: '\$/h',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        SectionTitle(tr('Heures travaillées', 'Hours worked'),
            color: AppColors.paie),
        NumberField(
          controller: _normalCtrl,
          label: tr('Heures normales (×1)', 'Regular hours (×1)'),
          suffix: 'h',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _demiCtrl,
          label: tr('Temps et demi (×1,5)', 'Time and a half (×1.5)'),
          suffix: 'h',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _doubleCtrl,
          label: tr('Temps double (×2)', 'Double time (×2)'),
          suffix: 'h',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Salaire brut', 'Gross pay'),
          value: Fmt.money(brut),
          color: AppColors.paie,
          icon: Icons.payments,
          details: [
            ResultLine(tr('Taux horaire', 'Hourly rate'), '${Fmt.money(taux)}/h'),
            ResultLine(tr('Total des heures', 'Total hours'),
                '${Fmt.trim(heures)} h'),
            if (payN > 0)
              ResultLine('${tr('Normales', 'Regular')} (${Fmt.trim(hN)} h)',
                  Fmt.money(payN)),
            if (pay15 > 0)
              ResultLine(
                  '${tr('Temps et demi', 'Time and a half')} (${Fmt.trim(h15)} h)',
                  Fmt.money(pay15)),
            if (pay2 > 0)
              ResultLine(
                  '${tr('Temps double', 'Double time')} (${Fmt.trim(h2)} h)',
                  Fmt.money(pay2)),
            ResultLine(tr('Salaire brut', 'Gross pay'), Fmt.money(brut),
                strong: true),
            ResultLine(
                tr('Indemnité congés (13 %)', 'Holiday pay (13%)'),
                Fmt.money(conges)),
            ResultLine(tr('Brut + congés', 'Gross + holiday'),
                Fmt.money(avecConges),
                strong: true),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _noterHeures(taux, hN, h15, h2),
          style: FilledButton.styleFrom(backgroundColor: AppColors.paie),
          icon: const Icon(Icons.post_add),
          label: Text(tr('Noter ces heures', 'Log these hours')),
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
              title: Text(tr('Estimation de la paie nette', 'Net pay estimate'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                  '${tr('Net estimé', 'Estimated net')} : ${Fmt.money(net)}',
                  style: const TextStyle(
                      color: AppColors.paie, fontWeight: FontWeight.w700)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                InfoBanner(
                  text: tr(
                      '⚠️ Estimation. Ajuste les taux : ils dépendent des '
                          'paliers d\'impôt, des maximums annuels et des '
                          'prélèvements de ta convention (syndicat, régime, '
                          'assurances).',
                      '⚠️ Estimate. Adjust the rates: they depend on tax '
                          'brackets, annual maximums and your agreement\'s '
                          'deductions (union, plan, insurance).'),
                  color: AppColors.danger,
                ),
                const SizedBox(height: 12),
                _pct(_impotCtrl,
                    tr('Impôt combiné (féd. + prov.)', 'Combined tax (fed. + prov.)')),
                _pct(_rrqCtrl, tr('RRQ', 'QPP')),
                _pct(_aeCtrl, tr('Assurance-emploi', 'Employment insurance')),
                _pct(_rqapCtrl, tr('RQAP', 'QPIP')),
                NumberField(
                  controller: _autresCtrl,
                  label: tr('Autres retenues (syndicat, régime…)',
                      'Other deductions (union, plan…)'),
                  suffix: '\$',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                ResultCard(
                  label: tr('Paie nette estimée', 'Estimated net pay'),
                  value: Fmt.money(net),
                  color: AppColors.paie,
                  icon: Icons.account_balance_wallet,
                  details: [
                    ResultLine(tr('Salaire brut', 'Gross pay'), Fmt.money(brut)),
                    ResultLine(tr('Total des retenues', 'Total deductions'),
                        '- ${Fmt.money(retenues)}'),
                    ResultLine(tr('Net estimé', 'Estimated net'), Fmt.money(net),
                        strong: true),
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
      decoration: InputDecoration(labelText: tr('Palier', 'Level')),
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
      decoration: InputDecoration(
        labelText: tr('Convention (secteur)', 'Agreement (sector)'),
        prefixIcon: const Icon(Icons.description_outlined),
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
      title: tr('Vacances & congés', 'Vacation & holidays'),
      children: [
        InfoBanner(
          text: tr(
              'Dans la construction, l\'indemnité de congés annuels et de jours '
                  'fériés est généralement d\'environ 13 % du salaire brut. Le '
                  'pourcentage exact dépend de ta convention — ajuste-le au besoin.',
              'In construction, the annual vacation and statutory holiday '
                  'allowance is usually about 13% of gross pay. The exact '
                  'percentage depends on your agreement — adjust as needed.'),
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _brutCtrl,
          label: tr('Salaire brut de la période', 'Gross pay for the period'),
          suffix: '\$',
          hint: tr('ex. 2 500', 'e.g. 2,500'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _pctCtrl,
          label: tr('Pourcentage d\'indemnité', 'Allowance percentage'),
          suffix: '%',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Indemnité de congés', 'Holiday allowance'),
          value: Fmt.money(indemnite),
          color: AppColors.paie,
          icon: Icons.beach_access,
          details: [
            ResultLine(tr('Salaire brut', 'Gross pay'), Fmt.money(brut)),
            ResultLine(tr('Taux appliqué', 'Applied rate'), Fmt.percent(pct)),
            ResultLine(tr('Indemnité', 'Allowance'), Fmt.money(indemnite),
                strong: true),
            ResultLine(tr('Brut + indemnité', 'Gross + allowance'),
                Fmt.money(brut + indemnite)),
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
      title: tr('Paie nette (estimation)', 'Net pay (estimate)'),
      children: [
        InfoBanner(
          text: tr(
              '⚠️ ESTIMATION SEULEMENT. Les vraies retenues dépendent des '
                  'paliers d\'imposition, des maximums annuels (RRQ, AE, RQAP) '
                  'et des prélèvements de ta convention (syndicat, régime de '
                  'retraite, assurances). Ajuste les taux et vois ton relevé de '
                  'paie officiel.',
              '⚠️ ESTIMATE ONLY. Actual deductions depend on tax brackets, '
                  'annual maximums (QPP, EI, QPIP) and your agreement\'s '
                  'deductions (union, pension plan, insurance). Adjust the rates '
                  'and check your official pay stub.'),
          color: AppColors.danger,
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _brutCtrl,
          label: tr('Salaire brut', 'Gross pay'),
          suffix: '\$',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        SectionTitle(tr('Retenues (taux ajustables)', 'Deductions (adjustable)'),
            color: AppColors.paie),
        _pctRow(_impotCtrl,
            tr('Impôt combiné (féd. + prov.)', 'Combined tax (fed. + prov.)')),
        _pctRow(_rrqCtrl, tr('RRQ (régime de rentes)', 'QPP (pension plan)')),
        _pctRow(_aeCtrl, tr('Assurance-emploi (AE)', 'Employment insurance (EI)')),
        _pctRow(_rqapCtrl, tr('RQAP', 'QPIP')),
        const SizedBox(height: 12),
        NumberField(
          controller: _autresCtrl,
          label: tr('Autres retenues (syndicat, régime, assurances)',
              'Other deductions (union, plan, insurance)'),
          suffix: '\$',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Paie nette estimée', 'Estimated net pay'),
          value: Fmt.money(net),
          color: AppColors.paie,
          icon: Icons.account_balance_wallet,
          details: [
            ResultLine(tr('Salaire brut', 'Gross pay'), Fmt.money(brut)),
            ResultLine(tr('Impôt', 'Tax'), '- ${Fmt.money(impot)}'),
            ResultLine(tr('RRQ', 'QPP'), '- ${Fmt.money(rrq)}'),
            ResultLine(tr('AE', 'EI'), '- ${Fmt.money(ae)}'),
            ResultLine(tr('RQAP', 'QPIP'), '- ${Fmt.money(rqap)}'),
            if (autres > 0)
              ResultLine(tr('Autres', 'Other'), '- ${Fmt.money(autres)}'),
            ResultLine(tr('Total des retenues', 'Total deductions'),
                '- ${Fmt.money(retenues)}'),
            ResultLine(tr('Net estimé', 'Estimated net'), Fmt.money(net),
                strong: true),
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
      title: tr('Frais de déplacement', 'Travel expenses'),
      children: [
        InfoBanner(
          text: tr(
              'Calcul simple : distance × taux du kilomètre × nombre de jours. '
                  'Les conventions de la construction ont aussi des règles de '
                  'zones, de transport et de pension (chambre/pension) — vérifie '
                  'ta convention pour les indemnités exactes.',
              'Simple calc: distance × per-km rate × number of days. '
                  'Construction agreements also have zone, transport and room & '
                  'board rules — check your agreement for the exact allowances.'),
        ),
        const SizedBox(height: 18),
        NumberField(
          controller: _kmCtrl,
          label: tr('Distance (un sens)', 'Distance (one way)'),
          suffix: 'km',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: _allerRetour,
          onChanged: (v) => setState(() => _allerRetour = v),
          title: Text(tr('Aller-retour', 'Round trip')),
          subtitle: Text(_allerRetour
              ? tr('La distance est comptée ×2', 'Distance counted ×2')
              : tr('Distance comptée une seule fois', 'Distance counted once')),
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _tauxCtrl,
          label: tr('Taux du kilomètre', 'Per-km rate'),
          suffix: '\$/km',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        NumberField(
          controller: _joursCtrl,
          label: tr('Nombre de jours', 'Number of days'),
          suffix: tr('j', 'd'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 22),
        ResultCard(
          label: tr('Indemnité de déplacement', 'Travel allowance'),
          value: Fmt.money(total),
          color: AppColors.paie,
          icon: Icons.directions_car,
          details: [
            ResultLine(tr('Distance par jour', 'Distance per day'),
                '${Fmt.trim(kmParJour)} km'),
            ResultLine(tr('Taux', 'Rate'), '${Fmt.money(taux)}/km'),
            ResultLine(tr('Par jour', 'Per day'), Fmt.money(kmParJour * taux)),
            ResultLine(tr('Jours', 'Days'), Fmt.trim(jours)),
            ResultLine(tr('Total', 'Total'), Fmt.money(total), strong: true),
          ],
        ),
      ],
    );
  }
}
