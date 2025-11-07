import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/audio_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'core/themes/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
      ],
      child: MaterialApp(
        title: 'Music Showcase',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (_) => const SplashScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
