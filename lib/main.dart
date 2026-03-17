import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_t_hero/screens/auth/splash_screen.dart';
import 'package:frontend_t_hero/utils/themes/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'T Hero — بطل تونس',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}