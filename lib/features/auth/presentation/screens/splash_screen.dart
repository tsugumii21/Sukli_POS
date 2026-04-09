import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// SplashScreen — cinematic entry screen with DM Serif Display branding.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for animations to complete, then navigate
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) {
      context.go(RouteConstants.cashierSelect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Real Sukli POS logo
            Image.asset(
              'assets/images/sukli_logo_transparent.png',
              width: 160,
              height: 160,
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .scaleXY(begin: 0.7, end: 1.0, duration: 600.ms, delay: 200.ms,
                    curve: Curves.easeOutBack),

            const SizedBox(height: 24),

            // App name
            const Text(
              'Sukli POS',
              style: TextStyle(
                color: AppColors.primaryLightVariant,
                fontSize: 40,
                fontFamily: 'DMSerifDisplay',
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 500.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 500.ms,
                    curve: Curves.easeOut),

            const SizedBox(height: 8),

            // Tagline
            const Text(
              'Your offline-first POS solution',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 13,
                fontFamily: 'DMSans',
                letterSpacing: 0.3,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 800.ms),

            const SizedBox(height: 64),

            // Loading dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(
                      delay: Duration(milliseconds: 1200 + (i * 150)),
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .fadeIn(duration: 400.ms)
                    .scaleXY(
                        begin: 0.5,
                        end: 1.0,
                        duration: 500.ms,
                        curve: Curves.easeInOut);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
