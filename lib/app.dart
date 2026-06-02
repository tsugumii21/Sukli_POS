import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/route_constants.dart';
import 'core/services/supabase_service.dart';
import 'shared/providers/theme_provider.dart';
import 'app_router.dart';

class SukliPosApp extends ConsumerStatefulWidget {
  const SukliPosApp({super.key});

  @override
  ConsumerState<SukliPosApp> createState() => _SukliPosAppState();
}

class _SukliPosAppState extends ConsumerState<SukliPosApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  Future<void> _handleIncomingLinks() async {
    // Handle cold start — app opened via deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('Initial deep link: $initialUri');
        await _processAuthLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Handle warm start — app already running
    _linkSub = _appLinks.uriLinkStream.listen(
      (uri) async {
        debugPrint('Deep link received: $uri');
        await _processAuthLink(uri);
      },
      onError: (e) => debugPrint('Deep link stream error: $e'),
    );
  }

  Future<void> _processAuthLink(Uri uri) async {
    debugPrint('Processing auth link: $uri');
    debugPrint('Scheme: ${uri.scheme}');
    debugPrint('Host: ${uri.host}');
    debugPrint('Fragment: ${uri.fragment}');
    debugPrint('Query: ${uri.query}');

    // Handle both fragment (#) and query (?) token formats
    final fragment = uri.fragment.isNotEmpty ? uri.fragment : uri.query;
    final params = Uri.splitQueryString(fragment);

    final accessToken = params['access_token'];
    final refreshToken = params['refresh_token'];
    final type = params['type'];

    debugPrint('Access token present: ${accessToken != null}');
    debugPrint('Type: $type');

    if (accessToken != null && refreshToken != null) {
      try {
        await SupabaseService.instance.client.auth.setSession(accessToken);
        debugPrint('Session set successfully');

        if (mounted) {
          // Small delay to let auth state update
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            ref.read(appRouterProvider).go(RouteConstants.adminLogin);
          }
        }
      } catch (e) {
        debugPrint('Error setting session: $e');
      }
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Sukli',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
