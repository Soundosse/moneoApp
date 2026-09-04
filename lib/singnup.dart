import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/auth_service.dart';

import 'dashboardPage.dart';

// ============================================================
// SIGN UP SCREEN
// ============================================================

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SIGN UP WITH EMAIL
  // ==========================================================

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();

    // IMPORTANT:
    // Do not use trim() on the password.
    final password = _passwordController.text;

    final studentId = _studentIdController.text.trim();

    setState(() {
      _isLoading = true;
    });

    User? createdUser;

    try {
      // ======================================================
      // CREATE ACCOUNT IN FIREBASE AUTHENTICATION
      // ======================================================

      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      createdUser = userCredential.user;

      if (createdUser == null) {
        throw Exception(
          'Unable to retrieve the created account.',
        );
      }

      // ======================================================
      // USE FIREBASE AUTHENTICATION UID
      // ======================================================

      final String userId = createdUser.uid;

      // ======================================================
      // USER NAME
      // ======================================================

      String name;

      if (studentId.isNotEmpty) {
        name = studentId;
      } else {
        name = email.split('@').first;
      }

      // ======================================================
      // CREATE FIRESTORE DOCUMENT
      // ======================================================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
        'userId': userId,
        'studentId': studentId,
        'name': name,
        'email': email,
        'currency': 'MAD',
        'createdAt': FieldValue.serverTimestamp(),
        'photoUrl': '',
        'provider': 'email',
      });

      // ======================================================
      // DEBUG
      // ======================================================

      debugPrint(
        '========================================',
      );

      debugPrint(
        '✅ SIGN UP SUCCESSFUL',
      );

      debugPrint(
        'Email: $email',
      );

      debugPrint(
        'UID: $userId',
      );

      debugPrint(
        '========================================',
      );

      if (!mounted) return;

      // ======================================================
      // SIGN UP SUCCESSFUL
      // ======================================================

      _showMessage(
        'Sign-up successful!',
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
            (route) => false,
      );
    }

    // ========================================================
    // FIREBASE AUTHENTICATION ERRORS
    // ========================================================

    on FirebaseAuthException catch (e) {
      if (!mounted) return;

      debugPrint(
        '========================================',
      );

      debugPrint(
        '❌ FIREBASE AUTH ERROR',
      );

      debugPrint(
        'Code: ${e.code}',
      );

      debugPrint(
        'Message: ${e.message}',
      );

      debugPrint(
        '========================================',
      );

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already in use.';
          break;

        case 'invalid-email':
          message = 'Invalid email address.';
          break;

        case 'weak-password':
          message = 'The password is too weak.';
          break;

        case 'operation-not-allowed':
          message =
          'Email/password sign-in is not enabled in Firebase.';
          break;

        case 'network-request-failed':
          message =
          'Internet connection problem.';
          break;

        default:
          message =
              e.message ??
                  'Error creating the account.';
      }

      _showMessage(
        message,
      );
    }

    // ========================================================
    // OTHER ERRORS
    // ========================================================

    catch (e) {
      debugPrint(
        'Sign-up error: $e',
      );

      // ======================================================
      // IF AUTHENTICATION WAS CREATED BUT FIRESTORE FAILED
      // DELETE THE AUTHENTICATION ACCOUNT
      // ======================================================

      if (createdUser != null) {
        try {
          await createdUser.delete();

          debugPrint(
            'Firebase Auth account deleted after Firestore error.',
          );
        } catch (deleteError) {
          debugPrint(
            'Unable to delete Auth account: $deleteError',
          );
        }
      }

      if (!mounted) return;

      _showMessage(
        'Error during sign-up.',
      );
    }

    // ========================================================
    // FINISH LOADING
    // ========================================================

    finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ==========================================================
  // SIGN UP WITH GOOGLE
  // ==========================================================

  Future<void> _signUpWithGoogle() async {
    if (_isGoogleLoading) {
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      // ======================================================
      // GOOGLE SIGN IN
      // ======================================================

      final UserCredential? userCredential =
      await _authService.signInWithGoogle();

      if (!mounted) return;

      // ======================================================
      // CHECK RESULT
      // ======================================================

      if (userCredential == null) {
        _showMessage(
          'Google sign-in was canceled or failed.',
        );

        return;
      }

      final User? user = userCredential.user;

      if (user == null) {
        _showMessage(
          'Unable to retrieve the Google account.',
        );

        return;
      }

      // ======================================================
      // CHECK FIRESTORE PROFILE
      // ======================================================

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final userDoc = await userRef.get();

      // ======================================================
      // IF PROFILE DOES NOT EXIST
      // ======================================================

      if (!userDoc.exists) {
        await userRef.set({
          'userId': user.uid,
          'studentId': '',
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'password': '',
          'currency': 'MAD',
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': user.photoURL ?? '',
          'provider': 'google',
        });

        debugPrint(
          '✅ New Google account created in Firestore',
        );
      } else {
        debugPrint(
          '✅ Google account already exists in Firestore',
        );
      }

      if (!mounted) return;

      // ======================================================
      // MESSAGE
      // ======================================================

      _showMessage(
        'Google sign-in successful!',
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      // ======================================================
      // GO TO DASHBOARD
      // ======================================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      debugPrint(
        'Firebase Google error: ${e.code}',
      );

      _showMessage(
        'Google error: ${e.message ?? e.code}',
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'Google error: $e',
      );

      _showMessage(
        'Error during Google sign-up.',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isGoogleLoading = false;
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
              left: MediaQuery.of(context).size.width / 2 - 170,
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLogo(),
              _buildTitle(),
              _buildSubtitle(),

              const SizedBox(height: 20),

              _buildEmailField(),

              const SizedBox(height: 14),

              _buildPasswordField(),

              const SizedBox(height: 14),

              _buildConfirmPasswordField(),

              const SizedBox(height: 20),

              _buildSignUpButton(),

              const SizedBox(height: 20),

              _buildDivider(),

              const SizedBox(height: 16),

              _buildSocialButtons(),

              const SizedBox(height: 20),

              _buildLoginLink(),
            ],
          ),
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
          'Create an account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
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
    return const Text(
      'Join Moneo and manage your student finances',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Color(0xFFA09CA6),
        height: 1.4,
      ),
    );
  }

  // ==========================================================
  // STUDENT ID FIELD
  // ==========================================================

  Widget _buildStudentIdField() {
    return _buildTextField(
      controller: _studentIdController,
      icon: Icons.school_outlined,
      hintText: 'Student ID (optional)',
      keyboardType: TextInputType.text,
      validator: (value) => null,
    );
  }

  // ==========================================================
  // EMAIL FIELD
  // ==========================================================

  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      icon: Icons.mail_outline_rounded,
      hintText: 'Email',
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email';
        }

        if (!RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(value.trim())) {
          return 'Invalid email';
        }

        return null;
      },
    );
  }

  // ==========================================================
  // PASSWORD FIELD
  // ==========================================================

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _passwordController,
      icon: Icons.lock_outline_rounded,
      hintText: 'Password',
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: const Color(0xFF45414C),
          size: 23,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }

        if (value.length < 6) {
          return 'At least 6 characters';
        }

        return null;
      },
    );
  }

  // ==========================================================
  // CONFIRM PASSWORD FIELD
  // ==========================================================

  Widget _buildConfirmPasswordField() {
    return _buildTextField(
      controller: _confirmPasswordController,
      icon: Icons.lock_outline_rounded,
      hintText: 'Confirm password',
      obscureText: _obscureConfirmPassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: const Color(0xFF45414C),
          size: 23,
        ),
        onPressed: () {
          setState(() {
            _obscureConfirmPassword =
            !_obscureConfirmPassword;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }

        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }

        return null;
      },
    );
  }

  // ==========================================================
  // GENERIC TEXT FIELD BUILDER
  // ==========================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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
      child: TextFormField(
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
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 21,
          ),
        ),
        validator: validator,
      ),
    );
  }

  // ==========================================================
  // SIGN UP BUTTON
  // ==========================================================

  Widget _buildSignUpButton() {
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
          onPressed: (_isLoading || _isGoogleLoading)
              ? null
              : _signUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: Colors.white,
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
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : const Text(
            'Sign Up',
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
    return Row(
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
    );
  }

  // ==========================================================
  // SOCIAL BUTTONS
  // ==========================================================

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            icon: Icons.g_mobiledata_rounded,
            label: 'Google',
            color: const Color(0xFFE2E2E2),
            onPressed: _isGoogleLoading
                ? null
                : _signUpWithGoogle,
            isLoading: _isGoogleLoading,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _SocialButton(
            icon: Icons.apple,
            label: 'Apple',
            color: const Color(0xFFE2E2E2),
            onPressed: () {
              _showMessage(
                'Apple sign-up coming soon.',
              );
            },
          ),
        ),

        const SizedBox(width: 10),
      ],
    );
  }

  // ==========================================================
  // LOGIN LINK
  // ==========================================================

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(
              left: 5,
            ),
          ),
          child: const Text(
            'Log In',
            style: TextStyle(
              color: Color(0xFF7D3F96),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
  final bool isLoading;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.label,
    this.onPressed,
    this.isLoading = false,
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
        child: isLoading
            ? const SizedBox(
          width: 23,
          height: 23,
          child: CircularProgressIndicator(
            color: Color(0xFFE2E2E2),
            strokeWidth: 2.3,
          ),
        )
            : Column(
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