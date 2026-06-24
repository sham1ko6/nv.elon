// ============================================================
// main.dart  –  nv.elon App Entry Point
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar with DARK icons (we now use a light background).
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const NvElonApp());
}

class NvElonApp extends StatefulWidget {
  const NvElonApp({super.key});

  @override
  State<NvElonApp> createState() => _NvElonAppState();
}

class _NvElonAppState extends State<NvElonApp> {
  final _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: _appState,
      child: ListenableBuilder(
        listenable: _appState,
        builder: (ctx, _) {
          return MaterialApp(
            title: 'nv.elon',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            initialRoute: '/splash',
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/auth': (_) => const AuthScreen(),
              '/home': (_) => const MainShell(),
            },
          );
        },
      ),
    );
  }
}
