import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final state = AppState();
  await state.init();
  runApp(AppStateScope(notifier: state, child: const RavoqApp()));
}

class RavoqApp extends StatelessWidget {
  const RavoqApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return MaterialApp(
      title: 'Ravoq',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: state.themeMode,
      home: const SplashScreen(),
    );
  }
}
