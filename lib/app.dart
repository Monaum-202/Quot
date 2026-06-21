import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'package:hive/hive.dart';
import 'core/constants/hive_box_names.dart';
import 'core/services/google_drive_service.dart';
import 'features/home/presentation/screens/main_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _performAutoBackup();
    }
  }

  Future<void> _performAutoBackup() async {
    final box = Hive.box(HiveBoxNames.settings);
    final isEnabled = box.get('auto_backup', defaultValue: false);
    
    if (isEnabled) {
      await GoogleDriveService().backupToDrive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
