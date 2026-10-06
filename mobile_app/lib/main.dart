import 'package:flutter/material.dart';
import 'screens/connection_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(SmartGlassesApp());
}

class SmartGlassesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Glasses Uplink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accentCyan,
          surface: AppColors.cardColor,
        ),
        fontFamily: 'Roboto', // Modern, clean font
      ),
      home: ConnectionScreen(),
    );
  }
}