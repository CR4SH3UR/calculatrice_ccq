import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/ccq_data.dart';
import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/metier_picker.dart';

// ─────────────────────────────────────────────────────────────────────────
//  TAUX PAR MÉTIER (par secteur / convention)
// ─────────────────────────────────────────────────────────────────────────
class TauxMetiersScreen extends StatefulWidget {
  const TauxMetiersScreen({super.key});

  @override
  State<TauxMetiersScreen> createState() => _TauxMetiersScreenState();
}

class _TauxMetiersScreenState extends State<TauxMetiersScreen> {
  Secteur _secteur = Secteur.institutionnelCommercial;
  final _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String q = foldRecherche(_q.trim());
    final List<Metier> metiers = q.isEmpty
        ? CcqData.metiers
        : CcqData.metiers
            .where((m) =>
                foldRecherche('${m.nom} ${m.nomAffiche}').contains(q))
            .toList();

    return ToolScaffold(
      title: tr('Taux par métier', 'Rates by trade'),
      children: [
        InfoBanner(
          text: tr(
              'Taux de salaire par grille — ${CcqData.enVigueurTexte}. '
                  'Touche un métier pour voir les paliers et les prochains taux. '
                  '${CcqData.source}',
              'Wage rates by schedule — ${CcqData.enVigueurTexte}. '
                  'Tap a trade to see the steps and upcoming rates. '
                  '${CcqData.source}'),
          color: AppColors.warning,
        ),
        const SizedBox(height: 16),
        Text(tr('Convention (secteur)', 'Agreement (sector)'),
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75))),
        const SizedBox(height: 8),
        DropdownButtonFormField<Secteur>(
          initialValue: _secteur,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.description_outlined),
          ),
          items: Secteur.values
              .map((s) => DropdownMenuItem(value: s, child: Text(s.nom)))
              .toList(),
          onChanged: (s) => s == null ? null : setState(() => _secteur = s),
        ),
        if (_secteur.note != null) ...[
          const SizedBox(height: 8),
          InfoBanner(
              text: _secteur.note!,
              icon: Icons.schedule,
              color: AppColors.infos),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _q = v),
          decoration: InputDecoration(
            hintText: tr('Chercher un métier…', 'Search a trade…'),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _q.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _searchCtrl.clear();
                      _q = '';
                    }),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        if (metiers.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text('${tr('Aucun métier pour', 'No trade for')} « $_q »',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6))),
            ),
          )
        else
          ...metiers.map((m) => _MetierTile(metier: m, secteur: _secteur)),
      ],
    );
  }
}

class _MetierTile extends StatefulWidget {
  const _MetierTile({required this.metier, required this.secteur});
  final Metier metier;
  final Secteur secteur;

  @override
  State<_MetierTile> createState() => _MetierTileState();
}

class _MetierTileState extends State<_MetierTile> {
  /// Palier choisi pour voir ses hausses (null = compagnon, le dernier).
  int? _selPalier;

  @override
  Widget build(BuildContext context) {
    final Metier metier = widget.metier;
    final Secteur secteur = widget.secteur;
    final double comp = CcqData.tauxCompagnon(metier, secteur);
    final List<Hausse> futures = CcqData.haussesFutures(secteur);
    final Color onSurf = Theme.of(context).colorScheme.onSurface;
    final paliers = metier.paliers();
    final int selIdx = _selPalier ?? paliers.length - 1;
    final sel = paliers[selIdx];
    final String libelleComp = paliers.last.nom;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.infos.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metier.icon, color: AppColors.infos, size: 22),
          ),
          title: Text(metier.nomAffiche,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          subtitle: Text('$libelleComp : ${Fmt.money(comp)}/h',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.infos)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  tr('Touche un palier pour voir ses prochaines hausses.',
                      'Tap a step to see its upcoming increases.'),
                  style: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: onSurf.withValues(alpha: 0.55))),
            ),
            const SizedBox(height: 4),
            ...paliers.asMap().entries.map((e) {
              final int i = e.key;
              final p = e.value;
              final bool actif = i == selIdx;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _selPalier = i),
                child: Container(
                  decoration: BoxDecoration(
                    color: actif
                        ? AppColors.infos.withValues(alpha: 0.10)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  child: Row(
                    children: [
                      Icon(
                          actif
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: actif
                              ? AppColors.infos
                              : onSurf.withValues(alpha: 0.3)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${p.nom}  (${p.pourcentage} %)',
                            style: TextStyle(
                                color: onSurf
                                    .withValues(alpha: actif ? 0.95 : 0.75),
                                fontWeight:
                                    actif ? FontWeight.w700 : FontWeight.w400)),
                      ),
                      Text('${Fmt.money(comp * p.pourcentage / 100)}/h',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            }),
            if (futures.isNotEmpty) ...[
              const SizedBox(height: 8),
              Divider(color: AppColors.success.withValues(alpha: 0.25)),
              Row(
                children: [
                  const Icon(Icons.trending_up,
                      size: 17, color: AppColors.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                        '${tr('Prochaines hausses', 'Upcoming increases')} — ${sel.nom}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: AppColors.success)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...futures.map((h) {
                final double r = CcqData.tauxCompagnon(metier, secteur,
                        on: h.date) *
                    sel.pourcentage /
                    100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${Fmt.dateFr(h.date)}  (+${Fmt.trim(h.pct)} %)',
                          style: TextStyle(color: onSurf.withValues(alpha: 0.75))),
                      Text('${Fmt.money(r)}/h',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.success)),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  JOURS FÉRIÉS & VACANCES
// ─────────────────────────────────────────────────────────────────────────
class FeriesScreen extends StatelessWidget {
  const FeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: tr('Jours fériés & vacances', 'Holidays & vacations'),
      children: [
        SectionTitle(tr('Jours fériés chômés et payés', 'Paid statutory holidays'),
            color: AppColors.infos),
        ...CcqData.feries.map((f) => _FerieTile(ferie: f)),
        const SizedBox(height: 16),
        SectionTitle(tr('Vacances de la construction', 'Construction holidays'),
            color: AppColors.infos),
        ...CcqData.vacancesConstruction.map((f) => _FerieTile(ferie: f)),
        const SizedBox(height: 16),
        InfoBanner(
          text: tr(
              'Le traitement exact des jours fériés et les dates des vacances '
                  'de la construction sont fixés par convention et publiés chaque '
                  'année. Confirme les dates officielles sur ccq.org.',
              'The exact treatment of holidays and the construction vacation '
                  'dates are set by agreement and published each year. Confirm '
                  'the official dates on ccq.org.'),
        ),
      ],
    );
  }
}

class _FerieTile extends StatelessWidget {
  const _FerieTile({required this.ferie});
  final JourFerie ferie;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.event, color: AppColors.infos),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ferie.nom,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(ferie.detail,
                      style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  SANTÉ-SÉCURITÉ
// ─────────────────────────────────────────────────────────────────────────
class SecuriteScreen extends StatelessWidget {
  const SecuriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: tr('Santé-sécurité', 'Health & safety'),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.emergency, color: AppColors.danger, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('Urgence : 911', 'Emergency: 911'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.danger)),
                    Text(
                        tr('Accident grave ou danger immédiat — appelle tout de suite.',
                            'Serious accident or immediate danger — call right away.'),
                        style: TextStyle(
                            fontSize: 12.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.75))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionTitle(tr('Aide-mémoire sur le chantier', 'On-site checklist'),
            color: AppColors.infos),
        ...CcqData.securite.map((c) => _SecuriteCard(conseil: c)),
        const SizedBox(height: 8),
        InfoBanner(
          text: tr(
              'Rappels généraux — ce n\'est pas un avis juridique. Réfère-toi '
                  'à la CNESST, au Code de sécurité pour les travaux de '
                  'construction et à ton représentant en santé-sécurité.',
              'General reminders — this is not legal advice. Refer to the '
                  'CNESST, the Safety Code for the construction industry and '
                  'your health & safety representative.'),
        ),
      ],
    );
  }
}

class _SecuriteCard extends StatelessWidget {
  const _SecuriteCard({required this.conseil});
  final ConseilSecurite conseil;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(conseil.icon, color: AppColors.warning, size: 22),
          ),
          title: Text(conseil.titre,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(conseil.details,
                  style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8))),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  NUMÉROS & RESSOURCES
// ─────────────────────────────────────────────────────────────────────────
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: tr('Numéros utiles', 'Useful numbers'),
      children: [
        ...CcqData.ressources.map((r) => _RessourceCard(ressource: r)),
        const SizedBox(height: 8),
        InfoBanner(
          text: tr(
              'Numéros marqués « à confirmer » : valide-les sur les sites '
                  'officiels (ccq.org, cnesst.gouv.qc.ca) avant de t\'y fier.',
              'Numbers marked « to confirm »: verify them on the official '
                  'sites (ccq.org, cnesst.gouv.qc.ca) before relying on them.'),
        ),
      ],
    );
  }
}

class _RessourceCard extends StatelessWidget {
  const _RessourceCard({required this.ressource});
  final Ressource ressource;

  @override
  Widget build(BuildContext context) {
    final Color c = ressource.urgence ? AppColors.danger : AppColors.infos;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                  ressource.web
                      ? Icons.language
                      : (ressource.urgence ? Icons.emergency : Icons.phone),
                  color: c),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(ressource.nom,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                      if (!ressource.confirme) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(tr('à confirmer', 'to confirm'),
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(ressource.numero,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: c)),
                  const SizedBox(height: 2),
                  Text(ressource.description,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6))),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              tooltip: tr('Copier', 'Copy'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: ressource.numero));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          '${tr('Copié', 'Copied')} : ${ressource.numero}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
