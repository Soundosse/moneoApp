import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';

import 'singnup.dart';
import 'dashboardPage.dart';

// ============================================================
// MAIN
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

}

// ============================================================
// APP
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moneo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF050507),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF315A72),
          secondary: Color(0xFF684080),
          surface: Color(0xFF09090C),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  // 👁️ Password visible / caché
  bool _obscurePassword = true;

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  // ==========================================================
  // FORGOT PASSWORD
  // ==========================================================

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        'Veuillez entrer votre email.',
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      _showMessage(
        'Un email de réinitialisation a été envoyé.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      debugPrint(
        'Erreur Forgot Password : ${e.code}',
      );

      if (e.code == 'invalid-email') {
        _showMessage(
          'Email invalide.',
        );
      } else if (e.code == 'user-not-found') {
        _showMessage(
          'Aucun compte trouvé avec cet email.',
        );
      } else {
        _showMessage(
          'Erreur lors de la réinitialisation du mot de passe.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'Erreur Forgot Password : $e',
      );

      _showMessage(
        'Erreur lors de la réinitialisation du mot de passe.',
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // FIREBASE AUTH EMAIL / PASSWORD LOGIN
  // ==========================================================

  Future<void> _loginWithEmailPassword() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Vérification des champs
    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Veuillez remplir tous les champs.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ======================================================
      // CONNEXION AVEC FIREBASE AUTHENTICATION
      // ======================================================

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        _showMessage(
          'Connexion échouée.',
        );
        return;
      }

      // ======================================================
      // RÉCUPÉRATION DU PROFIL FIRESTORE
      // ======================================================

      String name = '';
      String userId = user.uid;
      String currency = 'MAD';

      final query = await FirebaseFirestore.instance
          .collection('users')
          .where(
        'email',
        isEqualTo: email,
      )
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final userData = query.docs.first.data();

        name = userData['name'] ?? '';
        userId = userData['userId'] ?? user.uid;
        currency = userData['currency'] ?? 'MAD';
      }

      // ======================================================
      // AFFICHAGE CONSOLE
      // ======================================================

      debugPrint(
        'Utilisateur connecté : $name',
      );

      debugPrint(
        'User ID : $userId',
      );

      debugPrint(
        'Currency : $currency',
      );

      _showMessage(
        'Connexion réussie !',
      );

      // Petite attente pour afficher le message
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      // ====================================================
      // REDIRECTION VERS DASHBOARD
      // ====================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      debugPrint(
        'Erreur Firebase Auth : ${e.code}',
      );

      if (e.code == 'invalid-email') {
        _showMessage(
          'Email invalide.',
        );
      } else if (e.code == 'user-not-found') {
        _showMessage(
          'Aucun compte trouvé avec cet email.',
        );
      } else if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        _showMessage(
          'Email ou mot de passe incorrect.',
        );
      } else if (e.code == 'user-disabled') {
        _showMessage(
          'Ce compte a été désactivé.',
        );
      } else {
        _showMessage(
          'Erreur lors de la connexion.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'Erreur de connexion : $e',
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
      final result =
      await _authService.signInWithGoogle();

      if (!mounted) return;

      // ======================================================
      // CONNEXION GOOGLE RÉUSSIE
      // ======================================================

      if (result != null) {
        _showMessage(
          'Connexion avec Google réussie !',
        );

        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );
      }

      // ======================================================
      // CONNEXION GOOGLE ÉCHOUÉE
      // ======================================================

      else {
        _showMessage(
          'Connexion échouée.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'Erreur Google : $e',
      );

      _showMessage(
        'Connexion échouée.',
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildBackground(),
          _buildBottomWave(),
          _buildBorder(),
          _buildContent(),
        ],
      ),
    );
  }

  // ==========================================================
  // BACKGROUND
  // ==========================================================

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF050507),
        child: Stack(
          children: [
            Positioned(
              top: 250,
              left:
              MediaQuery.of(context).size.width / 2 - 170,
              child: IgnorePointer(
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF32105E)
                            .withOpacity(0.055),
                        blurRadius: 130,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BOTTOM WAVE
  // ==========================================================

  Widget _buildBottomWave() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 210,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.72,
          child: Image.asset(
            'assets/moneo_bottom_wave.png',
            width: double.infinity,
            height: 210,
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BORDER
  // ==========================================================

  Widget _buildBorder() {
    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(42),
          border: Border.all(
            color: const Color(0xFF17151D),
            width: 1,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CONTENT
  // ==========================================================

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 12,
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
  }

  // ==========================================================
  // LOGO
  // ==========================================================

  Widget _buildLogo() {
    return Column(
      children: [
        const SizedBox(height: 4),
        SizedBox(
          width: 100,
          height: 90,
          child: Image.asset(
            'assets/moneo_logo.png',
            fit: BoxFit.contain,
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
        SizedBox(height: 2),
        Text(
          'Moneo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF4F3F6),
            letterSpacing: -1,
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
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFA09CA6),
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: 'Your ',
              ),
              TextSpan(
                text: 'AI',
                style: TextStyle(
                  color: Color(0xFF187FA8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' financial assistant\nfor ',
              ),
              TextSpan(
                text: 'student life.',
                style: TextStyle(
                  color: Color(0xFF78418F),
                  fontWeight: FontWeight.w500,
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
        SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _FeatureItem(
              icon: Icons.shield_outlined,
              title: 'Secure',
            ),
            _FeatureItem(
              icon: Icons.bolt_outlined,
              title: 'Smart',
            ),
            _FeatureItem(
              icon: Icons.bar_chart_rounded,
              title: 'Insightful',
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
        const SizedBox(height: 28),

        // EMAIL
        _LoginTextField(
          controller: _emailController,
          icon: Icons.mail_outline_rounded,
          hintText: 'Email or student ID',
          suffixIcon: null,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 14),

        // PASSWORD
        _LoginTextField(
          controller: _passwordController,
          icon: Icons.lock_outline_rounded,
          hintText: 'Password',
          suffixIcon: Icons.visibility_outlined,
          obscureText: _obscurePassword,
          onSuffixIconPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 2,
              ),
            ),
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                color: Color(0xFF704B88),
                fontSize: 14,
              ),
            ),
          ),
        ),

        const SizedBox(height: 5),

        _buildSignInButton(),
      ],
    );
  }

  // ==========================================================
  // SIGN IN BUTTON
  // ==========================================================

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF00CFFF),
              Color(0xFF4169FF),
              Color(0xFF7B2CFF),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : _loginWithEmailPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
              : const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
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
        const SizedBox(height: 25),
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: Color(0xFF211F26),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              child: Text(
                'or continue with',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
            const Expanded(
              child: Divider(
                color: Color(0xFF211F26),
                thickness: 1,
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
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          // GOOGLE
          Expanded(
            child: _SocialButton(
              icon: Icons.g_mobiledata_rounded,
              label: 'Google',
              color: const Color(0xFFE2E2E2),
              onPressed:
              _isLoading ? null : _loginWithGoogle,
            ),
          ),

          const SizedBox(width: 10),

          // APPLE
          Expanded(
            child: _SocialButton(
              icon: Icons.apple,
              label: 'Apple',
              color: const Color(0xFFE2E2E2),
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
      padding: const EdgeInsets.only(
        top: 22,
        bottom: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(
                left: 5,
              ),
            ),
            child: const Text(
              'Sign up',
              style: TextStyle(
                color: Color(0xFF7D3F96),
                fontSize: 14,
                fontWeight: FontWeight.w600,
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

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF08080B),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF1E1A29),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF584285),
            size: 27,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFA7A3AC),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// LOGIN TEXT FIELD
// ============================================================

class _LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final IconData? suffixIcon;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;

  final VoidCallback? onSuffixIconPressed;

  const _LoginTextField({
    required this.controller,
    required this.icon,
    required this.suffixIcon,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.onSuffixIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF08080B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF211D2B),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFFE7E5E9),
          fontSize: 15,
        ),
        cursorColor: const Color(0xFF68417D),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF64616A),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF594181),
            size: 25,
          ),
          suffixIcon: suffixIcon == null
              ? null
              : IconButton(
            onPressed: onSuffixIconPressed,
            icon: Icon(
              obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF45414C),
              size: 23,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 21,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SOCIAL BUTTON
// ============================================================

class _SocialButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF08080B),
          foregroundColor: const Color(0xFFE5E3E7),
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 7,
          ),
          side: const BorderSide(
            color: Color(0xFF211D2B),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFAAA6B0),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}