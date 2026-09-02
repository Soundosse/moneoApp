import 'dart:math' as math;
import 'package:flutter/material.dart';


class MoneoApp extends StatelessWidget {
  const MoneoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moneo',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020712),
        fontFamily: 'Arial',
      ),
      home: const DashboardScreen(),
    );
  }
}

// ============================================================
// COLORS
// ============================================================

const Color backgroundColor = Color(0xFF020712);
const Color purple = Color(0xFF8B3DFF);
const Color brightPurple = Color(0xFF9B4DFF);
const Color blue = Color(0xFF245BFF);
const Color green = Color(0xFF19E69B);
const Color pink = Color(0xFFFF3D81);
const Color yellow = Color(0xFFFFBE18);

const Color white = Color(0xFFF4F5FA);
const Color grey = Color(0xFF9DA3B4);

// ============================================================
// DASHBOARD
// ============================================================

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                125,
              ),
              child: Column(
                children: const [
                  Header(),

                  SizedBox(height: 28),

                  OverallBalanceCard(),

                  SizedBox(height: 18),

                  AccountsOverview(),

                  SizedBox(height: 18),

                  SpendingSummary(),

                  SizedBox(height: 18),

                  AiInsight(),

                  SizedBox(height: 18),

                  GoalsSection(),
                ],
              ),
            ),

            const Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: BottomNavigation(),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleButton(
                child: const MenuPlaceholder(),
              ),

              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8D45FF),
                            Color(0xFF3768FF),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      'Moneo',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              _CircleButton(
                child: Stack(
                  children: [
                    const Center(
                      child: BellPlaceholder(),
                    ),

                    Positioned(
                      right: 7,
                      top: 7,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: pink,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Good evening, Yassine 👋',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "Here's your financial overview",
          style: TextStyle(
            color: grey,
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final Widget child;

  const _CircleButton({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF111526),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF252B3C),
        ),
      ),
      child: child,
    );
  }
}

// ============================================================
// OVERALL BALANCE
// ============================================================

class OverallBalanceCard extends StatelessWidget {
  const OverallBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 365,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF343B54),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF141A2A),
            Color(0xFF11162A),
            Color(0xFF090E1B),
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: BalanceWavePainter(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    28,
                    25,
                    28,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Overall Balance',
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFFB5BAC8),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                EyePlaceholder(),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B2A50),
                              borderRadius:
                              BorderRadius.circular(22),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'This Month',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '⌄',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '2,340.00',
                                style: TextStyle(
                                  fontSize: 43,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: ' MAD',
                                style: TextStyle(
                                  fontSize: 19,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Row(
                        children: [
                          Text(
                            '↗',
                            style: TextStyle(
                              color: green,
                              fontSize: 21,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '+12.5%',
                            style: TextStyle(
                              color: green,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'from last month',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 95,
            color: const Color(0xB30A0E1A),
            child: Row(
              children: [
                const Expanded(
                  child: BalanceBottomItem(
                    title: 'Income',
                    value: '+ 4,850.00 MAD',
                    accent: green,
                  ),
                ),

                Container(
                  width: 1,
                  height: 52,
                  color: const Color(0xFF45495A),
                ),

                const Expanded(
                  child: BalanceBottomItem(
                    title: 'Expenses',
                    value: '- 2,510.00 MAD',
                    accent: pink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BalanceBottomItem extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;

  const BalanceBottomItem({
    super.key,
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.13),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 3),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}

// ============================================================
// WAVE
// ============================================================

class BalanceWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    path.moveTo(0, size.height * .82);

    path.cubicTo(
      size.width * .08,
      size.height * .66,
      size.width * .16,
      size.height * .72,
      size.width * .25,
      size.height * .65,
    );

    path.cubicTo(
      size.width * .36,
      size.height * .57,
      size.width * .40,
      size.height * .42,
      size.width * .50,
      size.height * .50,
    );

    path.cubicTo(
      size.width * .58,
      size.height * .56,
      size.width * .61,
      size.height * .64,
      size.width * .68,
      size.height * .53,
    );

    path.cubicTo(
      size.width * .75,
      size.height * .41,
      size.width * .78,
      size.height * .22,
      size.width * .87,
      size.height * .30,
    );

    path.cubicTo(
      size.width * .94,
      size.height * .37,
      size.width * .96,
      size.height * .27,
      size.width,
      size.height * .19,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xB45D2CFF),
          Color(0xCC351EFF),
          Color(0xDD071C88),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawPath(path, fillPaint);

    final linePath = Path();

    linePath.moveTo(0, size.height * .82);

    linePath.cubicTo(
      size.width * .08,
      size.height * .66,
      size.width * .16,
      size.height * .72,
      size.width * .25,
      size.height * .65,
    );

    linePath.cubicTo(
      size.width * .36,
      size.height * .57,
      size.width * .40,
      size.height * .42,
      size.width * .50,
      size.height * .50,
    );

    linePath.cubicTo(
      size.width * .58,
      size.height * .56,
      size.width * .61,
      size.height * .64,
      size.width * .68,
      size.height * .53,
    );

    linePath.cubicTo(
      size.width * .75,
      size.height * .41,
      size.width * .78,
      size.height * .22,
      size.width * .87,
      size.height * .30,
    );

    linePath.cubicTo(
      size.width * .94,
      size.height * .37,
      size.width * .96,
      size.height * .27,
      size.width,
      size.height * .19,
    );

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x407E48FF)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        8,
      );

    canvas.drawPath(linePath, glowPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF7D3FFF),
          Color(0xFFBD75FF),
          Color(0xFF5A8CFF),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// ACCOUNTS
// ============================================================

class AccountsOverview extends StatelessWidget {
  const AccountsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          const SectionHeader(
            title: 'Accounts Overview',
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return const Column(
                  children: [
                    PersonalAccountCard(),

                    SizedBox(height: 14),

                    SharedAccountCard(),
                  ],
                );
              }

              return const Row(
                children: [
                  Expanded(
                    child: PersonalAccountCard(),
                  ),

                  SizedBox(width: 14),

                  Expanded(
                    child: SharedAccountCard(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class PersonalAccountCard extends StatelessWidget {
  const PersonalAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountCard(
      title: 'Personal Account',
      amount: '2,340.00 MAD',
      spent: '1,260.00 MAD',
      percentage: '63%',
      progress: .63,
      accent: purple,
    );
  }
}

class AccountCard extends StatelessWidget {
  final String title;
  final String amount;
  final String spent;
  final String percentage;
  final double progress;
  final Color accent;

  const AccountCard({
    super.key,
    required this.title,
    required this.amount,
    required this.spent,
    required this.percentage,
    required this.progress,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 202,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151A2A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF30364C),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius:
                  BorderRadius.circular(13),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        amount,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          const Text(
            'Spent this month',
            style: TextStyle(
              color: grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            spent,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor:
                    const Color(0xFF252A3C),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(
                      accent,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Text(
                percentage,
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SharedAccountCard extends StatelessWidget {
  const SharedAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 202,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151A2A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF30364C),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF0988D6),
                  borderRadius:
                  BorderRadius.circular(13),
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Text(
                  'Shared Apartment',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          const Text(
            'You should receive',
            style: TextStyle(
              color: grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            '180.00 MAD',
            style: TextStyle(
              color: green,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'You owe',
            style: TextStyle(
              color: grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 2),

          const Text(
            '0.00 MAD',
            style: TextStyle(
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SPENDING SUMMARY
// ============================================================

class SpendingSummary extends StatelessWidget {
  const SpendingSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          const SectionHeader(
            title: 'Spending Summary',
          ),

          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return const Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: SpendingChart(),
                    ),

                    SizedBox(height: 18),

                    SpendingLegend(),
                  ],
                );
              }

              return const Row(
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 220,
                    child: SpendingChart(),
                  ),

                  SizedBox(width: 15),

                  Expanded(
                    child: SpendingLegend(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class SpendingChart extends StatelessWidget {
  const SpendingChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(205, 205),
          painter: DonutPainter(),
        ),

        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '2,510',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w600,
              ),
            ),

            Text(
              'MAD',
              style: TextStyle(
                color: grey,
                fontSize: 15,
              ),
            ),

            SizedBox(height: 3),

            Text(
              'Total',
              style: TextStyle(
                color: grey,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SpendingLegend extends StatelessWidget {
  const SpendingLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        LegendRow(
          title: 'Food & Groceries',
          percent: '40%',
          value: '1,004 MAD',
          accent: pink,
        ),

        SizedBox(height: 14),

        LegendRow(
          title: 'Transport',
          percent: '20%',
          value: '502 MAD',
          accent: yellow,
        ),

        SizedBox(height: 14),

        LegendRow(
          title: 'Housing',
          percent: '18%',
          value: '452 MAD',
          accent: Color(0xFF1489F7),
        ),

        SizedBox(height: 14),

        LegendRow(
          title: 'Entertainment',
          percent: '12%',
          value: '301 MAD',
          accent: purple,
        ),

        SizedBox(height: 14),

        LegendRow(
          title: 'Others',
          percent: '10%',
          value: '251 MAD',
          accent: Color(0xFF1ED3B1),
        ),
      ],
    );
  }
}

class LegendRow extends StatelessWidget {
  final String title;
  final String percent;
  final String value;
  final Color accent;

  const LegendRow({
    super.key,
    required this.title,
    required this.percent,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 33,
          height: 33,
          decoration: BoxDecoration(
            color: accent.withOpacity(.15),
            borderRadius:
            BorderRadius.circular(9),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ),

        const SizedBox(width: 5),

        Text(
          percent,
          style: const TextStyle(
            color: grey,
            fontSize: 13,
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 76,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DONUT PAINTER
// ============================================================

class DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2 - 10;

    const values = [
      .40,
      .20,
      .18,
      .12,
      .10,
    ];

    const colors = [
      pink,
      yellow,
      Color(0xFF2579FF),
      purple,
      Color(0xFF1ED3B1),
    ];

    double start = -math.pi / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 33;

    for (int i = 0; i < values.length; i++) {
      final sweep =
          values[i] * 2 * math.pi;

      paint.color = colors[i];

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        start,
        sweep,
        false,
        paint,
      );

      start += sweep;
    }

    final innerPaint = Paint()
      ..color = const Color(0xFF080D19);

    canvas.drawCircle(
      center,
      radius - 20,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}

// ============================================================
// AI INSIGHT
// ============================================================

class AiInsight extends StatelessWidget {
  const AiInsight({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF4D19B7),
            Color(0xFF211B4A),
            Color(0xFF101527),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF4D3A90),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 75,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFF9B55FF),
                            Color(0x003E176E),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Text(
                      'AI Insight',
                      style: TextStyle(
                        color: Color(0xFFBE9CFF),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  'You are spending more on food '
                      'than usual this month.',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Would you like some tips to '
                      'optimize your spending?',
                  style: TextStyle(
                    color: Color(0xFFB0B1C2),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF913CFF),
                        Color(0xFF6B28F2),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '✦  Ask Moneo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Container(
                width: 105,
                height: 105,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF9B55FF),
                      Color(0x003E176E),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'AI Insight',
                      style: TextStyle(
                        color: Color(0xFFBE9CFF),
                        fontSize: 16,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'You are spending more on food '
                          'than usual this month.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Would you like some tips to '
                          'optimize your spending?',
                      style: TextStyle(
                        color: Color(0xFFB0B1C2),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 160,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF913CFF),
                      Color(0xFF6B28F2),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    '✦  Ask Moneo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// GOALS
// ============================================================

class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          const SectionHeader(
            title: 'Goals',
          ),

          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return const Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    MarrakechPlaceholder(),

                    SizedBox(height: 16),

                    GoalInformation(),
                  ],
                );
              }

              return const Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  MarrakechPlaceholder(),

                  SizedBox(width: 22),

                  Expanded(
                    child: GoalInformation(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class MarrakechPlaceholder extends StatelessWidget {
  const MarrakechPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7C8DA6),
            Color(0xFF263143),
          ],
        ),
      ),
      child: const Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Marrakech Trip',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class GoalInformation extends StatelessWidget {
  const GoalInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Marrakech Trip',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '650',
                style: TextStyle(
                  color: green,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: ' / 1,500 MAD',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: .433,
                  minHeight: 6,
                  backgroundColor:
                  Color(0xFF252A3C),
                  valueColor:
                  AlwaysStoppedAnimation<Color>(
                    green,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            const Text(
              '43%',
              style: TextStyle(
                color: grey,
                fontSize: 14,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        const Wrap(
          spacing: 20,
          runSpacing: 8,
          children: [
            Text(
              '◷  30 days left',
              style: TextStyle(
                color: grey,
                fontSize: 14,
              ),
            ),

            Text(
              '♢  Save 28.3 MAD / day',
              style: TextStyle(
                color: grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// SECTION CARD
// ============================================================

class SectionCard extends StatelessWidget {
  final Widget child;

  const SectionCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF080E1B),
        borderRadius: BorderRadius.circular(29),
        border: Border.all(
          color: const Color(0xFF20283B),
        ),
      ),
      child: child,
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const Text(
          'See all',
          style: TextStyle(
            color: brightPurple,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION
// ============================================================

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1E),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF252C40),
        ),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,
        children: [
          const BottomItem(
            label: 'Dashboard',
            selected: true,
          ),

          const BottomItem(
            label: 'Transactions',
          ),

          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF9B45FF),
                  Color(0xFF6424EE),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: purple.withOpacity(.4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),

          const BottomItem(
            label: 'Goals',
          ),

          const BottomItem(
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class BottomItem extends StatelessWidget {
  final String label;
  final bool selected;

  const BottomItem({
    super.key,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: selected
                  ? purple
                  : const Color(0xFF858A9B),
              borderRadius:
              BorderRadius.circular(7),
            ),
          ),

          const SizedBox(height: 7),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? brightPurple
                    : const Color(0xFF9A9EAC),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PLACEHOLDER ICONS
// ============================================================

class MenuPlaceholder extends StatelessWidget {
  const MenuPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 2,
          color: white,
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: 2,
          color: white,
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: 2,
          color: white,
        ),
      ],
    );
  }
}

class BellPlaceholder extends StatelessWidget {
  const BellPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(
          color: white,
          width: 2,
        ),
        borderRadius:
        BorderRadius.circular(10),
      ),
    );
  }
}

class EyePlaceholder extends StatelessWidget {
  const EyePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 12,
      decoration: BoxDecoration(
        border: Border.all(
          color: grey,
          width: 1.5,
        ),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: const Center(
        child: CircleAvatar(
          radius: 2.5,
          backgroundColor: grey,
        ),
      ),
    );
  }
}