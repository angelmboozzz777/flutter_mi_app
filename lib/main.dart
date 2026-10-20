import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'theme/game_theme.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GameStore',
      theme: GameTheme.tema,
      home: const LoginPage(),
    );
  }
}
