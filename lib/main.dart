import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'onboarding_page.dart';
import 'sign_in.dart';
import 'dashboardPage.dart';


// ============================================================================
// MAIN
// ============================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // INITIALISER FIREBASE
  // ==========================================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ==========================================================================
  // RÉCUPÉRER L'ÉTAT DE L'ONBOARDING
  // ==========================================================================
  //
  // Cette information est indépendante de Firebase Authentication.
  //
  // Elle reste même après :
  //
  // - logout
  // - fermeture de l'application
  // - redémarrage du téléphone
  //
  // Elle sera supprimée uniquement lorsque l'application est désinstallée.
  //
  // ==========================================================================

  final SharedPreferences prefs =
  await SharedPreferences.getInstance();

  final bool onboardingCompleted =
      prefs.getBool(
        'onboarding_completed',
      ) ??
          false;

  // ==========================================================================
  // LANCER L'APPLICATION
  // ==========================================================================

  runApp(
    MoneoApp(
      onboardingCompleted: onboardingCompleted,
    ),
  );
}


// ============================================================================
// MONEO APP
// ============================================================================

class MoneoApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MoneoApp({
    super.key,
    required this.onboardingCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Moneo',

      // =========================================================================
      // THEME
      // =========================================================================

      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),

      // =========================================================================
      // PAGE DE DÉPART
      // =========================================================================
      //
      // IMPORTANT :
      //
      // onboardingCompleted == false
      //       → OnboardingPage
      //
      // onboardingCompleted == true
      //       → AuthGate
      //
      // ========================================================================

      home: onboardingCompleted
          ? const AuthGate()
          : const OnboardingPage(),
    );
  }
}


// ============================================================================
// AUTH GATE
// ============================================================================
//
// Cette classe contrôle automatiquement la destination de l'utilisateur
// selon son état Firebase Authentication.
//
// CAS 1 : aucun utilisateur
//     → LoginScreen
//
// CAS 2 : utilisateur Google
//     → DashboardPage
//
// CAS 3 : utilisateur email/password vérifié
//     → DashboardPage
//
// CAS 4 : utilisateur email/password NON vérifié
//     → EmailVerificationScreen
//
// ============================================================================

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // =========================================================================
      // USER CHANGES
      // =========================================================================
      //
      // userChanges() est utilisé au lieu de authStateChanges().
      //
      // Cela permet également de prendre en compte les changements du compte
      // Firebase, notamment après un reload() de l'utilisateur.
      //
      // =========================================================================

      stream: FirebaseAuth.instance.userChanges(),

      builder: (
          BuildContext context,
          AsyncSnapshot<User?> snapshot,
          ) {
        // =======================================================================
        // FIREBASE EST EN TRAIN DE RESTAURER LA SESSION
        // =======================================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF020208),

            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00D5FF),
              ),
            ),
          );
        }

        // =======================================================================
        // ERREUR
        // =======================================================================

        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: Color(0xFF020208),

            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),

                child: Text(
                  'Unable to restore your session.',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }

        // =======================================================================
        // RÉCUPÉRER L'UTILISATEUR
        // =======================================================================

        final User? user = snapshot.data;

        // =======================================================================
        // AUCUN UTILISATEUR CONNECTÉ
        // =======================================================================
        //
        // Exemple :
        //
        // utilisateur fait Logout
        //        ↓
        // FirebaseAuth.instance.signOut()
        //        ↓
        // user == null
        //        ↓
        // LoginScreen
        //
        // IMPORTANT :
        //
        // On ne retourne PAS OnboardingPage ici.
        //
        // =======================================================================

        if (user == null) {
          return const LoginScreen();
        }

        // =======================================================================
        // UTILISATEUR EMAIL/PASSWORD NON VÉRIFIÉ
        // =======================================================================
        //
        // Google n'est normalement pas concerné par cette condition.
        //
        // Pour email/password :
        //
        // user.emailVerified == false
        //        ↓
        // EmailVerificationScreen
        //
        // ET surtout :
        //
        // aucune création de document Firestore ne doit être faite ici.
        //
        // La création/synchronisation Firestore sera faite APRÈS vérification.
        //
        // =======================================================================

        if (user.providerData.any(
              (provider) =>
          provider.providerId == 'password',
        )) {
          if (!user.emailVerified) {
            return EmailVerificationScreen(
              email: user.email ?? '',
            );
          }
        }

        // =======================================================================
        // UTILISATEUR CONNECTÉ ET AUTORISÉ
        // =======================================================================
        //
        // Cas :
        //
        // - Google
        // - Email/password vérifié
        //
        // → Dashboard
        //
        // =======================================================================

        return const DashboardPage();
      },
    );
  }
}