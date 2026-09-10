import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'splash/animated_splash.dart';
import 'chat/chat_screen.dart';

void main() {
  runApp(const SarahApp());
}

class SarahApp extends StatelessWidget {
  const SarahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sarah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedSplash(
        onComplete: () async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        next: const ChatScreen(),
      ),
    );
  }
}
