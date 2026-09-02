import 'dart:async';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
const OnboardingPage({super.key});

@override
State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
with SingleTickerProviderStateMixin {

// ============================================================
// PAGE ACTUELLE
// ============================================================

int _currentPage = 0;

// ============================================================
// IMAGES DE L'ONBOARDING
// ============================================================

final List<String> _images = [
'assets/images/onboarding1.png',
'assets/images/onboarding2.png',
'assets/images/onboarding3.png',
'assets/images/onboarding4.png',
'assets/images/onboarding5.png',
'assets/images/onboarding6.png',
'assets/images/onboarding7.png',
];

// ============================================================
// ANIMATION DU BOUTON GET STARTED
// ============================================================

late AnimationController _buttonController;

late Animation<double> _buttonScale;
late Animation<double> _buttonOpacity;

Timer? _buttonTimer;

// ============================================================
// INITIALISATION
// ============================================================

@override
void initState() {
super.initState();

_buttonController = AnimationController(
vsync: this,

// Animation plus lente pour être bien visible
duration: const Duration(milliseconds: 1500),
);

// ------------------------------------------------------------
// SCALE : petit → grand
// ------------------------------------------------------------

_buttonScale = Tween<double>(
begin: 0.75,
end: 1.0,
).animate(
CurvedAnimation(
parent: _buttonController,
curve: Curves.easeOutBack,
),
);

// ------------------------------------------------------------
// OPACITY : transparent → visible
// ------------------------------------------------------------

_buttonOpacity = Tween<double>(
begin: 0.0,
end: 1.0,
).animate(
CurvedAnimation(
parent: _buttonController,
curve: Curves.easeOut,
),
);
}

// ============================================================
// LANCER L'ANIMATION DU BOUTON
// ============================================================

void _startButtonAnimation() {
_buttonTimer?.cancel();

// Remettre le bouton à son état initial
_buttonController.reset();

// Petite pause avant l'apparition
_buttonTimer = Timer(
const Duration(milliseconds: 700),
() {
if (!mounted) return;

if (_currentPage == _images.length - 1) {
_buttonController.forward();
}
},
);
}

// ============================================================
// PAGE SUIVANTE
// ============================================================

void _nextPage() {
if (_currentPage < _images.length - 1) {
setState(() {
_currentPage++;
});

// Si on arrive sur la dernière page
if (_currentPage == _images.length - 1) {
_startButtonAnimation();
}
} else {
// ========================================================
// GET STARTED
// ========================================================

// Ici tu peux mettre ta navigation vers Login.

// Exemple :
//
// Navigator.pushReplacement(
//   context,
//   MaterialPageRoute(
//     builder: (context) => const LoginScreen(),
//   ),
// );

debugPrint('Get Started pressed');
}
}

// ============================================================
// DISPOSE
// ============================================================

@override
void dispose() {
_buttonTimer?.cancel();
_buttonController.dispose();

super.dispose();
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
final bool isLastPage =
_currentPage == _images.length - 1;

return Scaffold(
backgroundColor: Colors.black,

// ==========================================================
// BODY
// ==========================================================

body: Stack(
fit: StackFit.expand,
children: [

// ======================================================
// IMAGE DE FOND
// ======================================================

AnimatedSwitcher(
duration: const Duration(milliseconds: 500),

switchInCurve: Curves.easeIn,
switchOutCurve: Curves.easeOut,

transitionBuilder: (
Widget child,
Animation<double> animation,
) {
return FadeTransition(
opacity: animation,
child: child,
);
},

child: SizedBox.expand(
key: ValueKey<String>(
_images[_currentPage],
),

child: Image.asset(
_images[_currentPage],

width: double.infinity,
height: double.infinity,

fit: BoxFit.cover,

filterQuality: FilterQuality.high,

// ==================================================
// SÉCURITÉ SI L'IMAGE N'EST PAS TROUVÉE
// ==================================================

errorBuilder: (
BuildContext context,
Object error,
StackTrace? stackTrace,
) {
debugPrint(
'Erreur image : ${_images[_currentPage]}',
);

return Container(
width: double.infinity,
height: double.infinity,

color: Colors.black,

alignment: Alignment.center,

child: Padding(
padding: const EdgeInsets.all(24),

child: Text(
'Image introuvable :\n'
'${_images[_currentPage]}',

textAlign: TextAlign.center,

style: const TextStyle(
color: Colors.white,
fontSize: 16,
),
),
),
);
},
),
),
),

// ======================================================
// CONTENU HAUT + INDICATEURS
// ======================================================

SafeArea(
child: Column(
children: [

// ==================================================
// BOUTON NEXT
// ==================================================

if (!isLastPage)
Align(
alignment: Alignment.topRight,

child: Padding(
padding: const EdgeInsets.only(
top: 15,
right: 20,
),

child: TextButton(
onPressed: _nextPage,

style: TextButton.styleFrom(
foregroundColor: Colors.white,

backgroundColor:
Colors.black.withOpacity(0.25),

padding:
const EdgeInsets.symmetric(
horizontal: 18,
vertical: 10,
),

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(25),
),
),

child: const Text(
'Next',

style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
),
),
),

const Spacer(),

// ==================================================
// INDICATEURS
// ==================================================

if (!isLastPage)
Padding(
padding: const EdgeInsets.only(
bottom: 35,
),

child: Row(
mainAxisAlignment:
MainAxisAlignment.center,

children: List.generate(
_images.length,
(index) {

final bool isActive =
index == _currentPage;

return AnimatedContainer(
duration:
const Duration(
milliseconds: 300,
),

curve: Curves.easeOut,

margin:
const EdgeInsets.symmetric(
horizontal: 4,
),

width: isActive ? 22 : 7,
height: 7,

decoration: BoxDecoration(
color: isActive
? const Color(
0xFF2D72F5,
)
    : Colors.white
    .withOpacity(0.30),

borderRadius:
BorderRadius.circular(10),
),
);
},
),
),
),
],
),
),

// ======================================================
// GET STARTED — DERNIÈRE PAGE
// ======================================================

if (isLastPage)
Positioned(
left: 0,
right: 0,

// Bouton légèrement plus bas
bottom:
MediaQuery.of(context).size.height * 0.12,

child: Center(
child: AnimatedBuilder(
animation: _buttonController,

builder: (
BuildContext context,
Widget? child,
) {
return Opacity(
opacity: _buttonOpacity.value,

child: Transform.scale(
scale: _buttonScale.value,

alignment: Alignment.center,

child: child,
),
);
},

// ==================================================
// BOUTON
// ==================================================

child: GestureDetector(
behavior:
HitTestBehavior.opaque,

onTap: _nextPage,

child: Container(
// Bouton plus petit
width: 350,
height: 62,

decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(32),

// ==================================================
// GRADIENT
// ==================================================

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

// ==================================================
// GLOW
// ==================================================

boxShadow: [
BoxShadow(
color:
const Color(0xFF4D4DFF)
    .withOpacity(0.45),

blurRadius: 25,

spreadRadius: 2,

offset:
const Offset(0, 7),
),
],
),

// ==================================================
// CONTENU DU BOUTON
// ==================================================

child: Row(
mainAxisAlignment:
MainAxisAlignment.center,

children: [

// ==================================================
// TEXTE
// ==================================================

const Text(
'Get Started',

style: TextStyle(
color: Colors.white,

fontSize: 18,

fontWeight:
FontWeight.w700,

letterSpacing: 0.2,
),
),

const SizedBox(
width: 14,
),

// ==================================================
// CERCLE + FLÈCHE
// ==================================================

Container(
width: 34,
height: 34,

decoration:
BoxDecoration(
color: Colors.white
    .withOpacity(0.18),

shape:
BoxShape.circle,
),

child: const Icon(
Icons
    .arrow_forward_rounded,

color: Colors.white,

size: 20,
),
),
],
),
),
),
),
),
),
],
),
);
}
}
