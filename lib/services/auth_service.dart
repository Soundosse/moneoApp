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

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _auth.currentUser;

  // ============================================================
  // INITIALISER GOOGLE SIGN-IN
  // ============================================================

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) {
      return;
    }

    await _googleSignIn.initialize();

    _googleInitialized = true;

    debugPrint('✅ Google Sign-In initialisé');
  }

  // ============================================================
  // INSCRIPTION EMAIL / PASSWORD
  // ============================================================

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final String cleanEmail = email.trim();
      final String cleanName = displayName.trim();

      if (cleanEmail.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Veuillez entrer votre adresse e-mail.',
        );
      }

      if (password.isEmpty) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Veuillez entrer un mot de passe.',
        );
      }

      if (cleanName.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-display-name',
          message: 'Veuillez entrer votre nom.',
        );
      }

      // --------------------------------------------------------
      // 1. CRÉER LE COMPTE FIREBASE
      // --------------------------------------------------------

      debugPrint(
        '🔵 Création du compte : $cleanEmail',
      );

      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'Impossible de récupérer le nouvel utilisateur.',
        );
      }

      debugPrint(
        '✅ Compte Firebase créé',
      );

      debugPrint(
        'UID : ${user.uid}',
      );

      // --------------------------------------------------------
      // 2. ENREGISTRER LE DISPLAY NAME DANS FIREBASE AUTH
      // --------------------------------------------------------

      await user.updateDisplayName(cleanName);

      // Important : récupérer la version actualisée
      await user.reload();

      final User? updatedUser = _auth.currentUser;

      debugPrint(
        '✅ Display name enregistré : '
            '${updatedUser?.displayName}',
      );

      // --------------------------------------------------------
      // 3. ENVOYER L'EMAIL DE VÉRIFICATION
      // --------------------------------------------------------

      await sendVerificationEmail();

      debugPrint(
        '✅ Email de vérification demandé',
      );

      // --------------------------------------------------------
      // 4. CRÉER LE PROFIL FIRESTORE
      // --------------------------------------------------------

      await createUserProfile(
        user: updatedUser ?? user,
        name: cleanName,
      );

      debugPrint(
        '✅ Profil Firestore créé',
      );

      return userCredential;
    }

    // ==========================================================
    // FIREBASE AUTH ERROR
    // ==========================================================

    on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        '==========================================',
      );

      debugPrint(
        '❌ SIGN UP FIREBASE AUTH ERROR',
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

      rethrow;
    }

    // ==========================================================
    // FIREBASE ERROR
    // ==========================================================

    on FirebaseException catch (e, stackTrace) {
      debugPrint(
        '==========================================',
      );

      debugPrint(
        '❌ FIREBASE ERROR',
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

      rethrow;
    }

    // ==========================================================
    // OTHER ERROR
    // ==========================================================

    catch (e, stackTrace) {
      debugPrint(
        '==========================================',
      );

      debugPrint(
        '❌ SIGN UP UNKNOWN ERROR',
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

      rethrow;
    }
  }

  // ============================================================
  // ENVOYER EMAIL DE VÉRIFICATION
  // ============================================================

  Future<void> sendVerificationEmail() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Aucun utilisateur connecté.',
      );
    }

    // ----------------------------------------------------------
    // ACTUALISER L'UTILISATEUR
    // ----------------------------------------------------------

    await user.reload();

    final User? refreshedUser = _auth.currentUser;

    if (refreshedUser == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Utilisateur introuvable.',
      );
    }

    // ----------------------------------------------------------
    // DÉJÀ VÉRIFIÉ
    // ----------------------------------------------------------

    if (refreshedUser.emailVerified) {
      debugPrint(
        'ℹ️ Email déjà vérifié.',
      );

      return;
    }

    // ----------------------------------------------------------
    // LANGUE
    // ----------------------------------------------------------

    await _auth.setLanguageCode('fr');

    // ----------------------------------------------------------
    // ENVOYER
    // ----------------------------------------------------------

    debugPrint(
      '📧 Envoi de l email de vérification vers '
          '${refreshedUser.email}',
    );

    await refreshedUser.sendEmailVerification();

    debugPrint(
      '✅ Demande d email de vérification envoyée',
    );
  }

  // ============================================================
  // VÉRIFIER SI L'EMAIL EST VÉRIFIÉ
  // ============================================================

  Future<bool> isEmailVerified() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      await user.reload();

      final User? refreshedUser = _auth.currentUser;

      return refreshedUser?.emailVerified ?? false;
    } catch (e) {
      debugPrint(
        '❌ Impossible de recharger utilisateur : $e',
      );

      return false;
    }
  }

  // ============================================================
  // CRÉER LE PROFIL FIRESTORE
  // ============================================================

  Future<void> createUserProfile({
    required User user,
    required String name,
  }) async {
    final DocumentReference<Map<String, dynamic>> userRef =
    _firestore
        .collection('users')
        .doc(user.uid);

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
    await userRef.get();

    // ----------------------------------------------------------
    // SI LE PROFIL EXISTE DÉJÀ
    // ----------------------------------------------------------

    if (snapshot.exists) {
      debugPrint(
        'ℹ️ Profil users/${user.uid} existe déjà.',
      );

      // Mise à jour du nom/email/photo sans écraser
      // les autres données de l'utilisateur.
      await userRef.set(
        {
          'name': name,
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return;
    }

    // ----------------------------------------------------------
    // NOUVEAU PROFIL
    // ----------------------------------------------------------

    await userRef.set({
      'name': name,
      'email': user.email ?? '',
      'currency': 'MAD',
      'photoUrl': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    debugPrint(
      '✅ Nouveau profil users/${user.uid} créé.',
    );
  }

  // ============================================================
  // GOOGLE SIGN-IN
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
      // 3. AUTHENTIFICATION GOOGLE
      // --------------------------------------------------------

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      debugPrint(
        'ID Token disponible : '
            '${googleAuth.idToken != null}',
      );

      if (googleAuth.idToken == null) {
        debugPrint(
          '❌ ID Token Google null',
        );

        return null;
      }

      // --------------------------------------------------------
      // 4. CRÉER CREDENTIAL FIREBASE
      // --------------------------------------------------------

      final OAuthCredential credential =
      GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      debugPrint(
        '✅ Credential Firebase créé',
      );

      // --------------------------------------------------------
      // 5. CONNEXION FIREBASE
      // --------------------------------------------------------

      final UserCredential userCredential =
      await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;

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
        'UID : ${user.uid}',
      );

      debugPrint(
        'Email : ${user.email}',
      );

      debugPrint(
        'Display name : ${user.displayName}',
      );

      // --------------------------------------------------------
      // 6. GOOGLE = EMAIL DÉJÀ AUTHENTIFIÉ
      // --------------------------------------------------------

      await createUserProfile(
        user: user,
        name: user.displayName ?? '',
      );

      // --------------------------------------------------------
      // 7. RETOUR
      // --------------------------------------------------------

      return userCredential;
    }

    // ==========================================================
    // GOOGLE ERROR
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
    // FIREBASE AUTH ERROR
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
    // FIRESTORE ERROR
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
    // OTHER ERROR
    // ==========================================================

    catch (e, stackTrace) {
      debugPrint(
        '==========================================',
      );

      debugPrint(
        '❌ UNKNOWN GOOGLE ERROR',
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
        '❌ Erreur déconnexion : $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================
  // RECHARGER L'UTILISATEUR
  // ============================================================

  Future<User?> reloadCurrentUser() async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        return null;
      }

      await user.reload();

      return _auth.currentUser;
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Erreur reload utilisateur : $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return null;
    }
  }
}