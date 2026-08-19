import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

/// Écran « Compte » : connexion / création de compte, puis état de la
/// sauvegarde cloud une fois connecté.
class CompteScreen extends StatelessWidget {
  const CompteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: tr('Compte', 'Account'),
      children: [
        StreamBuilder<User?>(
          stream: AuthService.instance.changements,
          initialData: AuthService.instance.utilisateur,
          builder: (context, snap) {
            return snap.data == null
                ? const _ConnexionForm()
                : _CompteConnecte(utilisateur: snap.data!);
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  Formulaire de connexion / inscription
// ─────────────────────────────────────────────────────────────────────────
class _ConnexionForm extends StatefulWidget {
  const _ConnexionForm();

  @override
  State<_ConnexionForm> createState() => _ConnexionFormState();
}

class _ConnexionFormState extends State<_ConnexionForm> {
  final _courriel = TextEditingController();
  final _mdp = TextEditingController();
  bool _inscription = false;
  bool _cacherMdp = true;
  bool _occupe = false;
  String? _erreur;

  @override
  void dispose() {
    _courriel.dispose();
    _mdp.dispose();
    super.dispose();
  }

  Future<void> _executer(Future<void> Function() action) async {
    setState(() {
      _occupe = true;
      _erreur = null;
    });
    try {
      await action();
      // Succès : le StreamBuilder parent reconstruit vers l'état connecté.
    } catch (e) {
      if (mounted) setState(() => _erreur = AuthService.messageErreur(e));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  void _soumettre() {
    final c = _courriel.text.trim();
    final m = _mdp.text;
    if (c.isEmpty || m.isEmpty) {
      setState(() => _erreur =
          tr('Entre ton courriel et ton mot de passe.',
              'Enter your email and password.'));
      return;
    }
    _executer(() => _inscription
        ? AuthService.instance.inscrire(c, m)
        : AuthService.instance.connecter(c, m));
  }

  Future<void> _motDePasseOublie() async {
    final c = _courriel.text.trim();
    if (c.isEmpty) {
      setState(() => _erreur = tr(
          'Entre d\'abord ton courriel pour recevoir le lien.',
          'Enter your email first to receive the link.'));
      return;
    }
    await _executer(() => AuthService.instance.reinitialiserMotDePasse(c));
    if (mounted && _erreur == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr(
              'Courriel de réinitialisation envoyé.',
              'Password reset email sent.'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoBanner(
          icon: Icons.cloud_sync,
          color: AppColors.infos,
          text: tr(
              'Connecte-toi pour sauvegarder ta feuille de temps, ton profil '
                  'et tes représentants, et les retrouver sur tes autres '
                  'appareils. Tes données restent privées à ton compte.',
              'Sign in to back up your timesheet, profile and reps, and find '
                  'them on your other devices. Your data stays private to your '
                  'account.'),
        ),
        const SizedBox(height: 18),
        SectionTitle(
            _inscription
                ? tr('Créer un compte', 'Create an account')
                : tr('Se connecter', 'Sign in'),
            color: AppColors.infos),
        const SizedBox(height: 12),
        TextField(
          controller: _courriel,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enabled: !_occupe,
          decoration: InputDecoration(
            labelText: tr('Courriel', 'Email'),
            prefixIcon: const Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _mdp,
          obscureText: _cacherMdp,
          enabled: !_occupe,
          onSubmitted: (_) => _occupe ? null : _soumettre(),
          decoration: InputDecoration(
            labelText: tr('Mot de passe', 'Password'),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                  _cacherMdp ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _cacherMdp = !_cacherMdp),
            ),
          ),
        ),
        if (_erreur != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.danger, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_erreur!,
                    style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _occupe ? null : _soumettre,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _occupe
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_inscription
                    ? tr('Créer mon compte', 'Create my account')
                    : tr('Se connecter', 'Sign in')),
          ),
        ),
        if (!_inscription) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _occupe ? null : _motDePasseOublie,
              child: Text(
                  tr('Mot de passe oublié ?', 'Forgot password?')),
            ),
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(tr('ou', 'or'),
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5))),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: _occupe
              ? null
              : () => _executer(AuthService.instance.connecterGoogle),
          icon: const Icon(Icons.g_mobiledata, size: 28),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(tr('Continuer avec Google', 'Continue with Google')),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _occupe
                ? null
                : () => setState(() {
                      _inscription = !_inscription;
                      _erreur = null;
                    }),
            child: Text(_inscription
                ? tr('J\'ai déjà un compte — me connecter',
                    'I already have an account — sign in')
                : tr('Pas de compte ? En créer un',
                    'No account? Create one')),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  État connecté : infos du compte + sauvegarde cloud
// ─────────────────────────────────────────────────────────────────────────
class _CompteConnecte extends StatelessWidget {
  const _CompteConnecte({required this.utilisateur});
  final User utilisateur;

  @override
  Widget build(BuildContext context) {
    final String courriel =
        utilisateur.email ?? tr('Compte Google', 'Google account');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.check_circle,
                      color: AppColors.success, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('Connecté', 'Signed in'),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success)),
                      const SizedBox(height: 2),
                      Text(courriel,
                          style: const TextStyle(
                              fontSize: 15.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionTitle(tr('Sauvegarde cloud', 'Cloud backup'),
            color: AppColors.infos),
        const SizedBox(height: 8),
        InfoBanner(
          icon: Icons.sync,
          color: AppColors.infos,
          text: tr(
              'Ta feuille de temps, ton profil et tes représentants sont '
                  'sauvegardés automatiquement et synchronisés sur tes '
                  'appareils connectés au même compte.',
              'Your timesheet, profile and reps are backed up automatically '
                  'and synced across your devices signed in to the same '
                  'account.'),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<DateTime?>(
          valueListenable: CloudSync.instance.derniereSync,
          builder: (context, date, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: CloudSync.instance.enCours,
              builder: (context, occupe, __) {
                final String etat = occupe
                    ? tr('Synchronisation…', 'Syncing…')
                    : date == null
                        ? tr('Pas encore synchronisé', 'Not synced yet')
                        : '${tr('Dernière synchro', 'Last sync')} : '
                            '${Fmt.dateFr(date)} '
                            '${date.hour.toString().padLeft(2, '0')}:'
                            '${date.minute.toString().padLeft(2, '0')}';
                return Row(
                  children: [
                    Icon(occupe ? Icons.cloud_sync : Icons.cloud_done,
                        size: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(etat,
                          style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7))),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () => CloudSync.instance.synchroniserMaintenant(),
          icon: const Icon(Icons.sync),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(tr('Synchroniser maintenant', 'Sync now')),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => AuthService.instance.deconnecter(),
          icon: const Icon(Icons.logout),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(tr('Se déconnecter', 'Sign out')),
          ),
        ),
        const SizedBox(height: 12),
        Text(
            tr(
                'La déconnexion garde tes données sur cet appareil ; elles '
                    'restent aussi sauvegardées dans ton compte.',
                'Signing out keeps your data on this device; it also stays '
                    'backed up in your account.'),
            style: TextStyle(
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55))),
      ],
    );
  }
}
