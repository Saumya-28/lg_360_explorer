import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/home_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: LGStarterApp(),
    ),
  );
}

class LGStarterApp extends StatelessWidget {
  const LGStarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LG Explorer 360',
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false, // Ensure green bars are off
      debugShowMaterialGrid: false,
      showSemanticsDebugger: false,
      checkerboardRasterCacheImages: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
