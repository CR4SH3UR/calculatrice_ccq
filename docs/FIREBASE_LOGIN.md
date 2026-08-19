# Connexion (login) + sauvegarde cloud — mise en route

L'app peut sauvegarder la **feuille de temps**, le **profil** et les
**représentants perso** dans le cloud, pour les retrouver sur n'importe quel
appareil. C'est bâti sur **Firebase Authentication** (connexion e-mail/mot de
passe + Google) et **Cloud Firestore** (stockage).

> **Tant que Firebase n'est pas configuré, l'app fonctionne exactement comme
> avant** : tout reste local sur l'appareil et le bouton « Compte » est masqué.
> Le code est déjà en place ; il ne s'active qu'une fois les étapes ci-dessous
> faites.

## 1. Générer la configuration Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=calculatriceccq
```

Cette commande :
- crée/relie les apps Web, Android et iOS dans ton projet Firebase ;
- **écrase** `lib/firebase_options.dart` avec les vraies clés (à ce moment,
  `estConfigure` devient vrai et le bouton « Compte » apparaît) ;
- ajoute `android/app/google-services.json` et
  `ios/Runner/GoogleService-Info.plist`.

Puis récupère les paquets :

```bash
flutter pub get
```

> Les versions de `firebase_core`/`firebase_auth`/`cloud_firestore` dans
> `pubspec.yaml` peuvent être ajustées automatiquement par `flutterfire` selon
> ta version de Flutter. Si `flutter pub get` se plaint d'une version, lance
> `flutter pub upgrade firebase_core firebase_auth cloud_firestore`.

## 2. Activer les méthodes de connexion

Console Firebase → **Authentication** → **Sign-in method** → active :
- **E-mail/Mot de passe**
- **Google**

## 3. Créer la base Firestore + déployer les règles

1. Console Firebase → **Firestore Database** → **Créer une base** (mode
   production).
2. Déploie les règles de sécurité fournies (`firestore.rules`, accès limité à
   `utilisateurs/{sonUid}`). Ajoute à `firebase.json` :

   ```json
   "firestore": { "rules": "firestore.rules" }
   ```

   puis :

   ```bash
   firebase deploy --only firestore:rules
   ```

## 4. (Web) Domaines autorisés

Console Firebase → **Authentication** → **Settings** → **Authorized domains** :
ajoute `calculatriceccq.web.app` (et `localhost` pour tes tests). Nécessaire
pour la connexion Google par popup sur le web.

## 5. Valider AVANT de mettre en ligne

Le déploiement web se fait automatiquement à chaque push sur `main`. Pour
éviter de pousser une version non testée sur le site public, valide d'abord :

```bash
flutter analyze
flutter test
flutter run                       # teste connexion + synchro en vrai
# ou un canal de prévisualisation Firebase (n'affecte pas la prod) :
flutter build web --release
firebase hosting:channel:deploy preview
```

Quand tout est bon, fusionne sur `main` : le site se met à jour et la
connexion est disponible.

## Ce qui est synchronisé

Un document par utilisateur : `utilisateurs/{uid}` avec `profil`, `heures`
(feuille de temps) et `representants`. La synchro est automatique (à la
connexion, puis à chaque changement) ; un bouton « Synchroniser maintenant »
force l'envoi.

## Confidentialité

Les données ne quittent l'appareil **que** si l'utilisateur se connecte. Les
règles Firestore garantissent que chacun n'accède qu'à ses propres données.
Ne committe jamais de clé privée de **compte de service** (voir `.gitignore`) —
`firebase_options.dart` et `google-services.json`, eux, ne contiennent que la
config client (publique) et peuvent être committés.
