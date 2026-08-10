import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/ccq_data.dart';
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
            .where((m) => foldRecherche(m.nom).contains(q))
            .toList();

    return ToolScaffold(
      title: 'Taux par métier',
      children: [
        InfoBanner(
          text:
              'Taux de salaire par grille — ${CcqData.enVigueurTexte}. '
              'Touche un métier pour voir les paliers et les prochains taux. '
              '${CcqData.source}',
          color: AppColors.warning,
        ),
        const SizedBox(height: 16),
        Text('Convention (secteur)',
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
            hintText: 'Chercher un métier…',
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
              child: Text('Aucun métier pour « $_q »',
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

class _MetierTile extends StatelessWidget {
  const _MetierTile({required this.metier, required this.secteur});
  final Metier metier;
  final Secteur secteur;

  @override
  Widget build(BuildContext context) {
    final double comp = CcqData.tauxCompagnon(metier, secteur);
    final List<Hausse> futures = CcqData.haussesFutures(secteur);
    final Color onSurf = Theme.of(context).colorScheme.onSurface;
    final String libelleComp = metier.paliers().last.nom;

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
          title: Text(metier.nom,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          subtitle: Text('$libelleComp : ${Fmt.money(comp)}/h',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.infos)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: [
            ...metier.paliers().map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${p.nom}  (${p.pourcentage} %)',
                          style: TextStyle(color: onSurf.withValues(alpha: 0.75))),
                      Text('${Fmt.money(comp * p.pourcentage / 100)}/h',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                )),
            if (futures.isNotEmpty) ...[
              const SizedBox(height: 8),
              Divider(color: AppColors.success.withValues(alpha: 0.25)),
              Row(
                children: [
                  const Icon(Icons.trending_up,
                      size: 17, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text('Prochains taux ($libelleComp)',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 4),
              ...futures.map((h) {
                final double r = CcqData.tauxCompagnon(metier, secteur, on: h.date);
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
      title: 'Jours fériés & vacances',
      children: [
        const SectionTitle('Jours fériés chômés et payés',
            color: AppColors.infos),
        ...CcqData.feries.map((f) => _FerieTile(ferie: f)),
        const SizedBox(height: 16),
        const SectionTitle('Vacances de la construction',
            color: AppColors.infos),
        ...CcqData.vacancesConstruction.map((f) => _FerieTile(ferie: f)),
        const SizedBox(height: 16),
        const InfoBanner(
          text:
              'Le traitement exact des jours fériés et les dates des vacances '
              'de la construction sont fixés par convention et publiés chaque '
              'année. Confirme les dates officielles sur ccq.org.',
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
      title: 'Santé-sécurité',
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
                    const Text('Urgence : 911',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.danger)),
                    Text('Accident grave ou danger immédiat — appelle tout de suite.',
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
        const SectionTitle('Aide-mémoire sur le chantier',
            color: AppColors.infos),
        ...CcqData.securite.map((c) => _SecuriteCard(conseil: c)),
        const SizedBox(height: 8),
        const InfoBanner(
          text:
              'Rappels généraux — ce n\'est pas un avis juridique. Réfère-toi '
              'à la CNESST, au Code de sécurité pour les travaux de '
              'construction et à ton représentant en santé-sécurité.',
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
      title: 'Numéros utiles',
      children: [
        ...CcqData.ressources.map((r) => _RessourceCard(ressource: r)),
        const SizedBox(height: 8),
        const InfoBanner(
          text:
              'Numéros marqués « à confirmer » : valide-les sur les sites '
              'officiels (ccq.org, cnesst.gouv.qc.ca) avant de t\'y fier.',
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
                          child: const Text('à confirmer',
                              style: TextStyle(
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
              tooltip: 'Copier',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: ressource.numero));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copié : ${ressource.numero}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
