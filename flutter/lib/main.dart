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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Restore saved token + user from disk, then kick off background fetches.
  final appState = AppState();
  await appState.init();

  runApp(NvElonApp(appState: appState));
}

class NvElonApp extends StatelessWidget {
  final AppState appState;
  const NvElonApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: appState,
      child: ListenableBuilder(
        listenable: appState,
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
