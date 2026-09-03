import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboardPage.dart';

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
// IMAGES
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
// ANIMATION GET STARTED
// ============================================================

late AnimationController _buttonController;

late Animation<double> _buttonScale;
late Animation<double> _buttonOpacity;

Timer? _buttonTimer;

// ============================================================
// SWIPE
// ============================================================

double _dragStartX = 0;

static const double _swipeThreshold = 60;

// ============================================================
// INIT
// ============================================================

@override
void initState() {
super.initState();

// ==========================================================
// CACHER UNIQUEMENT LA BARRE DE NAVIGATION ANDROID
// ==========================================================

SystemChrome.setEnabledSystemUIMode(
SystemUiMode.manual,
overlays: const [
SystemUiOverlay.top,
],
);

// ==========================================================
// ANIMATION
// ==========================================================

_buttonController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 1500),
);

// ----------------------------------------------------------
// SCALE
// ----------------------------------------------------------

_buttonScale = Tween<double>(
begin: 0.75,
end: 1.0,
).animate(
CurvedAnimation(
parent: _buttonController,
curve: Curves.easeOutBack,
),
);

// ----------------------------------------------------------
// OPACITY
// ----------------------------------------------------------

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
// GET STARTED ANIMATION
// ============================================================

void _startButtonAnimation() {
_buttonTimer?.cancel();

_buttonController.reset();

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
// NEXT
// ============================================================

void _nextPage() {
if (_currentPage >= _images.length - 1) {
return;
}

setState(() {
_currentPage++;
});

if (_currentPage == _images.length - 1) {
_startButtonAnimation();
}
}

// ============================================================
// PREVIOUS
// ============================================================

void _previousPage() {
if (_currentPage <= 0) {
return;
}

// Si on quitte la dernière page
if (_currentPage == _images.length - 1) {
_buttonTimer?.cancel();
_buttonController.reset();
}

setState(() {
_currentPage--;
});
}

// ============================================================
// SWIPE START
// ============================================================

void _handleDragStart(DragStartDetails details) {
_dragStartX = details.globalPosition.dx;
}

// ============================================================
// SWIPE END
// ============================================================

void _handleDragEnd(DragEndDetails details) {
final double dragEndX = details.globalPosition.dx;

final double difference = dragEndX - _dragStartX;

// ----------------------------------------------------------
// GAUCHE → NEXT
// ----------------------------------------------------------

if (difference < -_swipeThreshold) {
_nextPage();
}

// ----------------------------------------------------------
// DROITE → PREVIOUS
// ----------------------------------------------------------

else if (difference > _swipeThreshold) {
_previousPage();
}
}

// ============================================================
// DISPOSE
// ============================================================

@override
void dispose() {
_buttonTimer?.cancel();
_buttonController.dispose();

// Remettre la navigation Android normale
SystemChrome.setEnabledSystemUIMode(
SystemUiMode.edgeToEdge,
);

super.dispose();
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
final bool isFirstPage = _currentPage == 0;

final bool isLastPage =
_currentPage == _images.length - 1;

return Scaffold(
backgroundColor: Colors.black,

// ========================================================
// BODY
// ========================================================

body: GestureDetector(
behavior: HitTestBehavior.opaque,

onHorizontalDragStart:
_handleDragStart,

onHorizontalDragEnd:
_handleDragEnd,

child: Stack(
fit: StackFit.expand,

children: [

// ==================================================
// IMAGE DE FOND
// ==================================================

AnimatedSwitcher(
duration:
const Duration(milliseconds: 500),

switchInCurve:
Curves.easeIn,

switchOutCurve:
Curves.easeOut,

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

filterQuality:
FilterQuality.high,

errorBuilder: (
BuildContext context,
Object error,
StackTrace? stackTrace,
) {
debugPrint(
'Erreur image : '
'${_images[_currentPage]}',
);

return Container(
color: Colors.black,

alignment:
Alignment.center,

child: Padding(
padding:
const EdgeInsets.all(24),

child: Text(
'Image introuvable :\n'
'${_images[_currentPage]}',

textAlign:
TextAlign.center,

style:
const TextStyle(
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

// ==================================================
// HEADER
// ==================================================

Positioned(
top: 0,
left: 0,
right: 0,

child: SafeArea(
child: Padding(
padding:
const EdgeInsets.only(
left: 18,
right: 18,
top: 10,
),

child: Row(
mainAxisAlignment:
MainAxisAlignment
    .spaceBetween,

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

// ========================================
// PREVIOUS
// ========================================

if (!isFirstPage)
_buildPreviousButton()
else
const SizedBox(
width: 92,
height: 38,
),

// ========================================
// NEXT
// ========================================

if (!isLastPage)
_buildNextButton()
else
const SizedBox(
width: 65,
height: 38,
),
],
),
),
),
),

// ==================================================
// INDICATORS
// ==================================================

if (!isLastPage)
Positioned(
left: 0,
right: 0,
bottom: 35,

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

curve:
Curves.easeOut,

margin:
const EdgeInsets
    .symmetric(
horizontal: 4,
),

width:
isActive ? 22 : 7,

height: 7,

decoration:
BoxDecoration(
color: isActive
? const Color(
0xFF2D72F5,
)
    : Colors.white
    .withOpacity(
0.30,
),

borderRadius:
BorderRadius
    .circular(10),
),
);
},
),
),
),

// ==================================================
// GET STARTED
// ==================================================

if (isLastPage)
Positioned(
left: 0,
right: 0,

bottom:
MediaQuery.of(context)
    .size
    .height *
0.12,

child: Center(
child: AnimatedBuilder(
animation:
_buttonController,

builder: (
BuildContext context,
Widget? child,
) {
return Opacity(
opacity:
_buttonOpacity.value,

child:
Transform.scale(
scale:
_buttonScale.value,

alignment:
Alignment.center,

child: child,
),
);
},

child:
GestureDetector(
behavior:
HitTestBehavior.opaque,

onTap: () {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder:
(context) =>
const DashboardPage(),
),
);
},

child: Container(
width: 350,
height: 62,

decoration:
BoxDecoration(
borderRadius:
BorderRadius.circular(
32,
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

boxShadow: [
BoxShadow(
color:
const Color(
0xFF4D4DFF,
).withOpacity(
0.45,
),

blurRadius: 25,

spreadRadius: 2,

offset:
const Offset(
0,
7,
),
),
],
),

child: Row(
mainAxisAlignment:
MainAxisAlignment
    .center,

children: [

const Text(
'Get Started',

style:
TextStyle(
color:
Colors.white,

fontSize: 18,

fontWeight:
FontWeight.w700,

letterSpacing: 0.2,
),
),

const SizedBox(
width: 14,
),

Container(
width: 34,
height: 34,

decoration:
BoxDecoration(
color: Colors
    .white
    .withOpacity(
0.18,
),

shape:
BoxShape.circle,
),

child:
const Icon(
Icons
    .arrow_forward_rounded,

color:
Colors.white,

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
),
);
}

// ============================================================
// PREVIOUS BUTTON
// ============================================================

Widget _buildPreviousButton() {
return TextButton.icon(
onPressed: _previousPage,

style: TextButton.styleFrom(
foregroundColor:
Colors.white.withOpacity(0.90),

// Fond beaucoup plus discret
backgroundColor:
Colors.black.withOpacity(0.18),

padding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 7,
),

minimumSize:
const Size(0, 36),

tapTargetSize:
MaterialTapTargetSize.shrinkWrap,

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(20),
),
),

icon: Icon(
Icons.arrow_back_ios_new_rounded,
size: 13,

color:
Colors.white.withOpacity(0.85),
),

label: Text(
'Previous',

style: TextStyle(
fontSize: 13,
fontWeight:
FontWeight.w600,

color:
Colors.white.withOpacity(0.90),
),
),
);
}

// ============================================================
// NEXT BUTTON
// ============================================================

Widget _buildNextButton() {
return TextButton.icon(
onPressed: _nextPage,

style: TextButton.styleFrom(
foregroundColor:
Colors.white.withOpacity(0.90),

// Fond beaucoup plus discret
backgroundColor:
Colors.black.withOpacity(0.18),

padding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 7,
),

minimumSize:
const Size(0, 36),

tapTargetSize:
MaterialTapTargetSize.shrinkWrap,

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(20),
),
),

icon: Icon(
Icons.arrow_forward_ios_rounded,
size: 13,

color:
Colors.white.withOpacity(0.85),
),

label: Text(
'Next',

style: TextStyle(
fontSize: 13,
fontWeight:
FontWeight.w600,

color:
Colors.white.withOpacity(0.90),
),
),
);
}
}

