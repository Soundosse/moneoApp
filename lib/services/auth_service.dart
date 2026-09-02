import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // GOOGLE SIGN-IN
  // ============================================================

  final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance;

  bool _googleInitialized = false;

  // ============================================================
  // INITIALISER GOOGLE SIGN-IN
  // ============================================================

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) {
      return;
    }

    await _googleSignIn.initialize();

    _googleInitialized = true;

    debugPrint(
      '✅ Google Sign-In initialisé',
    );
  }

  // ============================================================
  // CONNEXION GOOGLE
  // ============================================================

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // --------------------------------------------------------
      // 1. INITIALISER GOOGLE
      // --------------------------------------------------------

      await _initializeGoogleSignIn();

      debugPrint(
        '🔵 Ouverture de Google Sign-In...',
      );

      // --------------------------------------------------------
      // 2. AUTHENTIFICATION GOOGLE
      // --------------------------------------------------------

      final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate();

      debugPrint(
        '✅ Compte Google sélectionné : '
            '${googleUser.email}',
      );

      // --------------------------------------------------------
      // 3. RÉCUPÉRER L'AUTHENTIFICATION GOOGLE
      // --------------------------------------------------------

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      debugPrint(
        'ID Token disponible : '
            '${googleAuth.idToken != null}',
      );

      // --------------------------------------------------------
      // 4. VÉRIFIER LE TOKEN
      // --------------------------------------------------------

      if (googleAuth.idToken == null) {
        debugPrint(
          '❌ ID Token Google est null',
        );

        return null;
      }

      // --------------------------------------------------------
      // 5. CRÉER LE CREDENTIAL FIREBASE
      // --------------------------------------------------------

      final OAuthCredential credential =
      GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      debugPrint(
        '✅ Credential Firebase créé',
      );

      // --------------------------------------------------------
      // 6. CONNEXION À FIREBASE AUTHENTICATION
      // --------------------------------------------------------

      final UserCredential userCredential =
      await _auth.signInWithCredential(
        credential,
      );

      final User? user =
          userCredential.user;

      // --------------------------------------------------------
      // 7. VÉRIFIER L'UTILISATEUR
      // --------------------------------------------------------

      if (user == null) {
        debugPrint(
          '❌ Utilisateur Firebase null',
        );

        return null;
      }

      debugPrint(
        '✅ Firebase Authentication réussie',
      );

      debugPrint(
        'UID Firebase : ${user.uid}',
      );

      debugPrint(
        'Email Firebase : ${user.email}',
      );

      // --------------------------------------------------------
      // 8. RÉFÉRENCE FIRESTORE
      // --------------------------------------------------------

      final DocumentReference userRef =
      _firestore
          .collection('users')
          .doc(user.uid);

      debugPrint(
        '📁 Lecture Firestore : users/${user.uid}',
      );

      // --------------------------------------------------------
      // 9. VÉRIFIER SI LE PROFIL EXISTE
      // --------------------------------------------------------

      final DocumentSnapshot userDoc =
      await userRef.get();

      debugPrint(
        '✅ Lecture Firestore réussie',
      );

      // --------------------------------------------------------
      // 10. CRÉER LE PROFIL SI NÉCESSAIRE
      // --------------------------------------------------------

      if (!userDoc.exists) {
        debugPrint(
          '🆕 Profil Firestore inexistant',
        );

        await userRef.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'currency': 'MAD',
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': user.photoURL ?? '',
        });

        debugPrint(
          '✅ Profil Firestore créé',
        );
      } else {
        debugPrint(
          '✅ Profil Firestore déjà existant',
        );
      }

      // --------------------------------------------------------
      // 11. RETOURNER LA CONNEXION
      // --------------------------------------------------------

      return userCredential;
    }

    // ==========================================================
    // ERREUR GOOGLE SIGN-IN
    // ==========================================================

    on GoogleSignInException catch (e, stackTrace) {
      debugPrint(
        '==========================================',
      );

      debugPrint(
        '❌ GOOGLE SIGN-IN EXCEPTION',
      );

      debugPrint(
        'Code : ${e.code}',
      );

      debugPrint(
        'Description : ${e.description}',
      );

      debugPrint(
        'Details : ${e.details}',
      );

      debugPrint(
        '==========================================',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }

    // ==========================================================
    // ERREUR FIREBASE AUTH
    // ==========================================================

    on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        '==========================================',
      );

      debugPrint(
        '❌ FIREBASE AUTH EXCEPTION',
      );

      debugPrint(
        'Code : ${e.code}',
      );

      debugPrint(
        'Message : ${e.message}',
      );

      debugPrint(
        '==========================================',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }

    // ==========================================================
    // ERREUR FIRESTORE
    // ==========================================================

    on FirebaseException catch (e, stackTrace) {
      debugPrint(
        '==========================================',
      );

      debugPrint(
        '❌ FIRESTORE EXCEPTION',
      );

      debugPrint(
        'Plugin : ${e.plugin}',
      );

      debugPrint(
        'Code : ${e.code}',
      );

      debugPrint(
        'Message : ${e.message}',
      );

      debugPrint(
        '==========================================',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }

    // ==========================================================
    // AUTRE ERREUR
    // ==========================================================

    catch (e, stackTrace) {
      debugPrint(
        '==========================================',
      );

      debugPrint(
        '❌ ERREUR INATTENDUE',
      );

      debugPrint(
        '$e',
      );

      debugPrint(
        '==========================================',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ============================================================
  // DÉCONNEXION
  // ============================================================

  Future<void> signOut() async {
    try {
      await _initializeGoogleSignIn();

      await _googleSignIn.signOut();

      await _auth.signOut();

      debugPrint(
        '✅ Déconnexion réussie',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Erreur lors de la déconnexion : $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================
  // UTILISATEUR ACTUEL
  // ============================================================

  User? get currentUser {
    return _auth.currentUser;
  }
}