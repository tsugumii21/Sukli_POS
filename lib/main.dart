import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/isar_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/sync_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize core services
  await IsarService.instance.init();
  await SupabaseService.instance.init();
  SyncService.instance.startPeriodicSync();

  runApp(const ProviderScope(child: SukliPosApp()));
}
