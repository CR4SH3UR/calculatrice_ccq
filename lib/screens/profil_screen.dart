import 'package:flutter/material.dart';

import '../data/app_prefs.dart';
import '../data/ccq_data.dart';
import '../data/profil.dart';
import '../data/syndicats.dart';
import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/link_tile.dart';
import '../widgets/metier_picker.dart';

/// Groupes sanguins proposés (aucun = «  »).
const List<String> _groupesSanguins = [
  'O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'
];

/// Page « Mon profil » : infos de travail utiles, gardées localement.
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  late final TextEditingController _region;
  late final TextEditingController _employeur;
  late final TextEditingController _competence;
  late final TextEditingController _taux;
  late final TextEditingController _urgenceNom;
  late final TextEditingController _urgenceTel;
  late final TextEditingController _allergies;

  String _metier = '';
  String _secteur = '';
  String _syndicat = '';
  String _groupeSanguin = '';
  DateTime? _aspExpiration;

  @override
  void initState() {
    super.initState();
    final p = AppPrefs.profil.value;
    _region = TextEditingController(text: p.region);
    _employeur = TextEditingController(text: p.employeur);
    _competence = TextEditingController(text: p.numeroCompetence);
    _taux = TextEditingController(
        text: p.tauxHoraire == null ? '' : Fmt.trim(p.tauxHoraire!));
    _urgenceNom = TextEditingController(text: p.urgenceNom);
    _urgenceTel = TextEditingController(text: p.urgenceTel);
    _allergies = TextEditingController(text: p.allergies);
    _metier = p.metier;
    _secteur = p.secteur;
    _syndicat = p.syndicat;
    _groupeSanguin = p.groupeSanguin;
    _aspExpiration = p.aspExpiration;
  }

  @override
  void dispose() {
    _region.dispose();
    _employeur.dispose();
    _competence.dispose();
    _taux.dispose();
    _urgenceNom.dispose();
    _urgenceTel.dispose();
    _allergies.dispose();
    super.dispose();
  }

  void _save() {
    AppPrefs.setProfil(Profil(
      metier: _metier,
      secteur: _secteur,
      region: _region.text.trim(),
      employeur: _employeur.text.trim(),
      numeroCompetence: _competence.text.trim(),
      aspExpiration: _aspExpiration,
      tauxHoraire: parseNum(_taux.text),
      syndicat: _syndicat,
      urgenceNom: _urgenceNom.text.trim(),
      urgenceTel: _urgenceTel.text.trim(),
      groupeSanguin: _groupeSanguin,
      allergies: _allergies.text.trim(),
    ));
  }

  Metier? get _metierObj {
    final m = CcqData.metiers.where((x) => x.nom == _metier);
    return m.isEmpty ? null : m.first;
  }

  Future<void> _choisirMetier() async {
    final m = await showMetierPicker(context, selected: _metierObj);
    if (m != null) {
      setState(() => _metier = m.nom);
      _save();
    }
  }

  Future<void> _choisirAsp() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _aspExpiration ?? DateTime(now.year + 3, now.month, now.day),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (d != null) {
      setState(() => _aspExpiration = d);
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    const c = AppColors.paie;
    return ToolScaffold(
      title: tr('Mon profil', 'My profile'),
      children: [
        InfoBanner(
          text: tr(
              'Tes infos restent sur ton téléphone (rien n\'est envoyé sur '
                  'Internet). Elles servent à pré-remplir la paie et à avoir tes '
                  'infos utiles à portée de main sur le chantier.',
              'Your info stays on your phone (nothing is sent online). It '
                  'pre-fills the pay calculator and keeps your useful info handy '
                  'on the jobsite.'),
          icon: Icons.lock_outline,
          color: c,
        ),
        const SizedBox(height: 16),

        // ── Emploi ──────────────────────────────────────────────────────
        SectionTitle(tr('Emploi', 'Employment'), color: c),
        const SizedBox(height: 10),
        _MetierField(
            metier: _metierObj, onTap: _choisirMetier, onClear: () {
          setState(() => _metier = '');
          _save();
        }),
        const SizedBox(height: 12),
        _dropdown(
          label: tr('Secteur habituel', 'Usual sector'),
          icon: Icons.description_outlined,
          value: _secteur,
          items: {
            for (final s in Secteur.values) s.name: s.nom,
          },
          onChanged: (v) {
            setState(() => _secteur = v);
            _save();
          },
        ),
        const SizedBox(height: 12),
        _textField(_region, tr('Région', 'Region'), Icons.place_outlined,
            hint: tr('Ex. Montréal, Québec, Saguenay…',
                'E.g. Montreal, Quebec, Saguenay…')),
        const SizedBox(height: 12),
        _textField(_employeur, tr('Employeur', 'Employer'),
            Icons.business_outlined),
        const SizedBox(height: 20),

        // ── Certification ───────────────────────────────────────────────
        SectionTitle(tr('Certification', 'Certification'), color: c),
        const SizedBox(height: 10),
        _textField(_competence,
            tr('N° certificat de compétence', 'Competency certificate no.'),
            Icons.badge_outlined,
            keyboardType: TextInputType.text),
        const SizedBox(height: 12),
        _AspField(
            date: _aspExpiration,
            jours: _profilJoursAsp,
            onTap: _choisirAsp,
            onClear: () {
              setState(() => _aspExpiration = null);
              _save();
            }),
        const SizedBox(height: 20),

        // ── Paie ────────────────────────────────────────────────────────
        SectionTitle(tr('Paie', 'Pay'), color: c),
        const SizedBox(height: 10),
        NumberField(
          controller: _taux,
          label: tr('Taux horaire', 'Hourly rate'),
          suffix: r'$/h',
          hint: tr('Pré-remplit le calculateur de paie',
              'Pre-fills the pay calculator'),
          onChanged: (_) => _save(),
        ),
        const SizedBox(height: 12),
        _dropdown(
          label: tr('Allégeance syndicale', 'Union allegiance'),
          icon: Icons.groups_outlined,
          value: _syndicat,
          items: {for (final u in syndicats) u.sigle: u.sigle},
          onChanged: (v) {
            setState(() => _syndicat = v);
            _save();
          },
        ),
        const SizedBox(height: 20),

        // ── Urgence & santé ─────────────────────────────────────────────
        SectionTitle(tr('Urgence & santé', 'Emergency & health'), color: c),
        const SizedBox(height: 6),
        Text(
            tr('En cas d\'accident sur le chantier.',
                'In case of an accident on the jobsite.'),
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6))),
        const SizedBox(height: 10),
        _textField(_urgenceNom,
            tr('Contact d\'urgence', 'Emergency contact'), Icons.person_outline),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _textField(_urgenceTel,
                  tr('Téléphone d\'urgence', 'Emergency phone'), Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: _urgenceTel.text.trim().isEmpty
                  ? null
                  : () => appelerNumero(context, _urgenceTel.text.trim()),
              icon: const Icon(Icons.call),
              tooltip: tr('Appeler', 'Call'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _dropdown(
          label: tr('Groupe sanguin', 'Blood type'),
          icon: Icons.bloodtype_outlined,
          value: _groupeSanguin,
          items: {for (final g in _groupesSanguins) g: g},
          onChanged: (v) {
            setState(() => _groupeSanguin = v);
            _save();
          },
        ),
        const SizedBox(height: 12),
        _textField(_allergies,
            tr('Allergies / notes médicales', 'Allergies / medical notes'),
            Icons.medical_information_outlined,
            maxLines: 2),
      ],
    );
  }

  int? get _profilJoursAsp {
    final d = _aspExpiration;
    if (d == null) return null;
    final now = DateTime.now();
    return DateTime(d.year, d.month, d.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  Widget _textField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (_) => _save(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) {
    // La valeur peut être hors liste (ancienne saisie) : on la ramène à «  ».
    final String val = items.containsKey(value) ? value : '';
    return DropdownButtonFormField<String>(
      initialValue: val,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: [
        DropdownMenuItem(value: '', child: Text(tr('— Non précisé', '— Not set'))),
        for (final e in items.entries)
          DropdownMenuItem(value: e.key, child: Text(e.value)),
      ],
      onChanged: (v) => onChanged(v ?? ''),
    );
  }
}

/// Champ tactile affichant le métier choisi (ou une invite).
class _MetierField extends StatelessWidget {
  const _MetierField(
      {required this.metier, required this.onTap, required this.onClear});
  final Metier? metier;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final onSurf = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: tr('Métier', 'Trade'),
          prefixIcon: Icon(metier?.icon ?? Icons.engineering, color: AppColors.paie),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                metier?.nomAffiche ??
                    tr('Choisir mon métier', 'Choose my trade'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: metier == null
                        ? onSurf.withValues(alpha: 0.5)
                        : onSurf),
              ),
            ),
            if (metier != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close,
                    size: 20, color: onSurf.withValues(alpha: 0.5)),
              )
            else
              Icon(Icons.search,
                  size: 20, color: onSurf.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

/// Champ tactile pour la date d'expiration de la carte ASP + statut.
class _AspField extends StatelessWidget {
  const _AspField(
      {required this.date,
      required this.jours,
      required this.onTap,
      required this.onClear});
  final DateTime? date;
  final int? jours;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final onSurf = Theme.of(context).colorScheme.onSurface;
    Color? statutColor;
    String? statut;
    if (jours != null) {
      if (jours! < 0) {
        statutColor = AppColors.danger;
        statut = tr('Expirée', 'Expired');
      } else if (jours! <= 60) {
        statutColor = AppColors.warning;
        statut = '${tr('Expire dans', 'Expires in')} $jours ${tr('jours', 'days')}';
      } else {
        statutColor = AppColors.success;
        statut = tr('Valide', 'Valid');
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Carte ASP',
              prefixIcon: Icon(Icons.event_available_outlined),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date == null
                        ? tr('Date d\'expiration', 'Expiry date')
                        : Fmt.dateFr(date!),
                    style: TextStyle(
                        color: date == null
                            ? onSurf.withValues(alpha: 0.5)
                            : onSurf),
                  ),
                ),
                if (date != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(Icons.close,
                        size: 20, color: onSurf.withValues(alpha: 0.5)),
                  )
                else
                  Icon(Icons.calendar_today,
                      size: 18, color: onSurf.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
        if (statut != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                Icon(Icons.circle, size: 9, color: statutColor),
                const SizedBox(width: 6),
                Text(statut,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statutColor)),
              ],
            ),
          ),
      ],
    );
  }
}
