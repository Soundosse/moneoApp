import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// ============================================================
// SIGN UP STATE
// ============================================================

class _SignUpScreenState extends State<SignUpScreen>
with WidgetsBindingObserver {
// ==========================================================
// FORM
// ==========================================================

final GlobalKey<FormState> _formKey =
GlobalKey<FormState>();

// ==========================================================
// CONTROLLERS
// ==========================================================

final TextEditingController _displayNameController =
TextEditingController();

final TextEditingController _emailController =
TextEditingController();

final TextEditingController _passwordController =
TextEditingController();

final TextEditingController _confirmPasswordController =
TextEditingController();

// ==========================================================
// SERVICES
// ==========================================================

final AuthService _authService = AuthService();

// ==========================================================
// STATES
// ==========================================================

bool _isLoading = false;
bool _isGoogleLoading = false;

bool _obscurePassword = true;
bool _obscureConfirmPassword = true;

// ==========================================================
// INIT
// ==========================================================

@override
void initState() {
super.initState();

WidgetsBinding.instance.addObserver(this);

_hideSystemNavigation();
}

// ==========================================================
// SYSTEM NAVIGATION
// ==========================================================

void _hideSystemNavigation() {
SystemChrome.setEnabledSystemUIMode(
SystemUiMode.immersiveSticky,
);

SystemChrome.setSystemUIOverlayStyle(
const SystemUiOverlayStyle(
statusBarColor: Colors.transparent,
statusBarIconBrightness: Brightness.light,
statusBarBrightness: Brightness.dark,
systemNavigationBarColor: Color(0xFF050507),
systemNavigationBarIconBrightness: Brightness.light,
systemNavigationBarDividerColor: Color(0xFF050507),
),
);
}

// ==========================================================
// LIFECYCLE
// ==========================================================

@override
void didChangeAppLifecycleState(
AppLifecycleState state) {
if (state == AppLifecycleState.resumed) {
_hideSystemNavigation();
}
}

// ==========================================================
// DISPOSE
// ==========================================================

@override
void dispose() {
WidgetsBinding.instance.removeObserver(this);

_displayNameController.dispose();
_emailController.dispose();
_passwordController.dispose();
_confirmPasswordController.dispose();

super.dispose();
}

// ==========================================================
// CREATE / UPDATE USER DOCUMENT
// ==========================================================
//
// IMPORTANT:
// For email/password users, this is called ONLY after
// email verification.
//
// The display name has already been saved to Firebase Auth
// during the sign-up process.
// ==========================================================

Future<void> _createUserDocument({
required User user,
String? displayName,
String? photoUrl,
required String provider,
}) async {
// --------------------------------------------------------
// SECURITY CHECK
// --------------------------------------------------------

if (provider == 'email' && !user.emailVerified) {
debugPrint(
'FIRESTORE BLOCKED: email is not verified.',
);

return;
}

final DocumentReference<Map<String, dynamic>> userRef =
FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid);

final DocumentSnapshot<Map<String, dynamic>> userDoc =
await userRef.get();

final Map<String, dynamic> existingData =
userDoc.data() ?? <String, dynamic>{};

// ========================================================
// DISPLAY NAME
// ========================================================

final String finalDisplayName =
(displayName ?? user.displayName ?? '').trim();

// ========================================================
// PHOTO
// ========================================================

final String finalPhotoUrl =
(photoUrl ?? user.photoURL ?? '').trim();

// ========================================================
// EMAIL VERIFIED
// ========================================================

final bool emailVerified = user.emailVerified;

// ========================================================
// EXISTING USER
// ========================================================

if (userDoc.exists) {
await userRef.set(
{
'displayName': finalDisplayName,
'email': user.email ?? '',
'photoUrl':
finalPhotoUrl.isEmpty ? null : finalPhotoUrl,
'currency': existingData['currency'] ?? 'MAD',
'country': existingData['country'] ?? 'MA',
'onboardingCompleted':
existingData['onboardingCompleted'] ?? false,
'profileCompleted':
existingData['profileCompleted'] ?? true,
'emailVerified': emailVerified,
'provider': provider,
'preferences':
existingData['preferences'] ??
{
'language': 'fr',
'notificationsEnabled': true,
'darkMode': false,
},
'updatedAt': FieldValue.serverTimestamp(),
'name': FieldValue.delete(),
},
SetOptions(merge: true),
);

debugPrint('==========================================');
debugPrint('USER DOCUMENT UPDATED');
debugPrint('UID : ${user.uid}');
debugPrint('EMAIL : ${user.email}');
debugPrint('DISPLAY NAME : $finalDisplayName');
debugPrint('PROVIDER : $provider');
debugPrint('EMAIL VERIFIED : $emailVerified');
debugPrint('==========================================');

return;
}

// ========================================================
// NEW USER
// ========================================================

await userRef.set(
{
'displayName': finalDisplayName,
'email': user.email ?? '',
'photoUrl':
finalPhotoUrl.isEmpty ? null : finalPhotoUrl,
'currency': 'MAD',
'country': 'MA',
'onboardingCompleted': false,
'profileCompleted': true,
'emailVerified': emailVerified,
'provider': provider,
'preferences': {
'language': 'fr',
'notificationsEnabled': true,
'darkMode': false,
},
'createdAt': FieldValue.serverTimestamp(),
'updatedAt': FieldValue.serverTimestamp(),
},
);

debugPrint('==========================================');
debugPrint('USER DOCUMENT CREATED');
debugPrint('UID : ${user.uid}');
debugPrint('DISPLAY NAME : $finalDisplayName');
debugPrint('EMAIL : ${user.email}');
debugPrint('PROVIDER : $provider');
debugPrint('EMAIL VERIFIED : $emailVerified');
debugPrint('==========================================');
}

// ==========================================================
// SIGN UP WITH EMAIL + PASSWORD
// ==========================================================

Future<void> _signUp() async {
if (_isLoading || _isGoogleLoading) {
return;
}

// ========================================================
// VALIDATE FORM
// ========================================================

if (!_formKey.currentState!.validate()) {
return;
}

// ========================================================
// DISPLAY NAME
// ========================================================

final String displayName =
_displayNameController.text.trim();

// ========================================================
// EMAIL
// ========================================================

final String email =
_emailController.text.trim();

// ========================================================
// PASSWORD
//
// IMPORTANT:
// Do NOT trim password.
// ========================================================

final String password =
_passwordController.text;

setState(() {
_isLoading = true;
});

try {
// ======================================================
// CREATE FIREBASE AUTH ACCOUNT
// ======================================================

final UserCredential userCredential =
await FirebaseAuth.instance
    .createUserWithEmailAndPassword(
email: email,
password: password,
);

final User? createdUser =
userCredential.user;

if (createdUser == null) {
throw Exception(
'Unable to retrieve the created account.',
);
}

// ======================================================
// SAVE DISPLAY NAME TO FIREBASE AUTH
// ======================================================

await createdUser.updateDisplayName(
displayName,
);

debugPrint('==========================================');
debugPrint('FIREBASE AUTH ACCOUNT CREATED');
debugPrint('EMAIL : $email');
debugPrint('UID : ${createdUser.uid}');
debugPrint('DISPLAY NAME : $displayName');
debugPrint('==========================================');

// ======================================================
// SEND VERIFICATION EMAIL
// ======================================================

await createdUser.sendEmailVerification();

debugPrint('==========================================');
debugPrint('VERIFICATION EMAIL SENT');
debugPrint('EMAIL : $email');
debugPrint('UID : ${createdUser.uid}');
debugPrint('==========================================');

if (!mounted) {
return;
}

// ======================================================
// OPEN EMAIL VERIFICATION SCREEN
// ======================================================

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) =>
EmailVerificationScreen(
email: email,
),
),
);
}

// ========================================================
// FIREBASE AUTH ERRORS
// ========================================================

on FirebaseAuthException catch (e) {
if (!mounted) {
return;
}

debugPrint(
'Firebase Auth Error : ${e.code}',
);

String message;

switch (e.code) {
case 'email-already-in-use':
message =
'This email is already registered.';
break;

case 'invalid-email':
message =
'Please enter a valid email address.';
break;

case 'weak-password':
message =
'Password must contain at least 6 characters.';
break;

case 'operation-not-allowed':
message =
'Email/password authentication is not enabled in Firebase.';
break;

case 'network-request-failed':
message =
'Please check your internet connection.';
break;

case 'too-many-requests':
message =
'Too many attempts. Please try again later.';
break;

default:
message =
e.message ??
'Error creating the account.';
}

_showMessage(message);
}

// ========================================================
// OTHER ERRORS
// ========================================================

catch (e, stackTrace) {
debugPrint(
'Sign Up Error : $e',
);

debugPrintStack(
stackTrace: stackTrace,
);

if (!mounted) {
return;
}

_showMessage(
'Something went wrong. Please try again.',
);
}

// ========================================================
// FINISH
// ========================================================

finally {
if (!mounted) {
return;
}

setState(() {
_isLoading = false;
});
}
}

// ==========================================================
// GOOGLE SIGN UP
// ==========================================================

Future<void> _signUpWithGoogle() async {
if (_isGoogleLoading || _isLoading) {
return;
}

setState(() {
_isGoogleLoading = true;
});

try {
final UserCredential? result =
await _authService.signInWithGoogle();

if (!mounted) {
return;
}

if (result == null) {
_showMessage(
'Google sign-up was canceled.',
);

return;
}

final User? user = result.user;

if (user == null) {
_showMessage(
'Unable to retrieve the Google account.',
);

return;
}

debugPrint('==========================================');
debugPrint(
'GOOGLE AUTHENTICATION SUCCESSFUL',
);
debugPrint('UID : ${user.uid}');
debugPrint('EMAIL : ${user.email}');
debugPrint(
'DISPLAY NAME : ${user.displayName}',
);
debugPrint(
'EMAIL VERIFIED : ${user.emailVerified}',
);
debugPrint('==========================================');

// ======================================================
// GOOGLE USER DOCUMENT
// ======================================================

await _createUserDocument(
user: user,
displayName: user.displayName,
photoUrl: user.photoURL,
provider: 'google',
);

if (!mounted) {
return;
}

_showMessage(
'Google sign-up successful!',
);

await Future.delayed(
const Duration(milliseconds: 500),
);

if (!mounted) {
return;
}

Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (context) =>
const DashboardPage(),
),
(route) => false,
);
}

// ========================================================
// FIREBASE ERROR
// ========================================================

on FirebaseAuthException catch (e) {
if (!mounted) {
return;
}

debugPrint(
'Google Firebase Error : ${e.code}',
);

_showMessage(
e.message ??
'Google authentication failed.',
);
}

// ========================================================
// OTHER ERROR
// ========================================================

catch (e, stackTrace) {
debugPrint(
'Google Sign Up Error : $e',
);

debugPrintStack(
stackTrace: stackTrace,
);

if (!mounted) {
return;
}

_showMessage(
'Error during Google sign-up.',
);
}

// ========================================================
// FINISH
// ========================================================

finally {
if (!mounted) {
return;
}

setState(() {
_isGoogleLoading = false;
});
}
}

// ==========================================================
// MESSAGE
// ==========================================================

void _showMessage(String message) {
if (!mounted) {
return;
}

ScaffoldMessenger.of(context)
    .hideCurrentSnackBar();

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
),
);
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
const Color(0xFF050507),

resizeToAvoidBottomInset: false,

body: Stack(
children: [
// ==================================================
// BACKGROUND
// ==================================================

Positioned.fill(
child: _buildBackground(),
),

// ==================================================
// FIXED WAVE
// ==================================================

Positioned(
left: 0,
right: 0,
bottom: 0,
height: 155,
child: IgnorePointer(
child: CustomPaint(
painter: _MoneoWavePainter(),
),
),
),

// ==================================================
// CONTENT
// ==================================================

Positioned.fill(
child: _buildContent(),
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
color: const Color(0xFF050507),
child: Stack(
children: [
Positioned(
top: 220,
left:
MediaQuery.of(context).size.width / 2 -
160,
child: IgnorePointer(
child: Container(
width: 320,
height: 320,
decoration: BoxDecoration(
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color:
const Color(0xFF32105E)
    .withOpacity(0.035),
blurRadius: 120,
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
builder: (context, constraints) {
return SingleChildScrollView(
physics:
const BouncingScrollPhysics(),

keyboardDismissBehavior:
ScrollViewKeyboardDismissBehavior.onDrag,

padding: const EdgeInsets.fromLTRB(
28,
20,
28,
215,
),

child: ConstrainedBox(
constraints: BoxConstraints(
minHeight:
constraints.maxHeight - 20,
),

child: Form(
key: _formKey,

child: Column(
children: [
_buildLogo(),
_buildTitle(),
_buildSubtitle(),
_buildSignUpForm(),
_buildDivider(),
_buildSocialButtons(),
_buildLogin(),
],
),
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
const SizedBox(height: 4),

SizedBox(
width: 92,
height: 82,
child: Image.asset(
'assets/images/foreground.png',
fit: BoxFit.contain,
errorBuilder:
(context, error, stackTrace) {
return const Icon(
Icons.account_balance_wallet_rounded,
size: 58,
color: Color(0xFF6B5BFF),
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
SizedBox(height: 2),

Text(
'Create an account',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 32,
fontWeight: FontWeight.w700,
color: Color(0xFFF4F3F6),
letterSpacing: -0.8,
),
),
],
);
}

// ==========================================================
// SUBTITLE
// ==========================================================

Widget _buildSubtitle() {
return const Column(
children: [
SizedBox(height: 8),

Text(
'Join Moneo and manage your student finances.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 14.5,
color: Color(0xFFA09CA6),
height: 1.4,
),
),
],
);
}

// ==========================================================
// SIGN UP FORM
// ==========================================================

Widget _buildSignUpForm() {
return Column(
children: [
// ====================================================
// DISPLAY NAME
// ====================================================

const SizedBox(height: 28),

_SignUpTextField(
controller: _displayNameController,
icon: Icons.person_outline_rounded,
hintText: 'Full Name',
textInputAction:
TextInputAction.next,
textCapitalization:
TextCapitalization.words,
validator: (value) {
if (value == null ||
value.trim().isEmpty) {
return 'Please enter your name';
}

if (value.trim().length < 2) {
return 'Name must contain at least 2 characters';
}

return null;
},
),

// ====================================================
// EMAIL
// ====================================================

const SizedBox(height: 14),

_SignUpTextField(
controller: _emailController,
icon: Icons.mail_outline_rounded,
hintText: 'Email',
keyboardType:
TextInputType.emailAddress,
textInputAction:
TextInputAction.next,
validator: (value) {
if (value == null ||
value.trim().isEmpty) {
return 'Please enter your email';
}

if (!RegExp(
r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$',
).hasMatch(
value.trim(),
)) {
return 'Invalid email';
}

return null;
},
),

// ====================================================
// PASSWORD
// ====================================================

const SizedBox(height: 14),

_SignUpTextField(
controller: _passwordController,
icon: Icons.lock_outline_rounded,
hintText: 'Password',
obscureText:
_obscurePassword,
textInputAction:
TextInputAction.next,
suffixIcon:
Icons.visibility_outlined,
onSuffixIconPressed: () {
setState(() {
_obscurePassword =
!_obscurePassword;
});
},
validator: (value) {
if (value == null ||
value.isEmpty) {
return 'Please enter a password';
}

if (value.length < 6) {
return 'At least 6 characters';
}

return null;
},
),

// ====================================================
// CONFIRM PASSWORD
// ====================================================

const SizedBox(height: 14),

_SignUpTextField(
controller:
_confirmPasswordController,
icon: Icons.lock_outline_rounded,
hintText: 'Confirm password',
obscureText:
_obscureConfirmPassword,
textInputAction:
TextInputAction.done,
suffixIcon:
Icons.visibility_outlined,
onSuffixIconPressed: () {
setState(() {
_obscureConfirmPassword =
!_obscureConfirmPassword;
});
},
onSubmitted: (_) {
if (!_isLoading &&
!_isGoogleLoading) {
_signUp();
}
},
validator: (value) {
if (value == null ||
value.isEmpty) {
return 'Please confirm your password';
}

if (value !=
_passwordController.text) {
return 'Passwords do not match';
}

return null;
},
),

// ====================================================
// SIGN UP BUTTON
// ====================================================

const SizedBox(height: 20),

_buildSignUpButton(),
],
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
borderRadius:
BorderRadius.circular(17),

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

child: ElevatedButton(
onPressed:
(_isLoading ||
_isGoogleLoading)
? null
    : _signUp,

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
disabledForegroundColor:
Colors.white,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(17),
),
),

child: _isLoading
? const SizedBox(
width: 24,
height: 24,
child:
CircularProgressIndicator(
strokeWidth: 2.5,
color: Colors.white,
),
)
    : const Text(
'Sign Up',
style: TextStyle(
fontSize: 18,
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
padding:
const EdgeInsets.symmetric(
horizontal: 14,
),
child: Text(
'or continue with',
style: TextStyle(
color:
Colors.grey.shade600,
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
padding:
const EdgeInsets.only(top: 20),

child: Row(
children: [
Expanded(
child: _SocialButton(
icon:
Icons.g_mobiledata_rounded,
label: 'Google',
color:
const Color(0xFFE2E2E2),
onPressed:
(_isLoading ||
_isGoogleLoading)
? null
    : _signUpWithGoogle,
isLoading:
_isGoogleLoading,
),
),

const SizedBox(width: 10),

Expanded(
child: _SocialButton(
icon: Icons.apple,
label: 'Apple',
color:
const Color(0xFFE2E2E2),
onPressed:
(_isLoading ||
_isGoogleLoading)
? null
    : () {
_showMessage(
'Apple Sign-In coming soon.',
);
},
),
),
],
),
);
}

// ==========================================================
// LOGIN LINK
// ==========================================================

Widget _buildLogin() {
return Padding(
padding:
const EdgeInsets.only(
top: 22,
bottom: 12,
),

child: Row(
mainAxisAlignment:
MainAxisAlignment.center,

children: [
Text(
'Already have an account?',
style: TextStyle(
color:
Colors.grey.shade600,
fontSize: 14,
),
),

TextButton(
onPressed:
(_isLoading ||
_isGoogleLoading)
? null
    : () {
Navigator.pop(
context,
);
},

style:
TextButton.styleFrom(
padding:
const EdgeInsets.only(
left: 5,
),
minimumSize:
Size.zero,
tapTargetSize:
MaterialTapTargetSize
    .shrinkWrap,
),

child: const Text(
'Sign in',
style: TextStyle(
color:
Color(0xFF7D3F96),
fontSize: 14,
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
// SIGN UP TEXT FIELD
// ============================================================

class _SignUpTextField
extends StatelessWidget {
final TextEditingController controller;

final IconData icon;

final IconData? suffixIcon;

final String hintText;

final bool obscureText;

final TextInputType? keyboardType;

final TextInputAction? textInputAction;

final TextCapitalization
textCapitalization;

final VoidCallback?
onSuffixIconPressed;

final ValueChanged<String>?
onSubmitted;

final String? Function(String?)?
validator;

const _SignUpTextField({
required this.controller,
required this.icon,
this.suffixIcon,
required this.hintText,
this.obscureText = false,
this.keyboardType,
this.textInputAction,
this.textCapitalization =
TextCapitalization.none,
this.onSuffixIconPressed,
this.onSubmitted,
this.validator,
});

@override
Widget build(BuildContext context) {
return Container(
width: double.infinity,

decoration: BoxDecoration(
color:
const Color(0xFF08080B),

borderRadius:
BorderRadius.circular(18),

border: Border.all(
color:
const Color(0xFF211D2B),
width: 1,
),
),

child: TextFormField(
controller: controller,

obscureText:
obscureText,

keyboardType:
keyboardType,

textInputAction:
textInputAction,

textCapitalization:
textCapitalization,

onFieldSubmitted:
onSubmitted,

style: const TextStyle(
color:
Color(0xFFE7E5E9),
fontSize: 15,
),

cursorColor:
const Color(0xFF68417D),

validator:
validator,

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
fontSize: 15,
),

prefixIcon:
Icon(
icon,
color:
const Color(
0xFF594181),
size: 25,
),

suffixIcon:
suffixIcon == null
? null
    : IconButton(
onPressed:
onSuffixIconPressed,

icon: Icon(
obscureText
? Icons
    .visibility_outlined
    : Icons
    .visibility_off_outlined,

color:
const Color(
0xFF45414C),

size: 23,
),
),

contentPadding:
const EdgeInsets
    .symmetric(
vertical: 21,
),

errorStyle:
const TextStyle(
color:
Color(0xFFD97979),
fontSize: 11.5,
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
onPressed:
onPressed,

style:
OutlinedButton.styleFrom(
backgroundColor:
const Color(0xFF08080B),

foregroundColor:
const Color(0xFFE5E3E7),

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
BorderRadius.circular(16),
),
),

child: isLoading
? const SizedBox(
width: 22,
height: 22,

child:
CircularProgressIndicator(
color:
Color(0xFFE2E2E2),
strokeWidth: 2.2,
),
)

    : Column(
mainAxisAlignment:
MainAxisAlignment.center,

children: [
Icon(
icon,
color: color,
size: 24,
),

const SizedBox(
height: 3,
),

FittedBox(
fit:
BoxFit.scaleDown,

child: Text(
label,
style:
const TextStyle(
color:
Color(
0xFFAAA6B0),
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

bool _goingBack = false;

// ==========================================================
// PROTECTION AGAINST DOUBLE EXECUTION
// ==========================================================

bool _verificationCompleted =
false;

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
// SYSTEM UI
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

// ==========================================================
// LIFECYCLE
// ==========================================================

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

super.dispose();
}

// ==========================================================
// CHECK VERIFICATION
// ==========================================================

Future<void>
_checkVerification() async {
// --------------------------------------------------------
// PROTECTION
// --------------------------------------------------------

if (_checking ||
_verificationCompleted) {
return;
}

setState(() {
_checking = true;
});

try {
User? user =
FirebaseAuth.instance
    .currentUser;

// ======================================================
// USER NOT FOUND
// ======================================================

if (user == null) {
if (mounted) {
_showMessage(
'Your session has expired. Please log in again.',
);
}

return;
}

// ======================================================
// RELOAD FIREBASE USER
// ======================================================

await user.reload();

user =
FirebaseAuth.instance
    .currentUser;

if (user == null) {
if (mounted) {
_showMessage(
'Unable to retrieve your account.',
);
}

return;
}

// ======================================================
// NOT VERIFIED
// ======================================================

if (!user.emailVerified) {
if (mounted) {
_showMessage(
'Your email is not verified yet.',
);
}

return;
}

// ======================================================
// LOCK THE FLOW
// ======================================================

_verificationCompleted = true;

debugPrint(
'==========================================',
);

debugPrint(
'EMAIL VERIFIED SUCCESSFULLY',
);

debugPrint(
'EMAIL : ${user.email}',
);

debugPrint(
'UID : ${user.uid}',
);

debugPrint(
'DISPLAY NAME : ${user.displayName}',
);

debugPrint(
'CREATING FIRESTORE DOCUMENT...',
);

debugPrint(
'==========================================',
);

// ======================================================
// CREATE FIRESTORE PROFILE
// ======================================================

await _createVerifiedUserDocument(
user,
);

if (!mounted) {
return;
}

// ======================================================
// RELOAD USER
// ======================================================

await user.reload();

if (!mounted) {
return;
}

// ======================================================
// OPEN DASHBOARD
//
// NO DISPLAY NAME DIALOG ANYMORE.
// ======================================================

Navigator.pushAndRemoveUntil(
context,

MaterialPageRoute(
builder: (context) =>
const DashboardPage(),
),

(route) => false,
);
}

// ========================================================
// ERROR
// ========================================================

catch (e, stackTrace) {
debugPrint(
'==========================================',
);

debugPrint(
'VERIFICATION FLOW ERROR',
);

debugPrint('$e');

debugPrint(
'==========================================',
);

debugPrintStack(
stackTrace: stackTrace,
);

if (!mounted) {
return;
}

_verificationCompleted = false;

_showMessage(
'Unable to complete the verification process.',
);
}

// ========================================================
// FINISH
// ========================================================

finally {
if (!mounted) {
return;
}

setState(() {
_checking = false;
});
}
}

// ==========================================================
// CREATE VERIFIED USER DOCUMENT
// ==========================================================

Future<void>
_createVerifiedUserDocument(
User user) async {
// --------------------------------------------------------
// FINAL SAFETY CHECK
// --------------------------------------------------------

if (!user.emailVerified) {
debugPrint(
'BLOCKED: User email is not verified.',
);

return;
}

final DocumentReference<
Map<String, dynamic>> userRef =
FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid);

final DocumentSnapshot<
Map<String, dynamic>> snapshot =
await userRef.get();

final Map<String, dynamic>
existingData =
snapshot.data() ??
<String, dynamic>{};

// ========================================================
// DISPLAY NAME
// ========================================================

final String displayName =
(user.displayName ?? '').trim();

// ========================================================
// PREFERENCES
// ========================================================

final Map<String, dynamic>
preferences =
existingData['preferences']
is Map
? Map<String, dynamic>.from(
existingData[
'preferences'] as Map,
)
    : {
'language': 'fr',
'notificationsEnabled':
true,
'darkMode': false,
};

// ========================================================
// CREATE / UPDATE PROFILE
// ========================================================

await userRef.set(
{
'displayName':
displayName,

'email':
user.email ?? '',

'photoUrl':
user.photoURL ??
existingData[
'photoUrl'],

'currency':
existingData[
'currency'] ??
'MAD',

'country':
existingData[
'country'] ??
'MA',

'onboardingCompleted':
existingData[
'onboardingCompleted'] ??
false,

'profileCompleted':
true,

'emailVerified':
true,

'provider':
existingData[
'provider'] ??
'email',

'preferences':
preferences,

'updatedAt':
FieldValue
    .serverTimestamp(),
},

SetOptions(
merge: true,
),
);

debugPrint(
'==========================================',
);

debugPrint(
'FIRESTORE USER DOCUMENT CREATED/UPDATED',
);

debugPrint(
'UID : ${user.uid}',
);

debugPrint(
'EMAIL : ${user.email}',
);

debugPrint(
'DISPLAY NAME : $displayName',
);

debugPrint(
'EMAIL VERIFIED : true',
);

debugPrint(
'==========================================',
);
}

// ==========================================================
// RESEND VERIFICATION EMAIL
// ==========================================================

Future<void>
_resendVerificationEmail() async {
if (_resending ||
_checking ||
_verificationCompleted) {
return;
}

setState(() {
_resending = true;
});

try {
final User? user =
FirebaseAuth.instance
    .currentUser;

if (user == null) {
if (mounted) {
_showMessage(
'Your session has expired.',
);
}

return;
}

if (user.emailVerified) {
if (mounted) {
_showMessage(
'Your email is already verified.',
);
}

return;
}

await user.sendEmailVerification();

if (!mounted) {
return;
}

_showMessage(
'Verification email sent again.',
);
}

// ========================================================
// FIREBASE ERROR
// ========================================================

on FirebaseAuthException catch (e) {
if (!mounted) {
return;
}

if (e.code ==
'too-many-requests') {
_showMessage(
'Too many requests. Please wait before trying again.',
);
} else {
_showMessage(
e.message ??
'Unable to resend verification email.',
);
}
}

// ========================================================
// OTHER ERROR
// ========================================================

catch (e) {
debugPrint(
'Resend Verification Error : $e',
);

if (!mounted) {
return;
}

_showMessage(
'Unable to resend verification email.',
);
}

// ========================================================
// FINISH
// ========================================================

finally {
if (!mounted) {
return;
}

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
if (_goingBack ||
_checking) {
return;
}

setState(() {
_goingBack = true;
});

try {
final User? user =
FirebaseAuth.instance
    .currentUser;

if (user != null &&
!user.emailVerified) {
debugPrint(
'Deleting unverified Firebase account...',
);

try {
await user.delete();

debugPrint(
'Unverified Firebase account deleted.',
);
} on FirebaseAuthException catch (e) {
debugPrint(
'Unable to delete temporary account: ${e.code}',
);
}
}

await FirebaseAuth.instance
    .signOut();

if (!mounted) {
return;
}

Navigator.pop(context);
} catch (e) {
debugPrint(
'Back to Login Error : $e',
);

try {
await FirebaseAuth.instance
    .signOut();
} catch (_) {}

if (!mounted) {
return;
}

Navigator.pop(context);
} finally {
if (!mounted) {
return;
}

setState(() {
_goingBack = false;
});
}
}

// ==========================================================
// MESSAGE
// ==========================================================

void _showVerificationMessage(
String message) {
if (!mounted) {
return;
}

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

// Alias used by this screen.
void _showMessage(String message) {
_showVerificationMessage(
message,
);
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
const Color(0xFF050507),

resizeToAvoidBottomInset:
false,

body: Stack(
children: [
// ==================================================
// BACKGROUND
// ==================================================

Positioned.fill(
child:
_buildVerificationBackground(),
),

// ==================================================
// FIXED WAVE
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
_buildVerificationContent(),
),
],
),
);
}

// ==========================================================
// VERIFICATION BACKGROUND
// ==========================================================

Widget
_buildVerificationBackground() {
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
// VERIFICATION CONTENT
// ==========================================================

Widget
_buildVerificationContent() {
return LayoutBuilder(
builder:
(context, constraints) {
return SingleChildScrollView(
physics:
const BouncingScrollPhysics(),

padding:
const EdgeInsets.fromLTRB(
28,
30,
28,
210,
),

child: ConstrainedBox(
constraints:
BoxConstraints(
minHeight:
constraints.maxHeight -
30,
),

child: Column(
children: [
// ==========================================
// LOGO
// ==========================================

SizedBox(
width: 92,
height: 82,

child: Image.asset(
'assets/images/foreground.png',
fit:
BoxFit.contain,

errorBuilder:
(
context,
error,
stackTrace,
) {
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

// ==========================================
// TITLE
// ==========================================

const SizedBox(
height: 15,
),

const Text(
'Verify your email',
textAlign:
TextAlign.center,

style: TextStyle(
fontSize: 32,

fontWeight:
FontWeight.w700,

color:
Color(0xFFF4F3F6),

letterSpacing:
-0.8,
),
),

// ==========================================
// DESCRIPTION
// ==========================================

const SizedBox(
height: 14,
),

const Text(
'We sent a verification email to',
textAlign:
TextAlign.center,

style: TextStyle(
fontSize: 15,

color:
Color(0xFFA09CA6),

height: 1.4,
),
),

const SizedBox(
height: 8,
),

Text(
widget.email,

textAlign:
TextAlign.center,

style:
const TextStyle(
fontSize: 15,

fontWeight:
FontWeight.w600,

color:
Color(0xFF9B5CBB),
),
),

// ==========================================
// EMAIL ICON
// ==========================================

const SizedBox(
height: 28,
),

Container(
width: 74,
height: 74,

decoration:
BoxDecoration(
shape:
BoxShape.circle,

color:
const Color(
0xFF0B0A10),

border:
Border.all(
color:
const Color(
0xFF281B34,
),

width: 1,
),
),

child: const Icon(
Icons
    .mark_email_unread_outlined,

size: 34,

color:
Color(0xFF704B88),
),
),

// ==========================================
// CHECK BUTTON
// ==========================================

const SizedBox(
height: 30,
),

_gradientButton(
text:
'I verified my email',

loading:
_checking,

onPressed:
(_checking ||
_verificationCompleted)
? null
    : _checkVerification,
),

// ==========================================
// RESEND
// ==========================================

const SizedBox(
height: 14,
),

TextButton(
onPressed:
(_resending ||
_checking ||
_verificationCompleted)
? null
    : _resendVerificationEmail,

child:
_resending
? const SizedBox(
width: 20,
height: 20,

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

// ==========================================
// BACK TO LOGIN
// ==========================================

const SizedBox(
height: 8,
),

TextButton(
onPressed:
(_goingBack ||
_checking ||
_verificationCompleted)
? null
    : _backToLogin,

child:
_goingBack
? const SizedBox(
width: 18,
height: 18,

child:
CircularProgressIndicator(
strokeWidth:
2,

color:
Color(
0xFF77727D,
),
),
)
    : const Text(
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
);
},
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
width: double.infinity,
height: 52,

child: DecoratedBox(
decoration:
BoxDecoration(
borderRadius:
BorderRadius.circular(17),

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

child: ElevatedButton(
onPressed:
onPressed,

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

child: loading
? const SizedBox(
width: 23,
height: 23,

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
fontSize: 16,

fontWeight:
FontWeight.w500,
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
Size size,
) {
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
covariant CustomPainter oldDelegate,
) {
return false;
}
}
