import 'package:flutter/material.dart';

import '../data/outils_registry.dart';
import '../l10n/lang.dart';
import '../widgets/metier_picker.dart' show foldRecherche;

/// Recherche globale dans tous les outils de l'app.
class RechercheScreen extends StatefulWidget {
  const RechercheScreen({super.key});

  @override
  State<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends State<RechercheScreen> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = foldRecherche(_q.trim());
    final resultats = q.isEmpty
        ? tousLesOutils
        : tousLesOutils
            .where((o) => foldRecherche(
                    '${o.titre} ${o.sousTitre} ${outilTitre(o)} ${outilSousTitre(o)}')
                .contains(q))
            .toList();
    final onSurf = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: (v) => setState(() => _q = v),
          decoration: InputDecoration(
            hintText: tr('Chercher un outil…', 'Search a tool…'),
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          if (_q.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _ctrl.clear();
                _q = '';
              }),
            ),
        ],
      ),
      body: resultats.isEmpty
          ? Center(
              child: Text('${tr('Aucun outil pour', 'No tool for')} « $_q »',
                  style: TextStyle(color: onSurf.withValues(alpha: 0.6))),
            )
          : ListView.builder(
              itemCount: resultats.length,
              itemBuilder: (context, i) {
                final o = resultats[i];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(o.icon, color: primary, size: 22),
                  ),
                  title: Text(outilTitre(o),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(outilSousTitre(o)),
                  onTap: () => Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: o.builder)),
                );
              },
            ),
    );
  }
}
