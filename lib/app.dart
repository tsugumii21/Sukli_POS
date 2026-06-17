import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'app_router.dart';

class SukliPosApp extends ConsumerStatefulWidget {
  const SukliPosApp({super.key});

  @override
  ConsumerState<SukliPosApp> createState() => _SukliPosAppState();
}

class _SukliPosAppState extends ConsumerState<SukliPosApp> {

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Sukli',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
    );
  }
}
