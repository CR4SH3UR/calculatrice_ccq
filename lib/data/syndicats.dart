/// Une association syndicale représentative de la construction (loi R-20).
///
/// Les noms sont des noms propres d'organismes québécois : ils restent en
/// français dans les deux langues. Le [telephone] est celui du siège social,
/// vérifié sur le site officiel (peut être `null` si non confirmé).
class Syndicat {
  const Syndicat({
    required this.sigle,
    required this.nom,
    required this.representativite,
    required this.site,
    required this.representants,
    this.telephone,
  });

  final String sigle;
  final String nom;
  final double representativite; // % au scrutin 2024
  final String site;
  final String representants; // page « représentants / nous joindre »
  final String? telephone; // siège social (numéro officiel vérifié)
}

/// Les 5 associations syndicales, triées par représentativité (scrutin 2024).
/// Sources : ccq.org et sites officiels des syndicats.
const List<Syndicat> syndicats = [
  Syndicat(
    sigle: 'FTQ-Construction',
    nom: 'Fédération des travailleurs et travailleuses du Québec',
    representativite: 44.069,
    site: 'https://ftqconstruction.org',
    representants: 'https://ftqconstruction.org/nous-joindre/',
    telephone: '1 877 666-4060',
  ),
  Syndicat(
    sigle: 'SQC',
    nom: 'Syndicat québécois de la construction',
    representativite: 21.703,
    site: 'https://www.sqc.ca',
    representants: 'https://www.sqc.ca/nous-joindre/',
    telephone: '1 888 773-8834',
  ),
  Syndicat(
    sigle: 'International (CPQMC)',
    nom: 'Conseil provincial du Québec des métiers de la construction',
    representativite: 20.698,
    site: 'https://cpqmci.org',
    representants: 'https://cpqmci.org/sections-locales/',
    telephone: '1 888 927-7624',
  ),
  Syndicat(
    sigle: 'CSD Construction',
    nom: 'Centrale des syndicats démocratiques',
    representativite: 7.552,
    site: 'https://www.csd.qc.ca',
    representants: 'https://www.csd.qc.ca/nous-contacter/',
    telephone: '418 529-2956',
  ),
  Syndicat(
    sigle: 'CSN-Construction',
    nom: 'Confédération des syndicats nationaux',
    representativite: 5.978,
    site: 'https://www.csnconstruction.qc.ca',
    representants: 'https://www.csnconstruction.qc.ca/a-propos/structure/',
    telephone: '1 800 363-6331',
  ),
];
