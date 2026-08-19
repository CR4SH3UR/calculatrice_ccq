# Calculatrice CCQ

Boîte à outils de chantier pour les travailleurs de la construction au Québec.
Application Flutter (Material 3), en français, pensée pour les gars sur les
chantiers : la paie, les calculs de tous les jours, et l'info importante à
portée de main.

> **Outil non officiel.** Les taux et les données sont donnés à titre indicatif
> et doivent être validés auprès des sources officielles (CCQ, CNESST). Aucun
> chiffre réglementaire n'est inventé : tout provient de sources citées dans
> l'app.

## Fonctionnalités

**Paie & salaire**
- Taux de salaire par métier selon les **5 grilles** (résidentiel léger/lourd,
  institutionnel-commercial, industriel, génie civil et voirie) et les prochains
  taux à venir
- Calculateur de paie (brut, congés, net), comparateur de taux, salaire annuel
- **Feuille de temps** : note tes heures, rapport filtré, export CSV, sauvegarde
- Vacances & congés, paie nette, déplacement, rappel rétroactif
- **Calculateur de retraite** : projection du compte complémentaire

**Calculs de chantier / matériaux / charpente**
- Convertisseur impérial ↔ métrique, fractions de pouce, surfaces et aires
- Béton (simple et avancé), pente de toit, escalier, équerre 3-4-5, solives…
- Peinture, briques, isolation (R), bardeaux, gravier, céramique, coffrage…
- Calculs électriques (loi d'Ohm, chute de tension), couple de serrage

**Infos pour les gars (données vérifiées)**
- **MÉDIC Construction** : tableau comparatif des protections (régimes A-D et
  AO-DO), classé comme le bulletin officiel
- **SIMDUT 2015** (pictogrammes), **lignes électriques** (distances d'approche
  CSTC 5.2.1), santé-sécurité
- Syndicats, jours fériés, numéros utiles, documentation (conventions)

## Sources des données

- Taux horaires : API officielle des taux de la CCQ
- MÉDIC : bulletins d'information (PD5212 métiers, PD5225 occupations)
- Santé-sécurité : CCHST (SIMDUT), Code de sécurité pour les travaux de
  construction (CNESST)
- Retraite : régime de retraite de l'industrie de la construction (CCQ)

## Démarrer

```bash
flutter pub get
flutter run
```

Tests et analyse statique :

```bash
flutter test
flutter analyze
```

## Pile technique

Flutter · Material 3 · `shared_preferences` (persistance locale) · `http` (API
CCQ) · `pdf`/`printing` (export PDF) · `share_plus`/`path_provider` (export CSV
et sauvegarde).

## Déployer l'app web sur Firebase Hosting

L'application Flutter peut être compilée en web et hébergée sur Firebase
Hosting. La configuration est déjà en place (`firebase.json` → `build/web`,
`.firebaserc`).

**1. Créer le projet** sur [console.firebase.google.com](https://console.firebase.google.com),
puis remplacer `calculatrice-ccq` par l'ID réel du projet dans `.firebaserc`
(et dans `.github/workflows/firebase-hosting.yml`).

**2. Déploiement automatique** (recommandé — GitHub Actions build + déploie à
chaque push sur `main`) : ajouter un secret `FIREBASE_SERVICE_ACCOUNT` au dépôt
(Console Firebase → Paramètres du projet → Comptes de service → « Générer une
nouvelle clé privée », puis GitHub → Settings → Secrets and variables →
Actions). Le workflow `.github/workflows/firebase-hosting.yml` compile l'app
(`flutter build web`) et la publie.

**3. Déploiement manuel** (depuis ta machine, Flutter installé) :

```bash
flutter build web --release
npm install -g firebase-tools     # une seule fois
firebase login                    # ouvre le navigateur pour s'authentifier
firebase deploy --only hosting
```

> Astuce : `firebase hosting:channel:deploy preview` crée une URL de
> prévisualisation temporaire sans toucher au site en production.
