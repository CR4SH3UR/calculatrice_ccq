import 'package:flutter/material.dart';

import '../data/app_prefs.dart';
import '../data/representants.dart';
import '../data/syndicats.dart';
import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/link_tile.dart';

class SyndicatScreen extends StatelessWidget {
  const SyndicatScreen({super.key});

  Future<void> _editerRep(BuildContext context, {Representant? existant}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: _RepForm(existant: existant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: tr('Syndicats', 'Unions'),
      children: [
        InfoBanner(
          text: tr(
              'La construction au Québec compte 5 associations syndicales '
                  'représentatives (loi R-20). Tu choisis ton allégeance lors '
                  'du scrutin syndical; la représentativité ci-dessous vient du '
                  'scrutin de 2024. Touche « Appeler » pour joindre le siège, ou '
                  '« Représentants » pour trouver le tien.',
              'Quebec construction has 5 representative union associations '
                  '(Act R-20). You choose your allegiance at the union vote; the '
                  'representativity below comes from the 2024 vote. Tap « Call » '
                  'to reach the head office, or « Representatives » to find '
                  'yours.'),
          icon: Icons.groups,
          color: AppColors.syndicat,
        ),
        const SizedBox(height: 16),
        SectionTitle(tr('Les 5 associations', 'The 5 associations'),
            color: AppColors.syndicat),
        ...syndicats.map((u) => _UnionCard(union: u)),
        const SizedBox(height: 16),

        // ── Mes représentants (saisis par l'utilisateur) ─────────────────
        SectionTitle(tr('Mes représentants', 'My representatives'),
            color: AppColors.syndicat),
        InfoBanner(
          text: tr(
              'Ajoute ici les coordonnées de TES représentants (délégué de '
                  'chantier, agent d\'affaires…). Elles restent sur ton téléphone. '
                  'Pour trouver le bon représentant, utilise « Représentants » sur '
                  'la carte de ton syndicat ci-dessus.',
              'Add YOUR representatives\' contact info here (site steward, '
                  'business agent…). It stays on your phone. To find the right '
                  'representative, use « Representatives » on your union\'s card '
                  'above.'),
          icon: Icons.contacts,
          color: AppColors.syndicat,
        ),
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: AppPrefs.representants,
          builder: (context, _) {
            final reps = AppPrefs.representants.all;
            return Column(
              children: [
                for (final r in reps)
                  _RepCard(
                    rep: r,
                    onEdit: () => _editerRep(context, existant: r),
                    onDelete: () => AppPrefs.representants.supprimer(r.id),
                  ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _editerRep(context),
                    icon: const Icon(Icons.person_add_alt),
                    label: Text(tr('Ajouter un représentant',
                        'Add a representative')),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        SectionTitle(tr('Cotisations syndicales', 'Union dues'),
            color: AppColors.syndicat),
        InfoBanner(
          text: tr(
              'La cotisation syndicale est prélevée chaque semaine sur ta paie. '
                  'Le montant varie selon le syndicat, le métier et l\'horaire '
                  'de travail. Tu la vois sur ton relevé de paie.',
              'Union dues are deducted from your pay each week. The amount '
                  'varies by union, trade and work schedule. You see it on your '
                  'pay stub.'),
        ),
        const SizedBox(height: 12),
        LinkTile(
          icon: Icons.request_quote,
          title: tr('Taux de cotisations syndicales', 'Union dues rates'),
          subtitle: tr('Montants officiels · ccq.org', 'Official amounts · ccq.org'),
          url: 'https://www.ccq.org/fr-CA/avantages-sociaux/salaire-taux/cotisations-syndicales',
          color: AppColors.syndicat,
        ),
        LinkTile(
          icon: Icons.how_to_vote,
          title: tr('Associations & scrutin syndical', 'Associations & union vote'),
          subtitle: tr('Rôles, représentativité, changement d\'allégeance',
              'Roles, representativity, changing allegiance'),
          url: 'https://www.ccq.org/fr-CA/loi-r20/relations-travail/associations-syndicales',
          color: AppColors.syndicat,
        ),
      ],
    );
  }
}

class _UnionCard extends StatelessWidget {
  const _UnionCard({required this.union});
  final Syndicat union;

  @override
  Widget build(BuildContext context) {
    final Color onSurf = Theme.of(context).colorScheme.onSurface;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.syndicat.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.groups,
                      color: AppColors.syndicat, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(union.sigle,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15.5)),
                      Text(union.nom,
                          style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              color: onSurf.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: union.representativite / 100,
                      minHeight: 7,
                      backgroundColor:
                          AppColors.syndicat.withValues(alpha: 0.12),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.syndicat),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${union.representativite.toStringAsFixed(1)} %',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.syndicat)),
              ],
            ),
            const SizedBox(height: 12),
            if (union.telephone != null) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => appelerNumero(context, union.telephone!),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.syndicat),
                  icon: const Icon(Icons.call, size: 18),
                  label: Text('${tr('Appeler', 'Call')} · ${union.telephone}'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: _LinkChip(
                    icon: Icons.language,
                    label: tr('Site web', 'Website'),
                    onTap: () => openUrl(context, union.site),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LinkChip(
                    icon: Icons.contact_phone,
                    label: tr('Représentants', 'Representatives'),
                    onTap: () => openUrl(context, union.representants),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte d'un représentant personnel, avec actions appeler/écrire/modifier.
class _RepCard extends StatelessWidget {
  const _RepCard(
      {required this.rep, required this.onEdit, required this.onDelete});
  final Representant rep;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final onSurf = Theme.of(context).colorScheme.onSurface;
    final sousTitre = [
      if (rep.poste.isNotEmpty) rep.poste,
      if (rep.syndicat.isNotEmpty) rep.syndicat,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rep.nom.isEmpty ? tr('(Sans nom)', '(No name)') : rep.nom,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      if (sousTitre.isNotEmpty)
                        Text(sousTitre,
                            style: TextStyle(
                                fontSize: 12.5,
                                color: onSurf.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: tr('Modifier', 'Edit'),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: tr('Supprimer', 'Delete'),
                  onPressed: onDelete,
                ),
              ],
            ),
            if (rep.telephone.isNotEmpty || rep.courriel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 8),
                child: Row(
                  children: [
                    if (rep.telephone.isNotEmpty)
                      Expanded(
                        child: _LinkChip(
                          icon: Icons.call,
                          label: rep.telephone,
                          filled: true,
                          onTap: () => appelerNumero(context, rep.telephone),
                        ),
                      ),
                    if (rep.telephone.isNotEmpty && rep.courriel.isNotEmpty)
                      const SizedBox(width: 10),
                    if (rep.courriel.isNotEmpty)
                      Expanded(
                        child: _LinkChip(
                          icon: Icons.mail_outline,
                          label: tr('Écrire', 'Email'),
                          onTap: () => envoyerCourriel(context, rep.courriel),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Formulaire d'ajout / modification d'un représentant.
class _RepForm extends StatefulWidget {
  const _RepForm({this.existant});
  final Representant? existant;

  @override
  State<_RepForm> createState() => _RepFormState();
}

class _RepFormState extends State<_RepForm> {
  late final TextEditingController _nom;
  late final TextEditingController _poste;
  late final TextEditingController _tel;
  late final TextEditingController _courriel;
  String _syndicat = '';

  @override
  void initState() {
    super.initState();
    final e = widget.existant;
    _nom = TextEditingController(text: e?.nom ?? '');
    _poste = TextEditingController(text: e?.poste ?? '');
    _tel = TextEditingController(text: e?.telephone ?? '');
    _courriel = TextEditingController(text: e?.courriel ?? '');
    _syndicat = e?.syndicat ?? '';
  }

  @override
  void dispose() {
    _nom.dispose();
    _poste.dispose();
    _tel.dispose();
    _courriel.dispose();
    super.dispose();
  }

  void _enregistrer() {
    final e = widget.existant;
    AppPrefs.representants.enregistrer(Representant(
      id: e?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      nom: _nom.text.trim(),
      poste: _poste.text.trim(),
      telephone: _tel.text.trim(),
      courriel: _courriel.text.trim(),
      syndicat: _syndicat,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final sigles = {for (final u in syndicats) u.sigle: u.sigle};
    final String val = sigles.containsKey(_syndicat) ? _syndicat : '';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              widget.existant == null
                  ? tr('Nouveau représentant', 'New representative')
                  : tr('Modifier le représentant', 'Edit representative'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 14),
          TextField(
            controller: _nom,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                labelText: tr('Nom', 'Name'),
                prefixIcon: const Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _poste,
            decoration: InputDecoration(
                labelText: tr('Poste / fonction', 'Position / role'),
                hintText: tr('Ex. délégué de chantier, agent d\'affaires',
                    'E.g. site steward, business agent'),
                prefixIcon: const Icon(Icons.badge_outlined)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tel,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                labelText: tr('Téléphone', 'Phone'),
                prefixIcon: const Icon(Icons.phone_outlined)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _courriel,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                labelText: tr('Courriel', 'Email'),
                prefixIcon: const Icon(Icons.mail_outline)),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: val,
            isExpanded: true,
            decoration: InputDecoration(
                labelText: tr('Allégeance syndicale', 'Union allegiance'),
                prefixIcon: const Icon(Icons.groups_outlined)),
            items: [
              DropdownMenuItem(
                  value: '', child: Text(tr('— Non précisé', '— Not set'))),
              for (final s in sigles.keys)
                DropdownMenuItem(value: s, child: Text(s)),
            ],
            onChanged: (v) => setState(() => _syndicat = v ?? ''),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(tr('Annuler', 'Cancel')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _enregistrer,
                  child: Text(tr('Enregistrer', 'Save')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    const Color c = AppColors.syndicat;
    return Material(
      color: filled ? c : c.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: filled ? Colors.white : c),
              const SizedBox(width: 7),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: filled ? Colors.white : c)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
