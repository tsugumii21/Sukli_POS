import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/route_constants.dart';

// ── Auth Screens ──────────────────────────────────────────────────────────────
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/auth/presentation/screens/verify_email_screen.dart';
import 'features/auth/presentation/screens/setup_wizard_screen.dart';
import 'features/auth/presentation/screens/cashier_selection_screen.dart';
import 'features/auth/presentation/screens/cashier_pin_screen.dart';
import 'features/auth/presentation/screens/admin_login_screen.dart';
import 'features/auth/presentation/screens/switch_to_admin_screen.dart';
import 'features/auth/presentation/screens/cashier_profile_screen.dart';

// ── Cashier Screens ───────────────────────────────────────────────────────────
import 'features/dashboard/presentation/screens/cashier_dashboard_screen.dart';
import 'features/menu/presentation/screens/new_order_screen.dart';
import 'features/checkout/presentation/screens/checkout_screen.dart';
import 'features/checkout/presentation/screens/payment_success_screen.dart';
import 'features/orders/presentation/screens/order_history_screen.dart';

// ── Admin Screens ─────────────────────────────────────────────────────────────
import 'features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'features/users/presentation/screens/user_management_screen.dart';
import 'features/menu/presentation/screens/category_management_screen.dart';
import 'features/menu/presentation/screens/item_management_screen.dart';
import 'features/void_refund/presentation/screens/void_refund_screen.dart';
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/reports/presentation/screens/end_of_day_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

/// Helper to build fade + slide route transitions (250ms, Material easing)
CustomTransitionPage<void> _buildFadeSlideTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Cubic(0.4, 0.0, 0.2, 1.0), // Material standard ease
            ),
          ),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Auth (no shell) ─────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.splash,
        pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
          state: s,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.welcome,
        pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
          state: s,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.signup,
        pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
          state: s,
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.verifyEmail,
        pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
          state: s,
          child: const VerifyEmailScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.setupWizard,
        pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
          state: s,
          child: const SetupWizardScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.cashierSelect,
        pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
          state: s,
          child: const CashierSelectionScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.cashierPin,
        pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
          state: s,
          child: const CashierPinScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.adminLogin,
        pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
          state: s,
          child: const AdminLoginScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.switchToAdmin,
        pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
          state: s,
          child: const SwitchToAdminScreen(),
        ),
      ),

      // ── Cashier Shell ────────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => CashierShell(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.cashierHome,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const CashierDashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.newOrder,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const NewOrderScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.checkout,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const CheckoutScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.paymentSuccess,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const PaymentSuccessScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.orderHistory,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const OrderHistoryScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.cashierProfile,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const CashierProfileScreen(),
            ),
          ),
        ],
      ),

      // ── Admin Shell ──────────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.adminHome,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const AdminDashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.adminUsers,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const UserManagementScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.adminMenuCats,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const CategoryManagementScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.adminMenuItems,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const ItemManagementScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.adminVoids,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const VoidRefundScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.adminReports,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const ReportsScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.adminEndOfDay,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const EndOfDayScreen(),
            ),
          ),
          GoRoute(
            path: RouteConstants.adminSettings,
            pageBuilder: (c, s) => _buildFadeSlideTransitionPage(
              state: s,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

// ── Shell Scaffolds ───────────────────────────────────────────────────────────

/// Cashier shell — wraps all cashier routes.
class CashierShell extends StatelessWidget {
  const CashierShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Admin shell — wraps all admin routes.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
