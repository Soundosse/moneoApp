import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/auth_service.dart';
import 'singnup.dart';
import 'dashboardPage.dart';


// ============================================================
// FIREBASE USER DOCUMENT
// ============================================================
//
// IMPORTANT
// ------------------------------------------------------------
// Cette fonction NE DOIT être appelée que pour un utilisateur
// qui est autorisé à être enregistré dans Firestore.
//
// Pour email/password :
//     user.emailVerified == true
//
// Pour Google :
//     on peut synchroniser directement.
// ============================================================

Future<void> syncUserDocument({
  required User user,
  required String provider,
}) async {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final DocumentReference<Map<String, dynamic>> userRef =
  firestore.collection('users').doc(user.uid);

  final DocumentSnapshot<Map<String, dynamic>> snapshot =
  await userRef.get();

  final Map<String, dynamic> existingData =
      snapshot.data() ?? <String, dynamic>{};


  // ==========================================================
  // EXISTING DISPLAY NAME
  // ==========================================================

  final String oldDisplayName =
  (existingData['displayName'] ??
      existingData['name'] ??
      '')
      .toString()
      .trim();

  final String firebaseDisplayName =
  (user.displayName ?? '').trim();

  final String finalDisplayName =
  firebaseDisplayName.isNotEmpty
      ? firebaseDisplayName
      : oldDisplayName;


  // ==========================================================
  // PHOTO
  // ==========================================================

  final String? finalPhotoUrl =
      user.photoURL ??
          (
              existingData['photoUrl']
                  ?.toString()
                  .trim()
                  .isNotEmpty ==
                  true
                  ? existingData['photoUrl']
                  .toString()
                  .trim()
                  : null
          );


  // ==========================================================
  // PREFERENCES
  // ==========================================================

  final Map<String, dynamic> existingPreferences =
  existingData['preferences'] is Map
      ? Map<String, dynamic>.from(
    existingData['preferences'] as Map,
  )
      : <String, dynamic>{};

  final Map<String, dynamic> preferences = {
    'language':
    existingPreferences['language'] ?? 'fr',

    'notificationsEnabled':
    existingPreferences['notificationsEnabled'] ?? true,

    'darkMode':
    existingPreferences['darkMode'] ?? false,
  };


  // ==========================================================
  // COMMON DATA
  // ==========================================================

  final Map<String, dynamic> data = {
    'displayName': finalDisplayName,

    'email': user.email ?? '',

    'photoUrl': finalPhotoUrl,

    'currency':
    existingData['currency'] ?? 'MAD',

    'country':
    existingData['country'] ?? 'MA',

    'onboardingCompleted':
    existingData['onboardingCompleted'] ?? false,

    'profileCompleted':
    existingData['profileCompleted'] ?? false,

    'emailVerified':
    user.emailVerified,

    'provider':
    provider,

    'preferences':
    preferences,

    'updatedAt':
    FieldValue.serverTimestamp(),
  };


  // ==========================================================
  // CREATED AT
  // ==========================================================

  if (!snapshot.exists) {
    data['createdAt'] =
        FieldValue.serverTimestamp();
  }


  // ==========================================================
  // MIGRATION
  // ==========================================================

  if (snapshot.exists &&
      existingData.containsKey('name')) {
    data['name'] =
        FieldValue.delete();
  }


  // ==========================================================
  // SAVE
  // ==========================================================

  await userRef.set(
    data,
    SetOptions(merge: true),
  );


  // ==========================================================
  // DEBUG
  // ==========================================================

  debugPrint(
    '==========================================',
  );

  debugPrint(
    'USER DOCUMENT SYNCHRONISÉ',
  );

  debugPrint(
    'UID : ${user.uid}',
  );

  debugPrint(
    'EMAIL : ${user.email}',
  );

  debugPrint(
    'DISPLAY NAME : $finalDisplayName',
  );

  debugPrint(
    'PROVIDER : $provider',
  );

  debugPrint(
    'EMAIL VERIFIED : ${user.emailVerified}',
  );

  debugPrint(
    '==========================================',
  );
}



// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}



// ============================================================
// LOGIN STATE
// ============================================================

class _LoginScreenState
    extends State<LoginScreen>
    with WidgetsBindingObserver {

  final AuthService _authService =
  AuthService();

  bool _isLoading = false;

  bool _obscurePassword = true;


  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController
  _emailController =
  TextEditingController();

  final TextEditingController
  _passwordController =
  TextEditingController();


  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addObserver(this);

    _hideSystemNavigation();
  }


  // ==========================================================
  // KEEP NAVIGATION HIDDEN
  // ==========================================================

  void _hideSystemNavigation() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:
        Colors.transparent,

        statusBarIconBrightness:
        Brightness.light,

        statusBarBrightness:
        Brightness.dark,

        systemNavigationBarColor:
        Color(0xFF050507),

        systemNavigationBarIconBrightness:
        Brightness.light,

        systemNavigationBarDividerColor:
        Color(0xFF050507),
      ),
    );
  }


  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state) {

    if (state ==
        AppLifecycleState.resumed) {
      _hideSystemNavigation();
    }
  }


  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this);

    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();
  }



  // ==========================================================
  // FORGOT PASSWORD
  // ==========================================================

  Future<void> _forgotPassword() async {

    if (_isLoading) return;


    // --------------------------------------------------------
    // CLEAN EMAIL
    // --------------------------------------------------------

    final String email =
    _emailController.text
        .trim()
        .toLowerCase();


    if (email.isEmpty) {
      _showMessage(
        'Veuillez entrer votre email.',
      );
      return;
    }


    _emailController.value =
        TextEditingValue(
          text: email,
          selection:
          TextSelection.collapsed(
            offset: email.length,
          ),
        );


    setState(() {
      _isLoading = true;
    });


    try {

      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );


      if (!mounted) return;

      _showMessage(
        'Un email de réinitialisation a été envoyé à $email. Vérifiez aussi vos spams.',
      );

    } on FirebaseAuthException catch (e) {

      if (!mounted) return;

      debugPrint(
        'Forgot Password : '
            '${e.code} - ${e.message}',
      );


      switch (e.code) {

        case 'invalid-email':

          _showMessage(
            'Email invalide.',
          );

          break;


        case 'user-not-found':

          _showMessage(
            'Aucun compte trouvé avec cet email.',
          );

          break;


        case 'operation-not-allowed':

          _showMessage(
            'La réinitialisation du mot de passe par email n’est pas activée dans Firebase.',
          );

          break;


        case 'too-many-requests':

          _showMessage(
            'Trop de demandes. Réessayez plus tard.',
          );

          break;


        case 'network-request-failed':

          _showMessage(
            'Vérifiez votre connexion Internet.',
          );

          break;


        default:

          _showMessage(
            'Impossible d’envoyer l’email de récupération. Réessayez plus tard.',
          );
      }

    } catch (e) {

      if (!mounted) return;

      debugPrint(
        'Forgot Password : $e',
      );

      _showMessage(
        'Impossible d’envoyer l’email de récupération. Réessayez plus tard.',
      );

    } finally {

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }



  // ==========================================================
  // EMAIL / PASSWORD LOGIN
  // ==========================================================

  Future<void>
  _loginWithEmailPassword() async {

    if (_isLoading) return;


    // --------------------------------------------------------
    // CLEAN EMAIL
    // --------------------------------------------------------

    final String email =
    _emailController.text
        .trim()
        .toLowerCase();


    // --------------------------------------------------------
    // CLEAN PASSWORD
    // --------------------------------------------------------
    //
    // IMPORTANT :
    // On supprime uniquement les espaces accidentels
    // autour du mot de passe.
    //
    // --------------------------------------------------------

    final String password =
    _passwordController.text.trim();


    // --------------------------------------------------------
    // VALIDATION
    // --------------------------------------------------------

    if (email.isEmpty ||
        password.isEmpty) {

      _showMessage(
        'Veuillez remplir tous les champs.',
      );

      return;
    }


    // Remettre l'email nettoyé
    _emailController.value =
        TextEditingValue(
          text: email,
          selection:
          TextSelection.collapsed(
            offset: email.length,
          ),
        );


    setState(() {
      _isLoading = true;
    });


    try {

      // ======================================================
      // FIREBASE LOGIN
      // ======================================================

      final UserCredential
      userCredential =
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      User? user =
          userCredential.user;


      if (user == null) {

        _showMessage(
          'Connexion échouée.',
        );

        return;
      }


      // ======================================================
      // RELOAD USER
      // ======================================================

      await user.reload();

      user =
          FirebaseAuth
              .instance
              .currentUser;


      if (user == null) {

        _showMessage(
          'Utilisateur introuvable.',
        );

        return;
      }


      // ======================================================
      // 🚨 EMAIL NON VÉRIFIÉ
      // ======================================================
      //
      // TRÈS IMPORTANT :
      //
      // ❌ PAS DE syncUserDocument()
      //
      // ❌ PAS DE Firestore users/{uid}
      //
      // ❌ PAS DE Dashboard
      //
      // ❌ PAS DE displayName
      //
      // On affiche uniquement l'écran de vérification.
      //
      // ======================================================

      if (!user.emailVerified) {

        debugPrint(
          'EMAIL NON VÉRIFIÉ',
        );

        debugPrint(
          'Aucun document Firestore ne sera synchronisé.',
        );


        if (!mounted) return;


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmailVerificationScreen(
                  email:
                  user?.email ??
                      email,
                ),
          ),
        );


        return;
      }


      // ======================================================
      // ✅ EMAIL VÉRIFIÉ
      // ======================================================
      //
      // Seulement maintenant nous pouvons synchroniser
      // l'utilisateur dans Firestore.
      //
      // ======================================================

      await syncUserDocument(
        user: user,
        provider: 'email',
      );


      if (!mounted) return;


      _showMessage(
        'Connexion réussie !',
      );


      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );


      if (!mounted) return;


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const DashboardPage(),
        ),
      );

    } on FirebaseAuthException catch (e) {

      if (!mounted) return;


      debugPrint(
        'Firebase Auth : ${e.code}',
      );


      switch (e.code) {

        case 'invalid-email':

          _showMessage(
            'Email invalide.',
          );

          break;


        case 'user-not-found':

          _showMessage(
            'Aucun compte trouvé avec cet email.',
          );

          break;


        case 'wrong-password':

        case 'invalid-credential':

          _showMessage(
            'Email ou mot de passe incorrect.',
          );

          break;


        case 'user-disabled':

          _showMessage(
            'Ce compte a été désactivé.',
          );

          break;


        case 'too-many-requests':

          _showMessage(
            'Trop de tentatives. Réessayez plus tard.',
          );

          break;


        case 'network-request-failed':

          _showMessage(
            'Vérifiez votre connexion Internet.',
          );

          break;


        default:

          _showMessage(
            'Erreur lors de la connexion.',
          );
      }

    } on FirebaseException catch (e) {

      if (!mounted) return;

      debugPrint(
        'Firebase : ${e.code}',
      );

      _showMessage(
        'Erreur lors de la récupération du profil.',
      );

    } catch (e, stackTrace) {

      if (!mounted) return;

      debugPrint(
        'Login error : $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showMessage(
        'Erreur lors de la connexion.',
      );

    } finally {

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }



  // ==========================================================
  // GOOGLE LOGIN
  // ==========================================================

  Future<void> _loginWithGoogle() async {

    if (_isLoading) return;


    setState(() {
      _isLoading = true;
    });


    try {

      final UserCredential? result =
      await _authService
          .signInWithGoogle();


      if (!mounted) return;


      if (result == null) {

        _showMessage(
          'Connexion avec Google échouée.',
        );

        return;
      }


      final User? user =
          result.user;


      if (user == null) {

        _showMessage(
          'Utilisateur Google introuvable.',
        );

        return;
      }


      // ======================================================
      // GOOGLE
      // ======================================================
      //
      // Google fournit déjà généralement le displayName.
      //
      // On peut donc synchroniser directement.
      //
      // ======================================================

      await syncUserDocument(
        user: user,
        provider: 'google',
      );


      if (!mounted) return;


      _showMessage(
        'Connexion avec Google réussie !',
      );


      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );


      if (!mounted) return;


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const DashboardPage(),
        ),
      );

    } catch (e, stackTrace) {

      if (!mounted) return;


      debugPrint(
        'Google login : $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );


      _showMessage(
        'Connexion avec Google échouée.',
      );

    } finally {

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }



  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
      String message) {

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();


    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
        Text(message),

        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }



  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFF050507),

      // IMPORTANT :
      // Le clavier ne redimensionne pas le Scaffold.
      // La wave reste donc tout en bas.
      resizeToAvoidBottomInset:
      false,

      body: Stack(
        children: [

          // ==================================================
          // BACKGROUND
          // ==================================================

          Positioned.fill(
            child:
            _buildBackground(),
          ),


          // ==================================================
          // WAVE
          // ==================================================

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 155,

            child: IgnorePointer(
              child: CustomPaint(
                painter:
                _MoneoWavePainter(),
              ),
            ),
          ),


          // ==================================================
          // CONTENT
          // ==================================================

          Positioned.fill(
            child:
            _buildContent(),
          ),
        ],
      ),
    );
  }



  // ==========================================================
  // BACKGROUND
  // ==========================================================

  Widget _buildBackground() {

    return Container(
      color:
      const Color(0xFF050507),

      child: Stack(
        children: [

          Positioned(
            top: 220,

            left:
            MediaQuery.of(context)
                .size
                .width /
                2 -
                160,

            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,

                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color:
                      const Color(
                        0xFF32105E,
                      ).withOpacity(
                        0.035,
                      ),

                      blurRadius:
                      120,

                      spreadRadius:
                      0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  // ==========================================================
  // CONTENT
  // ==========================================================

  Widget _buildContent() {

    return LayoutBuilder(
      builder:
          (context, constraints) {

        return SingleChildScrollView(
          physics:
          const BouncingScrollPhysics(),

          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior
              .onDrag,

          padding:
          const EdgeInsets.fromLTRB(
            28,
            20,
            28,
            215,
          ),

          child: ConstrainedBox(
            constraints:
            BoxConstraints(
              minHeight:
              constraints.maxHeight -
                  20,
            ),

            child: Column(
              children: [

                _buildLogo(),

                _buildTitle(),

                _buildSubtitle(),

                _buildFeatures(),

                _buildLoginForm(),

                _buildDivider(),

                _buildSocialButtons(),

                _buildSignUp(),
              ],
            ),
          ),
        );
      },
    );
  }



  // ==========================================================
  // LOGO
  // ==========================================================

  Widget _buildLogo() {

    return Column(
      children: [

        const SizedBox(
          height: 4,
        ),

        SizedBox(
          width: 92,
          height: 82,

          child: Image.asset(
            'assets/images/foreground.png',

            fit:
            BoxFit.contain,

            errorBuilder:
                (context,
                error,
                stackTrace) {

              return const Icon(
                Icons
                    .account_balance_wallet_rounded,

                size: 58,

                color:
                Color(0xFF6B5BFF),
              );
            },
          ),
        ),
      ],
    );
  }



  // ==========================================================
  // TITLE
  // ==========================================================

  Widget _buildTitle() {

    return const Column(
      children: [

        SizedBox(
          height: 2,
        ),

        Text(
          'Moneo',

          textAlign:
          TextAlign.center,

          style:
          TextStyle(
            fontSize: 38,

            fontWeight:
            FontWeight.w700,

            color:
            Color(0xFFF4F3F6),

            letterSpacing:
            -1,
          ),
        ),
      ],
    );
  }



  // ==========================================================
  // SUBTITLE
  // ==========================================================

  Widget _buildSubtitle() {

    return Column(
      children: [

        const SizedBox(
          height: 8,
        ),

        RichText(
          textAlign:
          TextAlign.center,

          text:
          const TextSpan(
            style:
            TextStyle(
              fontSize: 16,

              color:
              Color(0xFFA09CA6),

              height: 1.4,
            ),

            children: [

              TextSpan(
                text: 'Your ',
              ),

              TextSpan(
                text: 'AI',

                style:
                TextStyle(
                  color:
                  Color(0xFF187FA8),

                  fontWeight:
                  FontWeight.w500,
                ),
              ),

              TextSpan(
                text:
                ' financial assistant\nfor ',
              ),

              TextSpan(
                text:
                'student life.',

                style:
                TextStyle(
                  color:
                  Color(0xFF78418F),

                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  // ==========================================================
  // FEATURES
  // ==========================================================

  Widget _buildFeatures() {

    return const Column(
      children: [

        SizedBox(
          height: 22,
        ),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceEvenly,

          children: [

            _FeatureItem(
              icon:
              Icons.shield_outlined,

              title:
              'Secure',
            ),

            _FeatureItem(
              icon:
              Icons.bolt_outlined,

              title:
              'Smart',
            ),

            _FeatureItem(
              icon:
              Icons.bar_chart_rounded,

              title:
              'Insightful',
            ),
          ],
        ),
      ],
    );
  }



  // ==========================================================
  // LOGIN FORM
  // ==========================================================

  Widget _buildLoginForm() {

    return Column(
      children: [

        const SizedBox(
          height: 28,
        ),

        _LoginTextField(
          controller:
          _emailController,

          icon:
          Icons.mail_outline_rounded,

          hintText:
          'Email',

          suffixIcon:
          null,

          keyboardType:
          TextInputType.emailAddress,

          textInputAction:
          TextInputAction.next,
        ),

        const SizedBox(
          height: 14,
        ),

        _LoginTextField(
          controller:
          _passwordController,

          icon:
          Icons.lock_outline_rounded,

          hintText:
          'Password',

          suffixIcon:
          Icons.visibility_outlined,

          obscureText:
          _obscurePassword,

          textInputAction:
          TextInputAction.done,

          onSubmitted:
              (_) {

            if (!_isLoading) {
              _loginWithEmailPassword();
            }
          },

          onSuffixIconPressed:
              () {

            setState(() {
              _obscurePassword =
              !_obscurePassword;
            });
          },
        ),


        // ====================================================
        // FORGOT PASSWORD
        // ====================================================

        Align(
          alignment:
          Alignment.centerRight,

          child: TextButton(
            onPressed:
            _isLoading
                ? null
                : _forgotPassword,

            style:
            TextButton.styleFrom(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 2,
                vertical: 2,
              ),
            ),

            child:
            const Text(
              'Forgot password?',

              style:
              TextStyle(
                color:
                Color(0xFF704B88),

                fontSize:
                14,
              ),
            ),
          ),
        ),


        const SizedBox(
          height: 5,
        ),


        _buildSignInButton(),
      ],
    );
  }



  // ==========================================================
  // SIGN IN BUTTON
  // ==========================================================

  Widget _buildSignInButton() {

    return SizedBox(
      width:
      double.infinity,

      height:
      52,

      child:
      DecoratedBox(
        decoration:
        BoxDecoration(
          borderRadius:
          BorderRadius.circular(
            17,
          ),

          gradient:
          const LinearGradient(
            begin:
            Alignment.centerLeft,

            end:
            Alignment.centerRight,

            colors: [
              Color(0xFF00CFFF),
              Color(0xFF4169FF),
              Color(0xFF7B2CFF),
            ],
          ),
        ),

        child:
        ElevatedButton(
          onPressed:
          _isLoading
              ? null
              : _loginWithEmailPassword,

          style:
          ElevatedButton.styleFrom(
            backgroundColor:
            Colors.transparent,

            foregroundColor:
            Colors.white,

            shadowColor:
            Colors.transparent,

            disabledBackgroundColor:
            Colors.transparent,

            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                17,
              ),
            ),
          ),

          child:
          _isLoading
              ? const SizedBox(
            width: 24,
            height: 24,

            child:
            CircularProgressIndicator(
              strokeWidth:
              2.5,

              color:
              Colors.white,
            ),
          )
              : const Text(
            'Sign In',

            style:
            TextStyle(
              fontSize:
              18,

              fontWeight:
              FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }



  // ==========================================================
  // DIVIDER
  // ==========================================================

  Widget _buildDivider() {

    return Column(
      children: [

        const SizedBox(
          height: 25,
        ),

        Row(
          children: [

            const Expanded(
              child:
              Divider(
                color:
                Color(0xFF211F26),

                thickness:
                1,
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
              ),

              child:
              Text(
                'or continue with',

                style:
                TextStyle(
                  color:
                  Colors.grey.shade600,

                  fontSize:
                  13,
                ),
              ),
            ),

            const Expanded(
              child:
              Divider(
                color:
                Color(0xFF211F26),

                thickness:
                1,
              ),
            ),
          ],
        ),
      ],
    );
  }



  // ==========================================================
  // SOCIAL BUTTONS
  // ==========================================================

  Widget _buildSocialButtons() {

    return Padding(
      padding:
      const EdgeInsets.only(
        top: 20,
      ),

      child:
      Row(
        children: [

          Expanded(
            child:
            _SocialButton(
              icon:
              Icons.g_mobiledata_rounded,

              label:
              'Google',

              color:
              const Color(
                0xFFE2E2E2,
              ),

              onPressed:
              _isLoading
                  ? null
                  : _loginWithGoogle,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child:
            _SocialButton(
              icon:
              Icons.apple,

              label:
              'Apple',

              color:
              const Color(
                0xFFE2E2E2,
              ),

              onPressed: () {

                _showMessage(
                  'Apple Sign-In à venir.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }



  // ==========================================================
  // SIGN UP
  // ==========================================================

  Widget _buildSignUp() {

    return Padding(
      padding:
      const EdgeInsets.only(
        top: 22,
        bottom: 12,
      ),

      child:
      Row(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Text(
            "Don't have an account?",

            style:
            TextStyle(
              color:
              Colors.grey.shade600,

              fontSize:
              14,
            ),
          ),

          TextButton(
            onPressed:
            _isLoading
                ? null
                : () {

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder:
                      (context) =>
                  const SignUpScreen(),
                ),
              );
            },

            style:
            TextButton.styleFrom(
              padding:
              const EdgeInsets.only(
                left: 5,
              ),
            ),

            child:
            const Text(
              'Sign up',

              style:
              TextStyle(
                color:
                Color(0xFF7D3F96),

                fontSize:
                14,

                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// ============================================================
// FEATURE ITEM
// ============================================================

class _FeatureItem
    extends StatelessWidget {

  final IconData icon;

  final String title;

  const _FeatureItem({
    required this.icon,
    required this.title,
  });


  @override
  Widget build(
      BuildContext context) {

    return Column(
      children: [

        Container(
          width: 58,
          height: 58,

          decoration:
          BoxDecoration(
            color:
            const Color(
              0xFF08080B,
            ),

            borderRadius:
            BorderRadius.circular(
              15,
            ),

            border:
            Border.all(
              color:
              const Color(
                0xFF1E1A29,
              ),

              width: 1,
            ),
          ),

          child:
          Icon(
            icon,

            color:
            const Color(
              0xFF584285,
            ),

            size:
            27,
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        Text(
          title,

          style:
          const TextStyle(
            color:
            Color(0xFFA7A3AC),

            fontSize:
            13,
          ),
        ),
      ],
    );
  }
}



// ============================================================
// LOGIN TEXT FIELD
// ============================================================

class _LoginTextField
    extends StatelessWidget {

  final TextEditingController
  controller;

  final IconData icon;

  final IconData? suffixIcon;

  final String hintText;

  final bool obscureText;

  final TextInputType?
  keyboardType;

  final TextInputAction?
  textInputAction;

  final VoidCallback?
  onSuffixIconPressed;

  final ValueChanged<String>?
  onSubmitted;


  const _LoginTextField({
    required this.controller,
    required this.icon,
    required this.suffixIcon,
    required this.hintText,

    this.obscureText = false,

    this.keyboardType,

    this.textInputAction,

    this.onSuffixIconPressed,

    this.onSubmitted,
  });


  @override
  Widget build(
      BuildContext context) {

    return Container(
      height: 65,

      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFF08080B,
        ),

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border:
        Border.all(
          color:
          const Color(
            0xFF211D2B,
          ),

          width: 1,
        ),
      ),

      child:
      TextField(
        controller:
        controller,

        obscureText:
        obscureText,

        keyboardType:
        keyboardType,

        textInputAction:
        textInputAction,

        onSubmitted:
        onSubmitted,

        style:
        const TextStyle(
          color:
          Color(0xFFE7E5E9),

          fontSize:
          15,
        ),

        cursorColor:
        const Color(
          0xFF68417D,
        ),

        decoration:
        InputDecoration(
          border:
          InputBorder.none,

          hintText:
          hintText,

          hintStyle:
          const TextStyle(
            color:
            Color(0xFF64616A),

            fontSize:
            15,
          ),

          prefixIcon:
          Icon(
            icon,

            color:
            const Color(
              0xFF594181,
            ),

            size:
            25,
          ),

          suffixIcon:
          suffixIcon == null
              ? null
              : IconButton(
            onPressed:
            onSuffixIconPressed,

            icon:
            Icon(
              obscureText
                  ? Icons
                  .visibility_outlined
                  : Icons
                  .visibility_off_outlined,

              color:
              const Color(
                0xFF45414C,
              ),

              size:
              23,
            ),
          ),

          contentPadding:
          const EdgeInsets
              .symmetric(
            vertical:
            21,
          ),
        ),
      ),
    );
  }
}



// ============================================================
// SOCIAL BUTTON
// ============================================================

class _SocialButton
    extends StatelessWidget {

  final IconData icon;

  final Color color;

  final String label;

  final VoidCallback? onPressed;


  const _SocialButton({
    required this.icon,
    required this.color,
    required this.label,
    this.onPressed,
  });


  @override
  Widget build(
      BuildContext context) {

    return SizedBox(
      height: 68,

      child:
      OutlinedButton(
        onPressed:
        onPressed,

        style:
        OutlinedButton.styleFrom(
          backgroundColor:
          const Color(
            0xFF08080B,
          ),

          foregroundColor:
          const Color(
            0xFFE5E3E7,
          ),

          padding:
          const EdgeInsets
              .symmetric(
            horizontal: 5,
            vertical: 7,
          ),

          side:
          const BorderSide(
            color:
            Color(0xFF211D2B),

            width: 1,
          ),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              16,
            ),
          ),
        ),

        child:
        Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Icon(
              icon,

              color:
              color,

              size:
              24,
            ),

            const SizedBox(
              height: 3,
            ),

            FittedBox(
              fit:
              BoxFit.scaleDown,

              child:
              Text(
                label,

                style:
                const TextStyle(
                  color:
                  Color(
                    0xFFAAA6B0,
                  ),

                  fontSize:
                  11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ============================================================
// EMAIL VERIFICATION SCREEN
// ============================================================

class EmailVerificationScreen
    extends StatefulWidget {

  final String email;


  const EmailVerificationScreen({
    super.key,
    required this.email,
  });


  @override
  State<EmailVerificationScreen>
  createState() =>
      _EmailVerificationScreenState();
}



// ============================================================
// EMAIL VERIFICATION STATE
// ============================================================

class _EmailVerificationScreenState
    extends State<EmailVerificationScreen>
    with WidgetsBindingObserver {

  bool _checking = false;

  bool _resending = false;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addObserver(this);

    _hideSystemNavigation();
  }


  // ==========================================================
  // NAVIGATION BAR
  // ==========================================================

  void _hideSystemNavigation() {

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:
        Colors.transparent,

        statusBarIconBrightness:
        Brightness.light,

        systemNavigationBarColor:
        Color(0xFF050507),

        systemNavigationBarIconBrightness:
        Brightness.light,

        systemNavigationBarDividerColor:
        Color(0xFF050507),
      ),
    );
  }


  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state) {

    if (state ==
        AppLifecycleState.resumed) {

      _hideSystemNavigation();
    }
  }


  @override
  void dispose() {

    WidgetsBinding.instance
        .removeObserver(this);

    super.dispose();
  }



  // ==========================================================
  // CHECK EMAIL VERIFICATION
  // ==========================================================

  Future<void>
  _checkVerification() async {

    if (_checking) return;


    setState(() {
      _checking = true;
    });


    try {

      User? user =
          FirebaseAuth
              .instance
              .currentUser;


      if (user == null) {

        _showMessage(
          'Utilisateur introuvable.',
        );

        return;
      }


      // ======================================================
      // RELOAD FIREBASE USER
      // ======================================================

      await user.reload();


      user =
          FirebaseAuth
              .instance
              .currentUser;


      if (user == null) {

        _showMessage(
          'Utilisateur introuvable.',
        );

        return;
      }


      // ======================================================
      // EMAIL VERIFIED
      // ======================================================

      if (user.emailVerified) {

        debugPrint(
          'EMAIL VÉRIFIÉ ✅',
        );


        // ====================================================
        // MAINTENANT SEULEMENT :
        // FIRESTORE
        // ====================================================

        await syncUserDocument(
          user: user,
          provider: 'email',
        );


        if (!mounted) return;


        _showMessage(
          'Email vérifié avec succès !',
        );


        await Future.delayed(
          const Duration(
            milliseconds: 600,
          ),
        );


        if (!mounted) return;


        Navigator.pushAndRemoveUntil(
          context,

          MaterialPageRoute(
            builder:
                (context) =>
            const DashboardPage(),
          ),

              (route) => false,
        );

      } else {

        // ====================================================
        // STILL NOT VERIFIED
        // ====================================================

        if (!mounted) return;


        _showMessage(
          'Votre email n’est pas encore vérifié.',
        );
      }

    } catch (e) {

      if (!mounted) return;


      debugPrint(
        'Erreur vérification : $e',
      );


      _showMessage(
        'Impossible de vérifier votre email.',
      );

    } finally {

      if (!mounted) return;


      setState(() {
        _checking = false;
      });
    }
  }



  // ==========================================================
  // RESEND VERIFICATION EMAIL
  // ==========================================================

  Future<void>
  _resendVerificationEmail() async {

    if (_resending) return;


    setState(() {
      _resending = true;
    });


    try {

      final User? user =
          FirebaseAuth
              .instance
              .currentUser;


      if (user == null) {

        _showMessage(
          'Utilisateur introuvable.',
        );

        return;
      }


      if (user.emailVerified) {

        _showMessage(
          'Votre email est déjà vérifié.',
        );

        return;
      }


      await user
          .sendEmailVerification();


      if (!mounted) return;


      _showMessage(
        'Email de vérification renvoyé.',
      );

    } on FirebaseAuthException catch (e) {

      if (!mounted) return;


      debugPrint(
        'Resend verification : '
            '${e.code}',
      );


      if (e.code ==
          'too-many-requests') {

        _showMessage(
          'Trop de demandes. Réessayez plus tard.',
        );

      } else {

        _showMessage(
          'Impossible de renvoyer l’email.',
        );
      }

    } catch (e) {

      if (!mounted) return;


      debugPrint(
        'Resend error : $e',
      );


      _showMessage(
        'Impossible de renvoyer l’email.',
      );

    } finally {

      if (!mounted) return;


      setState(() {
        _resending = false;
      });
    }
  }



  // ==========================================================
  // BACK TO LOGIN
  // ==========================================================

  Future<void>
  _backToLogin() async {

    if (_checking ||
        _resending) {
      return;
    }


    try {

      // ======================================================
      // IMPORTANT
      // ======================================================
      //
      // On déconnecte l'utilisateur.
      //
      // Il ne sera donc pas considéré comme connecté
      // par Firebase.
      //
      // ======================================================

      await FirebaseAuth
          .instance
          .signOut();


      if (!mounted) return;


      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(
          builder:
              (context) =>
          const LoginScreen(),
        ),

            (route) => false,
      );

    } catch (e) {

      if (!mounted) return;


      debugPrint(
        'Back to login error : $e',
      );


      _showMessage(
        'Impossible de revenir à la connexion.',
      );
    }
  }



  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
      String message) {

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();


    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
        Text(message),

        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }



  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFF050507),

      resizeToAvoidBottomInset:
      false,

      body:
      Stack(
        children: [

          // ==================================================
          // BACKGROUND
          // ==================================================

          Positioned.fill(
            child:
            Container(
              color:
              const Color(
                0xFF050507,
              ),
            ),
          ),


          // ==================================================
          // WAVE
          // ==================================================

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,

            height: 155,

            child:
            IgnorePointer(
              child:
              CustomPaint(
                painter:
                _MoneoWavePainter(),
              ),
            ),
          ),


          // ==================================================
          // CONTENT
          // ==================================================

          Positioned.fill(
            child:
            SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),

              padding:
              const EdgeInsets
                  .fromLTRB(
                28,
                30,
                28,
                210,
              ),

              child:
              Column(
                children: [

                  // ========================================
                  // LOGO
                  // ========================================

                  SizedBox(
                    width: 92,
                    height: 82,

                    child:
                    Image.asset(
                      'assets/images/foreground.png',

                      fit:
                      BoxFit.contain,

                      errorBuilder:
                          (context,
                          error,
                          stackTrace) {

                        return const Icon(
                          Icons
                              .account_balance_wallet_rounded,

                          size:
                          58,

                          color:
                          Color(
                            0xFF6B5BFF,
                          ),
                        );
                      },
                    ),
                  ),


                  const SizedBox(
                    height: 15,
                  ),


                  // ========================================
                  // TITLE
                  // ========================================

                  const Text(
                    'Verify your email',

                    textAlign:
                    TextAlign.center,

                    style:
                    TextStyle(
                      fontSize:
                      28,

                      fontWeight:
                      FontWeight.w700,

                      color:
                      Color(
                        0xFFF4F3F6,
                      ),
                    ),
                  ),


                  const SizedBox(
                    height: 14,
                  ),


                  // ========================================
                  // DESCRIPTION
                  // ========================================

                  const Text(
                    'We sent a verification email to',

                    textAlign:
                    TextAlign.center,

                    style:
                    TextStyle(
                      fontSize:
                      15,

                      color:
                      Color(
                        0xFFA09CA6,
                      ),

                      height:
                      1.4,
                    ),
                  ),


                  const SizedBox(
                    height: 8,
                  ),


                  // ========================================
                  // EMAIL
                  // ========================================

                  Text(
                    widget.email,

                    textAlign:
                    TextAlign.center,

                    style:
                    const TextStyle(
                      fontSize:
                      15,

                      fontWeight:
                      FontWeight.w600,

                      color:
                      Color(
                        0xFF9B5CBB,
                      ),
                    ),
                  ),


                  const SizedBox(
                    height: 28,
                  ),


                  // ========================================
                  // EMAIL ICON
                  // ========================================

                  Container(
                    width: 74,
                    height: 74,

                    decoration:
                    BoxDecoration(
                      shape:
                      BoxShape.circle,

                      color:
                      const Color(
                        0xFF0B0A10,
                      ),

                      border:
                      Border.all(
                        color:
                        const Color(
                          0xFF281B34,
                        ),

                        width:
                        1,
                      ),
                    ),

                    child:
                    const Icon(
                      Icons
                          .mark_email_unread_outlined,

                      size:
                      34,

                      color:
                      Color(
                        0xFF704B88,
                      ),
                    ),
                  ),


                  const SizedBox(
                    height: 30,
                  ),


                  // ========================================
                  // CHECK BUTTON
                  // ========================================

                  _gradientButton(
                    text:
                    'I verified my email',

                    loading:
                    _checking,

                    onPressed:
                    _checking
                        ? null
                        : _checkVerification,
                  ),


                  const SizedBox(
                    height: 14,
                  ),


                  // ========================================
                  // RESEND
                  // ========================================

                  TextButton(
                    onPressed:
                    _resending
                        ? null
                        : _resendVerificationEmail,

                    child:
                    _resending
                        ? const SizedBox(
                      width:
                      20,

                      height:
                      20,

                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,

                        color:
                        Color(
                          0xFF704B88,
                        ),
                      ),
                    )
                        : const Text(
                      'Resend verification email',

                      style:
                      TextStyle(
                        color:
                        Color(
                          0xFF704B88,
                        ),

                        fontSize:
                        14,
                      ),
                    ),
                  ),


                  const SizedBox(
                    height: 8,
                  ),


                  // ========================================
                  // BACK TO LOGIN
                  // ========================================

                  TextButton(
                    onPressed:
                    _backToLogin,

                    child:
                    const Text(
                      'Back to login',

                      style:
                      TextStyle(
                        color:
                        Color(
                          0xFF77727D,
                        ),

                        fontSize:
                        13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  // ==========================================================
  // GRADIENT BUTTON
  // ==========================================================

  Widget _gradientButton({
    required String text,
    required bool loading,
    required VoidCallback? onPressed,
  }) {

    return SizedBox(
      width:
      double.infinity,

      height:
      52,

      child:
      DecoratedBox(
        decoration:
        BoxDecoration(
          borderRadius:
          BorderRadius.circular(
            17,
          ),

          gradient:
          const LinearGradient(
            colors: [
              Color(0xFF00CFFF),
              Color(0xFF4169FF),
              Color(0xFF7B2CFF),
            ],
          ),
        ),

        child:
        ElevatedButton(
          onPressed:
          onPressed,

          style:
          ElevatedButton.styleFrom(
            backgroundColor:
            Colors.transparent,

            shadowColor:
            Colors.transparent,

            disabledBackgroundColor:
            Colors.transparent,

            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                17,
              ),
            ),
          ),

          child:
          loading
              ? const SizedBox(
            width:
            23,

            height:
            23,

            child:
            CircularProgressIndicator(
              strokeWidth:
              2.5,

              color:
              Colors.white,
            ),
          )
              : Text(
            text,

            style:
            const TextStyle(
              fontSize:
              16,

              fontWeight:
              FontWeight.w500,

              color:
              Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}



// ============================================================
// MONEO WAVE PAINTER
// ============================================================

class _MoneoWavePainter
    extends CustomPainter {

  @override
  void paint(
      Canvas canvas,
      Size size) {


    // ========================================================
    // GRADIENT
    // ========================================================

    final LinearGradient gradient =
    const LinearGradient(
      begin:
      Alignment.centerLeft,

      end:
      Alignment.centerRight,

      colors: [
        Color(0xFF16708D),
        Color(0xFF1656A3),
        Color(0xFF272A9B),
        Color(0xFF4B24A5),
        Color(0xFF73258C),
      ],

      stops: [
        0.0,
        0.25,
        0.50,
        0.75,
        1.0,
      ],
    );


    // ========================================================
    // MAIN WAVE
    // ========================================================

    final Paint mainPaint =
    Paint()
      ..shader =
      gradient.createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      )
      ..color =
      Colors.white.withOpacity(
        0.48,
      );


    final Path mainWave =
    Path();


    mainWave.moveTo(
      0,
      size.height * 0.48,
    );


    mainWave.cubicTo(
      size.width * 0.15,
      size.height * 0.20,

      size.width * 0.30,
      size.height * 0.68,

      size.width * 0.47,
      size.height * 0.47,
    );


    mainWave.cubicTo(
      size.width * 0.62,
      size.height * 0.25,

      size.width * 0.78,
      size.height * 0.65,

      size.width,
      size.height * 0.32,
    );


    mainWave.lineTo(
      size.width,
      size.height,
    );


    mainWave.lineTo(
      0,
      size.height,
    );


    mainWave.close();


    canvas.drawPath(
      mainWave,
      mainPaint,
    );


    // ========================================================
    // SECONDARY WAVE
    // ========================================================

    final Paint secondPaint =
    Paint()
      ..shader =
      gradient.createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      )
      ..color =
      Colors.white.withOpacity(
        0.07,
      );


    final Path secondWave =
    Path();


    secondWave.moveTo(
      0,
      size.height * 0.72,
    );


    secondWave.cubicTo(
      size.width * 0.16,
      size.height * 0.43,

      size.width * 0.33,
      size.height * 0.80,

      size.width * 0.50,
      size.height * 0.63,
    );


    secondWave.cubicTo(
      size.width * 0.66,
      size.height * 0.45,

      size.width * 0.82,
      size.height * 0.82,

      size.width,
      size.height * 0.55,
    );


    secondWave.lineTo(
      size.width,
      size.height,
    );


    secondWave.lineTo(
      0,
      size.height,
    );


    secondWave.close();


    canvas.drawPath(
      secondWave,
      secondPaint,
    );
  }


  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate) {

    return false;
  }
}