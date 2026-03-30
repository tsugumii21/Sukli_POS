import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/auth_provider.dart';
import '../constants/route_constants.dart';

// --- PLACEHOLDER SCREENS ---
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)));
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(appAuthProvider);

  return GoRouter(
    initialLocation: RouteConstants.splash,
    redirect: (context, state) {
      final status = authState.status;
      final goingToSplash = state.matchedLocation == RouteConstants.splash;
      final goingToRoleSelect = state.matchedLocation == RouteConstants.roleSelect;
      final isGoingToAdmin = state.matchedLocation.startsWith('/admin');
      final isGoingToCashier = state.matchedLocation.startsWith('/cashier');

      // 1. App is Loading
      if (status == AppAuthStatus.loading && !goingToSplash) return RouteConstants.splash;

      // 2. Not Logged In
      if (status == AppAuthStatus.unauthenticated) {
        if (isGoingToAdmin && state.matchedLocation != RouteConstants.adminLogin) return RouteConstants.adminLogin;
        if (isGoingToCashier && state.matchedLocation != RouteConstants.cashierLogin) return RouteConstants.cashierLogin;
        if (!goingToSplash && !goingToRoleSelect && !isGoingToAdmin && !isGoingToCashier) return RouteConstants.roleSelect;
      }

      // 3. Logged in as Admin
      if (status == AppAuthStatus.adminAuthenticated && state.matchedLocation == RouteConstants.adminLogin) return RouteConstants.adminHome;

      // 4. Logged in as Cashier
      if (status == AppAuthStatus.cashierAuthenticated && state.matchedLocation == RouteConstants.cashierLogin) return RouteConstants.cashierHome;

      return null;
    },
    routes: [
      GoRoute(path: RouteConstants.splash, builder: (context, state) => const PlaceholderScreen('Splash')),
      GoRoute(path: RouteConstants.roleSelect, builder: (context, state) => const PlaceholderScreen('Role Selection')),
      
      // Cashier
      GoRoute(path: RouteConstants.cashierLogin, builder: (context, state) => const PlaceholderScreen('Cashier Login')),
      GoRoute(path: RouteConstants.cashierHome, builder: (context, state) => const PlaceholderScreen('Cashier Home')),
      GoRoute(path: RouteConstants.cashierMenu, builder: (context, state) => const PlaceholderScreen('Menu')),
      GoRoute(path: RouteConstants.cashierCart, builder: (context, state) => const PlaceholderScreen('Cart')),
      GoRoute(path: RouteConstants.cashierCheckout, builder: (context, state) => const PlaceholderScreen('Checkout')),
      GoRoute(path: RouteConstants.cashierPaymentSuccess, builder: (context, state) => const PlaceholderScreen('Payment Success')),
      GoRoute(path: RouteConstants.cashierOrderHistory, builder: (context, state) => const PlaceholderScreen('Order History')),
      GoRoute(path: RouteConstants.cashierProfile, builder: (context, state) => const PlaceholderScreen('Profile')),

      // Admin
      GoRoute(path: RouteConstants.adminLogin, builder: (context, state) => const PlaceholderScreen('Admin Login')),
      GoRoute(path: RouteConstants.adminHome, builder: (context, state) => const PlaceholderScreen('Admin Home')),
      GoRoute(path: RouteConstants.adminUsers, builder: (context, state) => const PlaceholderScreen('Manage Users')),
      GoRoute(path: RouteConstants.adminUserForm, builder: (context, state) => const PlaceholderScreen('User Details')),
      GoRoute(path: RouteConstants.adminMenu, builder: (context, state) => const PlaceholderScreen('Menu Settings')),
      GoRoute(path: RouteConstants.adminMenuCategory, builder: (context, state) => const PlaceholderScreen('Categories')),
      GoRoute(path: RouteConstants.adminMenuItems, builder: (context, state) => const PlaceholderScreen('Menu Items')),
      GoRoute(path: RouteConstants.adminMenuItemForm, builder: (context, state) => const PlaceholderScreen('Item Details')),
      GoRoute(path: RouteConstants.adminInventory, builder: (context, state) => const PlaceholderScreen('Inventory')),
      GoRoute(path: RouteConstants.adminOrders, builder: (context, state) => const PlaceholderScreen('Order Management')),
      GoRoute(path: RouteConstants.adminVoidRefund, builder: (context, state) => const PlaceholderScreen('Void/Refund')),
      GoRoute(path: RouteConstants.adminReports, builder: (context, state) => const PlaceholderScreen('Reports')),
      GoRoute(path: RouteConstants.adminEndOfDay, builder: (context, state) => const PlaceholderScreen('End of Day')),
      GoRoute(path: RouteConstants.adminSettings, builder: (context, state) => const PlaceholderScreen('General Settings')),
    ],
  );
});
