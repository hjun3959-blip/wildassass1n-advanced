import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF09090B);
  static const Color card = Color(0xFF18181B);
  static const Color border = Color(0xFF27272A);
  static const Color text = Color(0xFFE4E4E7);
  static const Color muted = Color(0xFF71717A);
  static const Color purple = Color(0xFF6366F1);
  static const Color indigo = Color(0xFFA855F7);
  static const Color green = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color coral = Color(0xFFEF4444);
  static const Color blue = Color(0xFF3B82F6);
  static const Color ocean = Color(0xFF06B6D4);
  static const Color red = Color(0xFFEF4444);
  static const Color white = Color(0xFFFFFFFF);

  static final CupertinoThemeData dark = CupertinoThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    primaryColor: purple,
    textTheme: CupertinoTextThemeData(
      primaryColor: text,
      textStyle: const TextStyle(fontFamily: '.SF Pro Display', color: text, fontSize: 14),
    ),
  );

  static BoxDecoration cardStyle = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: border, width: 1),
  );
}

extension ContextTheme on BuildContext {
  AppTheme get theme => AppTheme;
}