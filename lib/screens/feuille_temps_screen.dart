import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../data/app_prefs.dart';
import '../data/ccq_data.dart';
import '../data/feuille_pdf.dart';
import '../data/heures_store.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/metier_picker.dart';

const List<String> _joursCourts = [
  'lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'
];

String _jourDate(DateTime d) => '${_joursCourts[d.weekday - 1]} ${Fmt.dateFr(d)}';

/// Totaux agrégés d'une liste d'entrées.
class _Totaux {
  double hN = 0, h15 = 0, h2 = 0, brut = 0, prime = 0, deplacement = 0, km = 0;
  double get heures => hN + h15 + h2;
  double get conges => brut * CcqData.indemniteCongesPct / 100;
  double get avecConges => brut + conges;
  double get grandTotal => brut + deplacement;

  static _Totaux from(Iterable<HeureEntry> l) {
    final t = _Totaux();
    for (final e in l) {
      t.hN += e.hNormal;
      t.h15 += e.h15;
      t.h2 += e.h2;
      t.brut += e.brut;
      t.prime += e.prime;
      t.deplacement += e.deplacement;
      t.km += e.km;
    }
    return t;
  }
}

class FeuilleTempsScreen extends StatefulWidget {
  const FeuilleTempsScreen({super.key});

  @override
  State<FeuilleTempsScreen> createState() => _FeuilleTempsScreenState();
}

class _FeuilleTempsScreenState extends State<FeuilleTempsScreen> {
  final HeuresStore _store = HeuresStore.instance;

  @override
  void initState() {
    super.initState();
    _store.charger();
  }

  Future<void> _formulaire({HeureEntry? existant}) async {
    final HeureEntry? res = await showModalBottomSheet<HeureEntry>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: FractionallySizedBox(
          heightFactor: 0.92,
          child: _HeuresForm(existant: existant),
        ),
      ),
    );
    if (res != null) {
      if (existant != null) {
        await _store.remplacer(res);
      } else {
        await _store.ajouter(res);
      }
    }
  }

  void _copier() {
    final entries = _store.entries;
    if (entries.isEmpty) return;
    final Map<DateTime, List<HeureEntry>> parSem = {};
    for (final e in entries) {
      parSem.putIfAbsent(debutSemaine(e.date), () => []).add(e);
    }
    final semaines = parSem.keys.toList()..sort((a, b) => b.compareTo(a));
    final sb = StringBuffer('FEUILLE DE TEMPS — Calculatrice CCQ\n');
    for (final s in semaines) {
      final list = parSem[s]!..sort((a, b) => a.date.compareTo(b.date));
      final t = _Totaux.from(list);
      final fin = s.add(const Duration(days: 6));
      sb.writeln('\nSemaine du ${Fmt.dateFr(s)} au ${Fmt.dateFr(fin)}');
      for (final e in list) {
        sb.writeln('  ${_jourDate(e.date)} — ${Fmt.trim(e.heures)} h '
            '@ ${Fmt.money(e.taux)}/h = ${Fmt.money(e.brut)}'
            '${e.deplacement > 0 ? ' (+${Fmt.money(e.deplacement)} dépl.)' : ''}');
      }
      sb.writeln('  Total : ${Fmt.trim(t.heures)} h · ${Fmt.money(t.brut)} '
          '(+13 % = ${Fmt.money(t.avecConges)})');
    }
    final tt = _Totaux.from(entries);
    sb.writeln('\nTOTAL : ${Fmt.trim(tt.heures)} h · brut ${Fmt.money(tt.brut)}'
        '${tt.deplacement > 0 ? ' · déplacement ${Fmt.money(tt.deplacement)}' : ''}');
    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feuille de temps copiée ✓')));
  }

  Future<void> _partagerPdf() async {
    final bytes = await genererFeuillePdf(_store.entries);
    await Printing.sharePdf(bytes: bytes, filename: 'feuille-de-temps.pdf');
  }

  Future<void> _dupliquer(HeureEntry e) async {
    await _store.ajouter(HeureEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      taux: e.taux,
      hNormal: e.hNormal,
      h15: e.h15,
      h2: e.h2,
      prime: e.prime,
      km: e.km,
      tauxKm: e.tauxKm,
      metier: e.metier,
      secteur: e.secteur,
      employeur: e.employeur,
      note: e.note,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Journée dupliquée à aujourd\'hui ✓')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feuille de temps'),
        actions: [
          ListenableBuilder(
            listenable: _store,
            builder: (_, _) {
              final bool vide = _store.estVide;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Copier le texte',
                    icon: const Icon(Icons.content_copy),
                    onPressed: vide ? null : _copier,
                  ),
                  IconButton(
                    tooltip: 'Partager en PDF',
                    icon: const Icon(Icons.picture_as_pdf),
                    onPressed: vide ? null : _partagerPdf,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _formulaire(),
        backgroundColor: AppColors.paie,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _store,
          builder: (context, _) {
            final List<HeureEntry> entries = _store.entries;
            if (entries.isEmpty) return const _VideEtat();

            final Map<DateTime, List<HeureEntry>> parSemaine = {};
            for (final e in entries) {
              parSemaine.putIfAbsent(debutSemaine(e.date), () => []).add(e);
            }
            final semaines = parSemaine.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            final DateTime semActuelle = debutSemaine(DateTime.now());
            final List<HeureEntry> cetteSemaine =
                parSemaine[semActuelle] ?? const [];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                _Resume(cetteSemaine: cetteSemaine, toutes: entries),
                const SizedBox(height: 18),
                for (final s in semaines) ...[
                  _EnteteSemaine(debut: s, entries: parSemaine[s]!),
                  ...parSemaine[s]!.map((e) => _EntreeTile(
                        entry: e,
                        onTap: () => _formulaire(existant: e),
                        onDelete: () => _store.supprimer(e.id),
                        onDuplicate: () => _dupliquer(e),
                      )),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VideEtat extends StatelessWidget {
  const _VideEtat();
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_note, size: 64, color: c.withValues(alpha: 0.25)),
            const SizedBox(height: 16),
            Text('Aucune heure notée',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: c.withValues(alpha: 0.8))),
            const SizedBox(height: 8),
            Text(
              'Touche « Ajouter » pour noter ta journée : heures, taux, primes '
              'et déplacement. Les totaux et la paie brute se calculent tout '
              'seuls, par semaine.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.5, height: 1.4, color: c.withValues(alpha: 0.55)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Resume extends StatelessWidget {
  const _Resume({required this.cetteSemaine, required this.toutes});
  final List<HeureEntry> cetteSemaine;
  final List<HeureEntry> toutes;

  @override
  Widget build(BuildContext context) {
    final t = _Totaux.from(cetteSemaine);
    final g = _Totaux.from(toutes);
    return Column(
      children: [
        ResultCard(
          label: 'Cette semaine',
          value: Fmt.money(t.brut),
          color: AppColors.paie,
          icon: Icons.calendar_view_week,
          details: [
            ResultLine('Heures (norm. / 1,5 / 2)',
                '${Fmt.trim(t.hN)} / ${Fmt.trim(t.h15)} / ${Fmt.trim(t.h2)}'),
            ResultLine('Total heures', '${Fmt.trim(t.heures)} h'),
            if (t.prime > 0) ResultLine('Primes incluses', Fmt.money(t.prime)),
            if (t.deplacement > 0)
              ResultLine('Déplacement', Fmt.money(t.deplacement)),
            ResultLine('Brut + congés 13 %', Fmt.money(t.avecConges),
                strong: true),
            const ResultLine('———', ''),
            ResultLine('Total heures notées', '${Fmt.trim(g.heures)} h'),
            ResultLine('Brut total', Fmt.money(g.brut)),
            if (g.deplacement > 0)
              ResultLine('Déplacement total', Fmt.money(g.deplacement)),
            if (g.km > 0)
              ResultLine('Km cumulés', '${Fmt.trim(g.km)} km'),
          ],
        ),
        const SizedBox(height: 12),
        _Objectif(heuresSemaine: t.heures),
      ],
    );
  }
}

class _Objectif extends StatelessWidget {
  const _Objectif({required this.heuresSemaine});
  final double heuresSemaine;

  Future<void> _editer(BuildContext context, double courant) async {
    final ctrl = TextEditingController(text: Fmt.trim(courant));
    final res = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Objectif d\'heures par semaine'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: 'h'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, parseNum(ctrl.text) ?? courant),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (res != null) await AppPrefs.setObjectif(res);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: AppPrefs.objectifHebdo,
      builder: (context, obj, _) {
        final double pct =
            obj > 0 ? (heuresSemaine / obj).clamp(0.0, 1.0) : 0.0;
        final onSurf = Theme.of(context).colorScheme.onSurface;
        return InkWell(
          onTap: () => _editer(context, obj),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.flag, size: 17, color: AppColors.paie),
                      const SizedBox(width: 6),
                      const Text('Objectif hebdo',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                    Text('${Fmt.trim(heuresSemaine)} / ${Fmt.trim(obj)} h',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, color: AppColors.paie)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 9,
                    backgroundColor: AppColors.paie.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation(AppColors.paie),
                  ),
                ),
                const SizedBox(height: 6),
                Text('${(pct * 100).round()} % · touche pour modifier',
                    style: TextStyle(
                        fontSize: 11.5, color: onSurf.withValues(alpha: 0.55))),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EnteteSemaine extends StatelessWidget {
  const _EnteteSemaine({required this.debut, required this.entries});
  final DateTime debut;
  final List<HeureEntry> entries;

  @override
  Widget build(BuildContext context) {
    final DateTime fin = debut.add(const Duration(days: 6));
    final t = _Totaux.from(entries);
    final c = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Semaine du ${Fmt.dateFr(debut)} au ${Fmt.dateFr(fin)}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: c.withValues(alpha: 0.7)),
            ),
          ),
          Text('${Fmt.trim(t.heures)} h · ${Fmt.money(t.brut)}',
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.paie)),
        ],
      ),
    );
  }
}

class _EntreeTile extends StatelessWidget {
  const _EntreeTile({
    required this.entry,
    required this.onTap,
    required this.onDelete,
    required this.onDuplicate,
  });
  final HeureEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurface;
    final sousTitre = <String>[
      if (entry.hNormal > 0) '${Fmt.trim(entry.hNormal)}×1',
      if (entry.h15 > 0) '${Fmt.trim(entry.h15)}×1,5',
      if (entry.h2 > 0) '${Fmt.trim(entry.h2)}×2',
      if (entry.prime > 0) '+${Fmt.money(entry.prime)} prime',
      if (entry.deplacement > 0) '+${Fmt.money(entry.deplacement)} dépl.',
    ].join('  ·  ');
    final ligne2 = [
      if (entry.metier.isNotEmpty) entry.metier,
      if (entry.employeur.isNotEmpty) entry.employeur,
      if (entry.note.isNotEmpty) entry.note,
    ].join(' — ');

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 22),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.paie.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.copy, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          onDuplicate();
          return false; // glisser à droite = dupliquer, garder la ligne
        }
        return true; // glisser à gauche = supprimer
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 46,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.paie.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Column(
                    children: [
                      Text(_joursCourts[entry.date.weekday - 1],
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.paie)),
                      Text('${entry.date.day}',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${Fmt.trim(entry.heures)} h · ${Fmt.money(entry.taux)}/h',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      if (sousTitre.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(sousTitre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11.5,
                                color: c.withValues(alpha: 0.6))),
                      ],
                      if (ligne2.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(ligne2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: c.withValues(alpha: 0.5))),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(Fmt.money(entry.total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColors.paie)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  FORMULAIRE d'ajout / édition
// ─────────────────────────────────────────────────────────────────────────
class _HeuresForm extends StatefulWidget {
  const _HeuresForm({this.existant});
  final HeureEntry? existant;

  @override
  State<_HeuresForm> createState() => _HeuresFormState();
}

class _HeuresFormState extends State<_HeuresForm> {
  late DateTime _date;
  String _mode = 'Mon taux';
  Secteur _secteur = Secteur.institutionnelCommercial;
  Metier _metier = CcqData.metiers.firstWhere(
      (m) => m.nom == 'Charpentier-menuisier',
      orElse: () => CcqData.metiers.first);
  int _palierIndex = 999;

  late final TextEditingController _tauxCtrl;
  late final TextEditingController _nCtrl;
  late final TextEditingController _demiCtrl;
  late final TextEditingController _doubleCtrl;
  late final TextEditingController _primeCtrl;
  late final TextEditingController _kmCtrl;
  late final TextEditingController _tauxKmCtrl;
  late final TextEditingController _employeurCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existant;
    _date = e?.date ?? DateTime.now();
    _tauxCtrl = TextEditingController(text: e != null ? Fmt.trim(e.taux) : '');
    _nCtrl = TextEditingController(
        text: e != null && e.hNormal > 0 ? Fmt.trim(e.hNormal) : '');
    _demiCtrl = TextEditingController(
        text: e != null && e.h15 > 0 ? Fmt.trim(e.h15) : '');
    _doubleCtrl = TextEditingController(
        text: e != null && e.h2 > 0 ? Fmt.trim(e.h2) : '');
    _primeCtrl = TextEditingController(
        text: e != null && e.prime > 0 ? Fmt.trim(e.prime) : '');
    _kmCtrl =
        TextEditingController(text: e != null && e.km > 0 ? Fmt.trim(e.km) : '');
    _tauxKmCtrl = TextEditingController(
        text: e != null && e.tauxKm > 0 ? Fmt.trim(e.tauxKm) : '0,72');
    _employeurCtrl = TextEditingController(text: e?.employeur ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _tauxCtrl,
      _nCtrl,
      _demiCtrl,
      _doubleCtrl,
      _primeCtrl,
      _kmCtrl,
      _tauxKmCtrl,
      _employeurCtrl,
      _noteCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _idx {
    final n = _metier.paliers().length;
    return _palierIndex.clamp(0, n - 1);
  }

  double get _taux {
    if (_mode == 'Mon taux') return parseNum(_tauxCtrl.text) ?? 0;
    return CcqData.taux(_metier, _secteur, _metier.paliers()[_idx].pourcentage);
  }

  Future<void> _choisirDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  void _enregistrer() {
    final entry = HeureEntry(
      id: widget.existant?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      date: _date,
      taux: _taux,
      hNormal: parseNum(_nCtrl.text) ?? 0,
      h15: parseNum(_demiCtrl.text) ?? 0,
      h2: parseNum(_doubleCtrl.text) ?? 0,
      prime: parseNum(_primeCtrl.text) ?? 0,
      km: parseNum(_kmCtrl.text) ?? 0,
      tauxKm: parseNum(_tauxKmCtrl.text) ?? 0,
      metier: _mode == 'Par métier' ? _metier.nom : (widget.existant?.metier ?? ''),
      secteur:
          _mode == 'Par métier' ? _secteur.court : (widget.existant?.secteur ?? ''),
      employeur: _employeurCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final double taux = _taux;
    final double hN = parseNum(_nCtrl.text) ?? 0;
    final double h15 = parseNum(_demiCtrl.text) ?? 0;
    final double h2 = parseNum(_doubleCtrl.text) ?? 0;
    final double prime = parseNum(_primeCtrl.text) ?? 0;
    final double km = parseNum(_kmCtrl.text) ?? 0;
    final double tauxKm = parseNum(_tauxKmCtrl.text) ?? 0;
    final double brut = taux * hN + taux * 1.5 * h15 + taux * 2 * h2 + prime;
    final double dep = km * tauxKm;

    return ListView(
      controller: PrimaryScrollController.maybeOf(context),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Text(widget.existant == null ? 'Noter des heures' : 'Modifier',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        InkWell(
          onTap: _choisirDate,
          borderRadius: BorderRadius.circular(14),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(_jourDate(_date)),
          ),
        ),
        const SizedBox(height: 14),
        ChoiceSegments(
          options: const ['Mon taux', 'Par métier'],
          selected: _mode,
          onChanged: (v) => setState(() => _mode = v),
        ),
        const SizedBox(height: 12),
        if (_mode == 'Mon taux')
          NumberField(
            controller: _tauxCtrl,
            label: 'Taux horaire',
            suffix: '\$/h',
            hint: 'ex. 43,90',
            onChanged: (_) => setState(() {}),
          )
        else ...[
          DropdownButtonFormField<Secteur>(
            initialValue: _secteur,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Convention (secteur)'),
            items: Secteur.values
                .map((s) =>
                    DropdownMenuItem(value: s, child: Text(s.nom)))
                .toList(),
            onChanged: (s) => s == null ? null : setState(() => _secteur = s),
          ),
          const SizedBox(height: 12),
          MetierField(
            metier: _metier,
            color: AppColors.paie,
            onChanged: (m) => setState(() => _metier = m),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _idx,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Palier'),
            items: [
              for (int i = 0; i < _metier.paliers().length; i++)
                DropdownMenuItem(
                    value: i,
                    child: Text(
                        '${_metier.paliers()[i].nom} (${_metier.paliers()[i].pourcentage} %)')),
            ],
            onChanged: (i) => setState(() => _palierIndex = i ?? 999),
          ),
          const SizedBox(height: 8),
          Text('Taux : ${Fmt.money(taux)}/h',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.paie)),
        ],
        const SizedBox(height: 16),
        const SectionTitle('Heures', color: AppColors.paie),
        Row(
          children: [
            Expanded(
                child: NumberField(
                    controller: _nCtrl,
                    label: 'Normales',
                    suffix: 'h',
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(
                child: NumberField(
                    controller: _demiCtrl,
                    label: '×1,5',
                    suffix: 'h',
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(
                child: NumberField(
                    controller: _doubleCtrl,
                    label: '×2',
                    suffix: 'h',
                    onChanged: (_) => setState(() {}))),
          ],
        ),
        const SizedBox(height: 12),
        NumberField(
            controller: _primeCtrl,
            label: 'Prime (montant de la journée)',
            suffix: '\$',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),
        const SectionTitle('Déplacement', color: AppColors.paie),
        Row(
          children: [
            Expanded(
                child: NumberField(
                    controller: _kmCtrl,
                    label: 'Distance',
                    suffix: 'km',
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(
                child: NumberField(
                    controller: _tauxKmCtrl,
                    label: 'Taux',
                    suffix: '\$/km',
                    onChanged: (_) => setState(() {}))),
          ],
        ),
        const SizedBox(height: 16),
        const SectionTitle('Détails', color: AppColors.paie),
        TextField(
          controller: _employeurCtrl,
          decoration: const InputDecoration(
            labelText: 'Employeur',
            prefixIcon: Icon(Icons.business),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteCtrl,
          decoration: const InputDecoration(
            labelText: 'Chantier / note',
            prefixIcon: Icon(Icons.notes),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.paie.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _ligne('Brut de la journée', Fmt.money(brut), fort: true),
              if (dep > 0) _ligne('Déplacement', Fmt.money(dep)),
              if (dep > 0)
                _ligne('Total', Fmt.money(brut + dep), fort: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _enregistrer,
          style: FilledButton.styleFrom(backgroundColor: AppColors.paie),
          icon: const Icon(Icons.check),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }

  Widget _ligne(String k, String v, {bool fort = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k,
                style: TextStyle(
                    fontWeight: fort ? FontWeight.w700 : FontWeight.w500)),
            Text(v,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: fort ? 17 : 14,
                    color: AppColors.paie)),
          ],
        ),
      );
}
