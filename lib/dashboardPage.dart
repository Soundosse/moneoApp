import 'dart:math' as math;

import 'package:flutter/material.dart';

// ================================================================
// DASHBOARD PAGE
// ================================================================

class DashboardPage extends StatefulWidget {
const DashboardPage({super.key});

@override
State<DashboardPage> createState() => _DashboardPageState();
}

// ================================================================
// DASHBOARD STATE
// ================================================================

class _DashboardPageState extends State<DashboardPage> {
// ============================================================
// MONEO COLORS
// ============================================================

static const Color background = Color(0xFF020208);

static const Color cardColor = Color(0xFF080B18);

static const Color cardColor2 = Color(0xFF0A0E20);

static const Color cyan = Color(0xFF00D5FF);

static const Color blue = Color(0xFF247BFF);

static const Color purple = Color(0xFF762CFF);

static const Color violet = Color(0xFF9A2CFF);

static const Color pink = Color(0xFFD92DFF);

static const Color mutedText = Color(0xFF9CA6C1);

// ============================================================
// USER DATA
// ============================================================

String userName = "Meryem";

// ============================================================
// BALANCE VISIBILITY
// ============================================================

bool _balanceVisible = true;

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: background,
body: SafeArea(
child: SingleChildScrollView(
physics: const BouncingScrollPhysics(),
padding: const EdgeInsets.fromLTRB(
18,
12,
18,
115,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ==================================================
// NEW HEADER
// ==================================================

_buildHeader(),

const SizedBox(height: 20),

// ==================================================
// TOTAL BALANCE
// ==================================================

_buildBalanceCard(),

const SizedBox(height: 20),

// ==================================================
// SPENDING + AI
// ==================================================

_buildSpendingSection(),

const SizedBox(height: 20),

// ==================================================
// ACCOUNTS OVERVIEW
// ==================================================

_buildAccountsOverview(),

const SizedBox(height: 20),

// ==================================================
// RECENT TRANSACTIONS
// ==================================================

_buildTransactions(),

const SizedBox(height: 20),

// ==================================================
// GOALS
// ==================================================

_buildGoals(),
],
),
),
),

// ==========================================================
// BOTTOM NAVIGATION
// ==========================================================

bottomNavigationBar: _buildBottomNavigation(),
);
}

// ============================================================
// NEW HEADER
// ============================================================
//
// ROW 1:
// Logo + Moneo                         Menu + Notification
//
// ROW 2:
// Good morning, Meryem
//
// ROW 3:
// Let's make your money smarter.
//
// ============================================================

Widget _buildHeader() {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ======================================================
// TOP ROW
// LOGO + MONEO + BUTTONS
// ======================================================

SizedBox(
height: 58,
child: Row(
children: [
// ==================================================
// LOGO
// ==================================================

Container(
width: 52,
height: 52,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(17),
boxShadow: [
BoxShadow(
color: cyan.withOpacity(0.20),
blurRadius: 28,
spreadRadius: 2,
),
BoxShadow(
color: purple.withOpacity(0.12),
blurRadius: 35,
),
],
),
child: ClipRRect(
borderRadius: BorderRadius.circular(17),
child: Image.asset(
'assets/images/foreground.png',
fit: BoxFit.contain,
errorBuilder: (
context,
error,
stackTrace,
) {
return Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(17),
gradient: const LinearGradient(
colors: [
Color(0xFF111B55),
Color(0xFF28105E),
],
),
),
child: const Icon(
Icons.account_balance_wallet_rounded,
color: cyan,
size: 31,
),
);
},
),
),
),

const SizedBox(width: 12),

// ==================================================
// MONEO NAME
// ==================================================

ShaderMask(
shaderCallback: (bounds) {
return const LinearGradient(
begin: Alignment.centerLeft,
end: Alignment.centerRight,
colors: [
cyan,
blue,
purple,
pink,
],
).createShader(bounds);
},
child: const Text(
"Moneo",
style: TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight: FontWeight.w700,
letterSpacing: -0.5,
),
),
),

const Spacer(),

// ==================================================
// NOTIFICATION
// ==================================================

_notificationButton(),

const SizedBox(width: 8),

// ==================================================
// MENU
// ==================================================

_menuButton(),
],
),
),

const SizedBox(height: 15),

// ======================================================
// GREETING
// ======================================================

SizedBox(
width: double.infinity,
child: Text(
"Good morning, $userName",
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.white,
fontSize: 20,
fontWeight: FontWeight.w500,
letterSpacing: -0.3,
),
),
),

const SizedBox(height: 5),

// ======================================================
// SUBTITLE
// ======================================================

ShaderMask(
shaderCallback: (bounds) {
return const LinearGradient(
begin: Alignment.centerLeft,
end: Alignment.centerRight,
colors: [
cyan,
purple,
pink,
],
).createShader(bounds);
},
child: const Text(
"Let's make your money smarter.",
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: TextStyle(
color: Colors.white,
fontSize: 12.5,
fontWeight: FontWeight.w400,
),
),
),
],
);
}

// ============================================================
// MENU BUTTON - 3 TIRES
// ============================================================

Widget _menuButton() {
return GestureDetector(
onTap: _openMenu,
child: Container(
width: 50,
height: 50,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: cardColor,
border: Border.all(
color: purple.withOpacity(0.60),
width: 1.1,
),
boxShadow: [
BoxShadow(
color: purple.withOpacity(0.15),
blurRadius: 20,
spreadRadius: 1,
),
],
),
child: const Center(
child: Icon(
Icons.menu_rounded,
color: Colors.white,
size: 25,
),
),
),
);
}

// ============================================================
// NOTIFICATION BUTTON
// ============================================================

Widget _notificationButton() {
return Container(
width: 50,
height: 50,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: cardColor,
border: Border.all(
color: purple.withOpacity(0.70),
width: 1.2,
),
boxShadow: [
BoxShadow(
color: purple.withOpacity(0.20),
blurRadius: 22,
spreadRadius: 1,
),
],
),
child: Stack(
clipBehavior: Clip.none,
children: [
const Center(
child: Icon(
Icons.notifications_none_rounded,
color: Colors.white,
size: 26,
),
),

Positioned(
top: 4,
right: 5,
child: Container(
width: 9,
height: 9,
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient: const LinearGradient(
colors: [
pink,
purple,
],
),
boxShadow: [
BoxShadow(
color: pink.withOpacity(0.70),
blurRadius: 10,
),
],
),
),
),
],
),
);
}

// ============================================================
// BALANCE CARD
// ============================================================

Widget _buildBalanceCard() {
return Container(
width: double.infinity,
height: 235,
padding: const EdgeInsets.fromLTRB(
22,
17,
22,
8,
),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(27),
color: cardColor,
border: Border.all(
color: cyan.withOpacity(0.55),
width: 1.1,
),
boxShadow: [
BoxShadow(
color: cyan.withOpacity(0.07),
blurRadius: 30,
spreadRadius: 1,
),
BoxShadow(
color: purple.withOpacity(0.04),
blurRadius: 40,
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ======================================================
// TITLE + EYE
// ======================================================

Row(
children: [
const Text(
"Total balance",
style: TextStyle(
color: Color(0xFFB9C2DA),
fontSize: 16,
fontWeight: FontWeight.w400,
),
),

const Spacer(),

GestureDetector(
onTap: () {
setState(() {
_balanceVisible = !_balanceVisible;
});
},
child: AnimatedContainer(
duration: const Duration(
milliseconds: 200,
),
width: 49,
height: 40,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(14),
color: Colors.white.withOpacity(0.025),
border: Border.all(
color: _balanceVisible
? cyan.withOpacity(0.35)
    : Colors.white.withOpacity(0.15),
),
),
child: Icon(
_balanceVisible
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
color: _balanceVisible
? cyan
    : Colors.white,
size: 22,
),
),
),
],
),

const SizedBox(height: 2),

// ======================================================
// BALANCE
// ======================================================

AnimatedSwitcher(
duration: const Duration(
milliseconds: 250,
),
child: FittedBox(
key: ValueKey(_balanceVisible),
fit: BoxFit.scaleDown,
alignment: Alignment.centerLeft,
child: Text(
_balanceVisible
? "4,250 MAD"
    : "••••••",
style: const TextStyle(
color: Colors.white,
fontSize: 34,
fontWeight: FontWeight.w700,
letterSpacing: -1.2,
),
),
),
),

const SizedBox(height: 5),

// ======================================================
// MONTHLY CHANGE
// ======================================================

Container(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 5,
),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(18),
color: cyan.withOpacity(0.06),
border: Border.all(
color: cyan.withOpacity(0.32),
),
),
child: const Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.north_east_rounded,
color: cyan,
size: 17,
),
SizedBox(width: 6),
Text(
"+8.4% this month",
style: TextStyle(
color: cyan,
fontSize: 13,
fontWeight: FontWeight.w600,
),
),
],
),
),

const Spacer(),

// ======================================================
// GRAPH
// ======================================================

SizedBox(
width: double.infinity,
height: 62,
child: CustomPaint(
painter: BalanceGraphPainter(),
),
),
],
),
);
}

// ============================================================
// SPENDING SECTION
// ============================================================

Widget _buildSpendingSection() {
return LayoutBuilder(
builder: (context, constraints) {
if (constraints.maxWidth < 650) {
return Column(
children: [
_buildSpendingCard(),
const SizedBox(height: 16),
_buildAIInsight(),
],
);
}

return Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
flex: 3,
child: _buildSpendingCard(),
),
const SizedBox(width: 16),
Expanded(
flex: 2,
child: _buildAIInsight(),
),
],
);
},
);
}

// ============================================================
// SPENDING CARD
// ============================================================

Widget _buildSpendingCard() {
return Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(
20,
19,
20,
15,
),
decoration: BoxDecoration(
color: cardColor,
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: purple.withOpacity(0.38),
),
boxShadow: [
BoxShadow(
color: purple.withOpacity(0.05),
blurRadius: 25,
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
const Expanded(
child: Text(
"Spending overview",
style: TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight: FontWeight.w600,
),
),
),
const Text(
"This month",
style: TextStyle(
color: Color(0xFFB9C2D8),
fontSize: 12,
),
),
const SizedBox(width: 5),
const Icon(
Icons.keyboard_arrow_down_rounded,
color: Colors.white,
size: 20,
),
],
),

const SizedBox(height: 18),

Row(
crossAxisAlignment: CrossAxisAlignment.center,
children: [
SizedBox(
width: 145,
height: 145,
child: CustomPaint(
painter: SpendingChartPainter(),
child: const Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Text(
"2,180",
style: TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
Text(
"MAD",
style: TextStyle(
color: Colors.white70,
fontSize: 11,
),
),
Text(
"spent",
style: TextStyle(
color: Colors.white70,
fontSize: 11,
),
),
],
),
),
),
),

const SizedBox(width: 16),

Expanded(
child: Column(
children: [
_category(
"Food",
"720 MAD",
"33%",
cyan,
),

const SizedBox(height: 12),

_category(
"Transport",
"340 MAD",
"16%",
purple,
),

const SizedBox(height: 12),

_category(
"Shopping",
"280 MAD",
"13%",
pink,
),
],
),
),
],
),

const SizedBox(height: 14),

Divider(
color: Colors.white.withOpacity(0.10),
height: 1,
),

const SizedBox(height: 9),

GestureDetector(
onTap: () {},
child: const Row(
children: [
Text(
"View full report",
style: TextStyle(
color: cyan,
fontSize: 14,
fontWeight: FontWeight.w600,
),
),
Spacer(),
Icon(
Icons.arrow_forward_ios_rounded,
color: Colors.white70,
size: 14,
),
],
),
),
],
),
);
}

// ============================================================
// CATEGORY
// ============================================================

Widget _category(
String title,
String amount,
String percentage,
Color color,
) {
return Row(
children: [
Container(
width: 10,
height: 10,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: color,
boxShadow: [
BoxShadow(
color: color.withOpacity(0.65),
blurRadius: 9,
),
],
),
),

const SizedBox(width: 9),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
color: Colors.white,
fontSize: 13,
),
),
const SizedBox(height: 2),
Text(
amount,
style: const TextStyle(
color: Colors.white70,
fontSize: 11,
),
),
],
),
),

Text(
percentage,
style: const TextStyle(
color: Colors.white54,
fontSize: 11,
),
),
],
);
}

// ============================================================
// AI AGENT
// ============================================================

Widget _buildAIInsight() {
return Container(
width: double.infinity,
decoration: BoxDecoration(
color: cardColor,
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: purple.withOpacity(0.52),
width: 1.1,
),
boxShadow: [
BoxShadow(
color: purple.withOpacity(0.10),
blurRadius: 28,
spreadRadius: 1,
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
ClipRRect(
borderRadius: const BorderRadius.vertical(
top: Radius.circular(23),
),
child: SizedBox(
width: double.infinity,
height: 175,
child: Image.asset(
'assets/images/aiagent.png',
fit: BoxFit.cover,
errorBuilder:
(context, error, stackTrace) {
return Container(
decoration:
const BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Color(0xFF090D27),
Color(0xFF100A2B),
],
),
),
child: const Center(
child: Icon(
Icons.smart_toy_rounded,
color: cyan,
size: 55,
),
),
);
},
),
),
),

Padding(
padding: const EdgeInsets.fromLTRB(
18,
15,
18,
17,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
ShaderMask(
shaderCallback: (bounds) {
return const LinearGradient(
colors: [
cyan,
purple,
pink,
],
).createShader(bounds);
},
child: const Text(
"Ask Moneo",
style: TextStyle(
color: Colors.white,
fontSize: 17,
fontWeight: FontWeight.bold,
),
),
),

const SizedBox(height: 9),

RichText(
text: const TextSpan(
style: TextStyle(
color: Colors.white70,
fontSize: 14,
height: 1.45,
),
children: [
TextSpan(
text: "You're spending ",
),
TextSpan(
text: "14%",
style: TextStyle(
color: pink,
fontWeight: FontWeight.bold,
),
),
TextSpan(
text:
" less on food this month.\nGreat progress!",
),
],
),
),

const SizedBox(height: 14),

GestureDetector(
onTap: () {},
child: Container(
width: double.infinity,
height: 46,
decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(17),
gradient:
const LinearGradient(
colors: [
Color(0xFF006CFF),
Color(0xFFB000FF),
],
),
boxShadow: [
BoxShadow(
color:
purple.withOpacity(0.28),
blurRadius: 18,
spreadRadius: 1,
),
],
),
child: const Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Text(
"View insights",
style: TextStyle(
color: Colors.white,
fontSize: 13,
fontWeight:
FontWeight.w600,
),
),
SizedBox(width: 8),
Icon(
Icons.arrow_forward_rounded,
color: Colors.white,
size: 18,
),
],
),
),
),
],
),
),
],
),
);
}

// ============================================================
// ACCOUNTS OVERVIEW
// ============================================================

Widget _buildAccountsOverview() {
return Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(
16,
18,
16,
16,
),
decoration: BoxDecoration(
color: cardColor,
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: purple.withOpacity(0.30),
width: 1,
),
boxShadow: [
BoxShadow(
color: purple.withOpacity(0.05),
blurRadius: 25,
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// ======================================================
// HEADER
// ======================================================

Row(
children: [
const Expanded(
child: Text(
"Accounts overview",
style: TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight: FontWeight.w600,
),
),
),

GestureDetector(
onTap: () {},
child: const Row(
mainAxisSize:
MainAxisSize.min,
children: [
Text(
"View all",
style: TextStyle(
color: cyan,
fontSize: 12,
fontWeight:
FontWeight.w500,
),
),
SizedBox(width: 3),
Icon(
Icons.chevron_right_rounded,
color: cyan,
size: 18,
),
],
),
),
],
),

const SizedBox(height: 15),

// ======================================================
// TWO ACCOUNTS
// ======================================================

Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Expanded(
child: _accountCard(
title: "Personal",
subtitle: "My money",
amount: "2,850 MAD",
icon:
Icons.person_outline_rounded,
colors: const [
cyan,
blue,
],
percentage: "67%",
),
),

const SizedBox(width: 10),

Expanded(
child: _accountCard(
title: "Shared",
subtitle: "Apartment",
amount: "1,400 MAD",
icon:
Icons.people_alt_outlined,
colors: const [
purple,
pink,
],
percentage: "33%",
),
),
],
),
],
),
);
}

// ============================================================
// ACCOUNT CARD
// ============================================================

Widget _accountCard({
required String title,
required String subtitle,
required String amount,
required IconData icon,
required List<Color> colors,
required String percentage,
}) {
return Container(
padding: const EdgeInsets.fromLTRB(
12,
12,
10,
12,
),
decoration: BoxDecoration(
color: const Color(0xFF0A0E20),
borderRadius: BorderRadius.circular(19),
border: Border.all(
color: colors.first.withOpacity(0.35),
width: 1,
),
boxShadow: [
BoxShadow(
color:
colors.first.withOpacity(0.06),
blurRadius: 20,
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 36,
height: 36,
decoration: BoxDecoration(
shape: BoxShape.circle,
color:
colors.first.withOpacity(0.10),
border: Border.all(
color:
colors.first.withOpacity(0.30),
),
),
child: Icon(
icon,
color: colors.first,
size: 18,
),
),

const Spacer(),

Container(
padding:
const EdgeInsets.symmetric(
horizontal: 6,
vertical: 3,
),
decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(9),
color:
colors.first.withOpacity(0.07),
),
child: Text(
percentage,
style: TextStyle(
color: colors.first,
fontSize: 9,
fontWeight:
FontWeight.w600,
),
),
),
],
),

const SizedBox(height: 10),

Text(
title,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.white,
fontSize: 13,
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 3),

Text(
subtitle,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
color: Color(0xFF7F899F),
fontSize: 9.5,
),
),

const SizedBox(height: 8),

ShaderMask(
shaderCallback: (bounds) {
return LinearGradient(
colors: colors,
).createShader(bounds);
},
child: FittedBox(
fit: BoxFit.scaleDown,
alignment:
Alignment.centerLeft,
child: Text(
amount,
style: const TextStyle(
color: Colors.white,
fontSize: 17,
fontWeight:
FontWeight.w700,
),
),
),
),
],
),
);
}

// ============================================================
// TRANSACTIONS
// ============================================================

Widget _buildTransactions() {
return Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(
18,
18,
18,
8,
),
decoration: BoxDecoration(
color: cardColor,
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: purple.withOpacity(0.30),
),
),
child: Column(
children: [
Row(
children: [
const Expanded(
child: Text(
"Recent transactions",
style: TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight: FontWeight.w600,
),
),
),

GestureDetector(
onTap: () {},
child: const Row(
children: [
Text(
"View all",
style: TextStyle(
color: Color(0xFFB9C1D8),
fontSize: 12,
),
),
Icon(
Icons.chevron_right_rounded,
color: Colors.white70,
size: 19,
),
],
),
),
],
),

const SizedBox(height: 9),

_transaction(
icon: Icons.local_cafe_rounded,
title: "Campus Café",
date: "Today, 08:45",
amount: "- 45 MAD",
color: pink,
),

_transaction(
icon:
Icons.directions_car_filled_rounded,
title: "Uber",
date: "Yesterday, 19:30",
amount: "- 32 MAD",
color: blue,
),

_transaction(
icon:
Icons.attach_money_rounded,
title: "Freelance payment",
date: "May 25, 14:20",
amount: "+ 850 MAD",
color: cyan,
positive: true,
),
],
),
);
}

// ============================================================
// TRANSACTION ITEM
// ============================================================

Widget _transaction({
required IconData icon,
required String title,
required String date,
required String amount,
required Color color,
bool positive = false,
}) {
return Container(
padding:
const EdgeInsets.symmetric(
vertical: 11,
),
decoration: BoxDecoration(
border: Border(
bottom: BorderSide(
color:
Colors.white.withOpacity(0.07),
),
),
),
child: Row(
children: [
Container(
width: 45,
height: 45,
decoration: BoxDecoration(
shape: BoxShape.circle,
color:
color.withOpacity(0.10),
border: Border.all(
color:
color.withOpacity(0.45),
),
boxShadow: [
BoxShadow(
color:
color.withOpacity(0.08),
blurRadius: 15,
),
],
),
child: Icon(
icon,
color: color,
size: 21,
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.white,
fontSize: 14,
fontWeight:
FontWeight.w500,
),
),

const SizedBox(height: 4),

Text(
date,
style: const TextStyle(
color:
Color(0xFF7E879E),
fontSize: 11,
),
),
],
),
),

Text(
amount,
style: TextStyle(
color:
positive ? cyan : Colors.white,
fontSize: 13,
fontWeight:
FontWeight.w600,
),
),

const SizedBox(width: 3),

const Icon(
Icons.chevron_right_rounded,
color: Colors.white54,
size: 20,
),
],
),
);
}

// ============================================================
// GOALS
// ============================================================

Widget _buildGoals() {
return Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(
18,
18,
18,
18,
),
decoration: BoxDecoration(
color: cardColor,
borderRadius: BorderRadius.circular(24),
border: Border.all(
color:
violet.withOpacity(0.35),
width: 1,
),
boxShadow: [
BoxShadow(
color:
violet.withOpacity(0.06),
blurRadius: 25,
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
const Expanded(
child: Text(
"Goals",
style: TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight:
FontWeight.w600,
),
),
),

GestureDetector(
onTap: () {},
child: const Row(
children: [
Text(
"View all",
style: TextStyle(
color:
Color(0xFFB9C1D8),
fontSize: 12,
),
),
Icon(
Icons.chevron_right_rounded,
color: Colors.white70,
size: 19,
),
],
),
),
],
),

const SizedBox(height: 16),

_goalItem(
icon:
Icons.luggage_outlined,
title: "Summer trip",
current: "3,200 MAD",
target: "5,000 MAD",
progress: 0.64,
color: cyan,
),

const SizedBox(height: 15),

_goalItem(
icon:
Icons.laptop_mac_rounded,
title: "New laptop",
current: "2,750 MAD",
target: "4,000 MAD",
progress: 0.6875,
color: purple,
),

const SizedBox(height: 15),

_goalItem(
icon:
Icons.savings_outlined,
title: "Emergency fund",
current: "1,800 MAD",
target: "3,000 MAD",
progress: 0.60,
color: pink,
),
],
),
);
}

// ============================================================
// GOAL ITEM
// ============================================================

Widget _goalItem({
required IconData icon,
required String title,
required String current,
required String target,
required double progress,
required Color color,
}) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
shape: BoxShape.circle,
color:
color.withOpacity(0.10),
border: Border.all(
color:
color.withOpacity(0.32),
),
),
child: Icon(
icon,
color: color,
size: 21,
),
),

const SizedBox(width: 11),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style:
const TextStyle(
color: Colors.white,
fontSize: 13.5,
fontWeight:
FontWeight.w500,
),
),

const SizedBox(height: 3),

Text(
"$current / $target",
style:
const TextStyle(
color:
Color(0xFF818BA2),
fontSize: 10.5,
),
),
],
),
),

Text(
"${(progress * 100).round()}%",
style: TextStyle(
color: color,
fontSize: 12,
fontWeight:
FontWeight.w600,
),
),
],
),

const SizedBox(height: 9),

ClipRRect(
borderRadius:
BorderRadius.circular(10),
child: Stack(
children: [
Container(
height: 7,
width: double.infinity,
color:
Colors.white.withOpacity(
0.07,
),
),

FractionallySizedBox(
widthFactor: progress,
child: Container(
height: 7,
decoration:
BoxDecoration(
borderRadius:
BorderRadius.circular(
10,
),
gradient:
LinearGradient(
colors: [
color,
color.withOpacity(
0.45,
),
],
),
boxShadow: [
BoxShadow(
color:
color.withOpacity(
0.40,
),
blurRadius: 8,
),
],
),
),
),
],
),
),
],
);
}

// ============================================================
// BOTTOM NAVIGATION
// ============================================================

Widget _buildBottomNavigation() {
return SafeArea(
top: false,
child: Container(
margin: const EdgeInsets.fromLTRB(
12,
0,
12,
10,
),
height: 78,
decoration: BoxDecoration(
color:
const Color(0xFF070A16),
borderRadius:
BorderRadius.circular(35),
border: Border.all(
color:
purple.withOpacity(0.30),
width: 1,
),
boxShadow: [
BoxShadow(
color:
Colors.black.withOpacity(
0.50,
),
blurRadius: 25,
spreadRadius: 2,
),
BoxShadow(
color:
purple.withOpacity(0.08),
blurRadius: 25,
),
],
),
child: Row(
children: [
Expanded(
child: _bottomItem(
icon:
Icons.home_rounded,
title: "Home",
selected: true,
),
),

Expanded(
child: _bottomItem(
icon:
Icons.receipt_long_rounded,
title: "Transactions",
selected: false,
),
),

SizedBox(
width: 78,
child: Center(
child:
_centerAddButton(),
),
),

Expanded(
child: _bottomItem(
icon:
Icons.track_changes_rounded,
title: "Goals",
selected: false,
),
),

Expanded(
child: _bottomItem(
icon:
Icons.person_outline_rounded,
title: "Profile",
selected: false,
),
),
],
),
),
);
}

// ============================================================
// CENTER ADD BUTTON
// ============================================================

Widget _centerAddButton() {
return Container(
width: 68,
height: 68,
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient:
const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
cyan,
blue,
purple,
pink,
],
),
boxShadow: [
BoxShadow(
color:
cyan.withOpacity(0.22),
blurRadius: 20,
spreadRadius: 2,
),
BoxShadow(
color:
purple.withOpacity(0.45),
blurRadius: 30,
spreadRadius: 2,
),
],
),
child: Container(
margin:
const EdgeInsets.all(1.5),
decoration:
const BoxDecoration(
shape: BoxShape.circle,
color:
Color(0xFF080B18),
),
child: const Center(
child: Icon(
Icons.add_rounded,
color: Colors.white,
size: 34,
),
),
),
);
}

// ============================================================
// BOTTOM ITEM
// ============================================================

Widget _bottomItem({
required IconData icon,
required String title,
required bool selected,
}) {
return GestureDetector(
onTap: () {},
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
icon,
color: selected
? cyan
    : const Color(
0xFF9CA5BF,
),
size:
selected ? 28 : 25,
),

const SizedBox(height: 3),

Text(
title,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: TextStyle(
color: selected
? cyan
    : const Color(
0xFF9CA5BF,
),
fontSize: 10,
fontWeight: selected
? FontWeight.w500
    : FontWeight.w400,
),
),
],
),
);
}

// ============================================================
// MENU
// ============================================================

void _openMenu() {
showModalBottomSheet(
context: context,
backgroundColor:
Colors.transparent,
isScrollControlled: true,
useSafeArea: true,
builder: (context) {
return SafeArea(
top: false,
bottom: true,
child: Container(
padding:
const EdgeInsets.fromLTRB(
20,
12,
20,
34,
),
decoration:
const BoxDecoration(
color:
Color(0xFF090C18),
borderRadius:
BorderRadius.vertical(
top: Radius.circular(30),
),
),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
Container(
width: 45,
height: 4,
decoration:
BoxDecoration(
color: Colors.white24,
borderRadius:
BorderRadius.circular(
10,
),
),
),

const SizedBox(height: 24),

const Align(
alignment:
Alignment.centerLeft,
child: Text(
"Menu",
style: TextStyle(
color: Colors.white,
fontSize: 21,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(height: 14),

_menuItem(
Icons.person_outline_rounded,
"My profile",
),

_menuItem(
Icons.settings_outlined,
"Settings",
),

_menuItem(
Icons.notifications_none_rounded,
"Notifications",
),

_menuItem(
Icons.help_outline_rounded,
"Help & support",
),

const SizedBox(height: 10),
],
),
),
);
},
);
}

// ============================================================
// MENU ITEM
// ============================================================

Widget _menuItem(
IconData icon,
String title,
) {
return ListTile(
contentPadding:
const EdgeInsets.symmetric(
horizontal: 4,
vertical: 2,
),
leading: Container(
width: 42,
height: 42,
decoration: BoxDecoration(
shape: BoxShape.circle,
color:
cyan.withOpacity(0.08),
border: Border.all(
color:
cyan.withOpacity(0.25),
),
),
child: Icon(
icon,
color: cyan,
size: 21,
),
),
title: Text(
title,
style: const TextStyle(
color: Colors.white,
fontSize: 15,
fontWeight:
FontWeight.w500,
),
),
trailing: const Icon(
Icons.chevron_right_rounded,
color: Colors.white54,
),
onTap: () {
Navigator.pop(context);
},
);
}
}

// =================================================================
// BALANCE GRAPH PAINTER
// =================================================================

class BalanceGraphPainter
extends CustomPainter {
@override
void paint(
Canvas canvas,
Size size,
) {
final path = Path();

path.moveTo(
0,
size.height * 0.82,
);

path.cubicTo(
size.width * 0.08,
size.height * 0.88,
size.width * 0.14,
size.height * 0.89,
size.width * 0.22,
size.height * 0.65,
);

path.cubicTo(
size.width * 0.31,
size.height * 0.38,
size.width * 0.38,
size.height * 0.72,
size.width * 0.47,
size.height * 0.43,
);

path.cubicTo(
size.width * 0.55,
size.height * 0.17,
size.width * 0.62,
size.height * 0.61,
size.width * 0.70,
size.height * 0.33,
);

path.cubicTo(
size.width * 0.78,
size.height * 0.08,
size.width * 0.84,
size.height * 0.32,
size.width * 0.91,
size.height * 0.22,
);

path.cubicTo(
size.width * 0.95,
size.height * 0.16,
size.width * 0.98,
size.height * 0.12,
size.width,
size.height * 0.05,
);

// ==========================================================
// FILL
// ==========================================================

final fillPath =
Path.from(path);

fillPath.lineTo(
size.width,
size.height,
);

fillPath.lineTo(
0,
size.height,
);

fillPath.close();

final fillGradient =
LinearGradient(
begin:
Alignment.topCenter,
end:
Alignment.bottomCenter,
colors: [
const Color(0xFF8C2CFF)
    .withOpacity(0.24),
const Color(0xFF247BFF)
    .withOpacity(0.08),
Colors.transparent,
],
);

final fillPaint =
Paint()
..shader =
fillGradient.createShader(
Rect.fromLTWH(
0,
0,
size.width,
size.height,
),
);

canvas.drawPath(
fillPath,
fillPaint,
);

// ==========================================================
// GUIDE LINES
// ==========================================================

final guidePaint =
Paint()
..color =
const Color(0xFF6B58FF)
    .withOpacity(0.10)
..strokeWidth = 1;

for (int i = 1; i <= 6; i++) {
final x =
size.width * (i / 7);

canvas.drawLine(
Offset(
x,
size.height * 0.45,
),
Offset(
x,
size.height,
),
guidePaint,
);
}

// ==========================================================
// GRAPH GRADIENT
// ==========================================================

final gradient =
const LinearGradient(
begin:
Alignment.centerLeft,
end:
Alignment.centerRight,
colors: [
Color(0xFF00D5FF),
Color(0xFF247BFF),
Color(0xFF7132FF),
Color(0xFFD52CFF),
],
);

// ==========================================================
// GLOW
// ==========================================================

final glowPaint =
Paint()
..style =
PaintingStyle.stroke
..strokeWidth = 13
..strokeCap =
StrokeCap.round
..shader =
gradient.createShader(
Rect.fromLTWH(
0,
0,
size.width,
size.height,
),
)
..maskFilter =
const MaskFilter.blur(
BlurStyle.normal,
11,
);

canvas.drawPath(
path,
glowPaint,
);

// ==========================================================
// MAIN LINE
// ==========================================================

final linePaint =
Paint()
..style =
PaintingStyle.stroke
..strokeWidth = 4.2
..strokeCap =
StrokeCap.round
..strokeJoin =
StrokeJoin.round
..shader =
gradient.createShader(
Rect.fromLTWH(
0,
0,
size.width,
size.height,
),
);

canvas.drawPath(
path,
linePaint,
);

// ==========================================================
// FINAL POINT GLOW
// ==========================================================

final glowDot =
Paint()
..color =
const Color(0xFFD12CFF)
    .withOpacity(0.35)
..maskFilter =
const MaskFilter.blur(
BlurStyle.normal,
12,
);

canvas.drawCircle(
Offset(
size.width,
size.height * 0.05,
),
10,
glowDot,
);

// ==========================================================
// FINAL WHITE POINT
// ==========================================================

final dotPaint =
Paint()
..color = Colors.white
..style =
PaintingStyle.fill;

canvas.drawCircle(
Offset(
size.width,
size.height * 0.05,
),
5.5,
dotPaint,
);
}

@override
bool shouldRepaint(
covariant CustomPainter oldDelegate,
) {
return false;
}
}

// =================================================================
// SPENDING DONUT CHART
// =================================================================

class SpendingChartPainter
extends CustomPainter {
@override
void paint(
Canvas canvas,
Size size,
) {
final center = Offset(
size.width / 2,
size.height / 2,
);

final radius =
size.width * 0.36;

final paint =
Paint()
..style =
PaintingStyle.stroke
..strokeWidth = 20
..strokeCap =
StrokeCap.butt;

// ==========================================================
// FOOD
// ==========================================================

paint.shader =
const LinearGradient(
colors: [
Color(0xFF00D5FF),
Color(0xFF247BFF),
],
).createShader(
Rect.fromCircle(
center: center,
radius: radius,
),
);

canvas.drawArc(
Rect.fromCircle(
center: center,
radius: radius,
),
-math.pi / 2,
math.pi * 0.66,
false,
paint,
);

// ==========================================================
// TRANSPORT
// ==========================================================

paint.shader =
const LinearGradient(
colors: [
Color(0xFF6B2CFF),
Color(0xFF9C2CFF),
],
).createShader(
Rect.fromCircle(
center: center,
radius: radius,
),
);

canvas.drawArc(
Rect.fromCircle(
center: center,
radius: radius,
),
math.pi * 0.14,
math.pi * 0.30,
false,
paint,
);

// ==========================================================
// SHOPPING
// ==========================================================

paint.shader =
const LinearGradient(
colors: [
Color(0xFF9C2CFF),
Color(0xFFD72DFF),
],
).createShader(
Rect.fromCircle(
center: center,
radius: radius,
),
);

canvas.drawArc(
Rect.fromCircle(
center: center,
radius: radius,
),
math.pi * 0.46,
math.pi * 0.28,
false,
paint,
);
}

@override
bool shouldRepaint(
covariant CustomPainter oldDelegate,
) {
return false;
}
}

