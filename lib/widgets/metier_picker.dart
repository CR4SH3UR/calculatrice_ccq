import 'package:flutter/material.dart';

import '../data/ccq_data.dart';

/// Normalise pour la recherche : minuscules, sans accents.
/// « Électricien » → « electricien », pour trouver même sans accent.
String foldRecherche(String s) {
  const accents = 'àâäáãçéèêëíïîìóôöòõúùûüñ';
  const sans = 'aaaaaceeeeiiiiooooouuuun';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = accents.indexOf(ch);
    b.write(i >= 0 ? sans[i] : ch);
  }
  return b.toString();
}

/// Ouvre un sélecteur de métier cherchable (feuille modale).
Future<Metier?> showMetierPicker(BuildContext context, {Metier? selected}) {
  return showModalBottomSheet<Metier>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.72,
        child: _MetierPickerSheet(selected: selected),
      ),
    ),
  );
}

class _MetierPickerSheet extends StatefulWidget {
  const _MetierPickerSheet({this.selected});
  final Metier? selected;

  @override
  State<_MetierPickerSheet> createState() => _MetierPickerSheetState();
}

class _MetierPickerSheetState extends State<_MetierPickerSheet> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String q = foldRecherche(_q.trim());
    final List<Metier> list = q.isEmpty
        ? CcqData.metiers
        : CcqData.metiers
            .where((m) => foldRecherche(m.nom).contains(q))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(
              hintText: 'Chercher un métier…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _q.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _ctrl.clear();
                        _q = '';
                      }),
                    ),
            ),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text('Aucun métier pour « $_q »',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6))),
                )
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final Metier m = list[i];
                    final bool sel = identical(m, widget.selected) ||
                        m.nom == widget.selected?.nom;
                    return ListTile(
                      leading: Icon(m.icon,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(m.nom),
                      trailing: sel
                          ? Icon(Icons.check,
                              color: Theme.of(context).colorScheme.primary)
                          : null,
                      selected: sel,
                      onTap: () => Navigator.of(context).pop(m),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Champ tactile affichant le métier choisi ; ouvre le sélecteur au clic.
class MetierField extends StatelessWidget {
  const MetierField({
    super.key,
    required this.metier,
    required this.onChanged,
    this.color,
  });

  final Metier metier;
  final ValueChanged<Metier> onChanged;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? Theme.of(context).colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final Metier? m = await showMetierPicker(context, selected: metier);
        if (m != null) onChanged(m);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Métier',
          prefixIcon: Icon(metier.icon, color: c),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(metier.nom,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Icon(Icons.search,
                size: 20,
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
