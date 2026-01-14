import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  ThemeMode _themeMode = ThemeMode.light;
  AccentTheme _accentTheme = AccentTheme.indigo;

  ThemeProvider(this.prefs) {
    _loadThemeSettings();
  }

  ThemeMode get themeMode => _themeMode;
  AccentTheme get accentTheme => _accentTheme;

  void _loadThemeSettings() {
    final savedThemeMode = prefs.getString('taskflow_theme_mode');
    final savedAccentTheme = prefs.getString('taskflow_accent_theme');

    if (savedThemeMode != null) {
      _themeMode = savedThemeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }

    if (savedAccentTheme != null) {
      _accentTheme = AccentTheme.values.firstWhere(
        (theme) => theme.value == savedAccentTheme,
        orElse: () => AccentTheme.indigo,
      );
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await prefs.setString('taskflow_theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setAccentTheme(AccentTheme theme) async {
    _accentTheme = theme;
    await prefs.setString('taskflow_accent_theme', theme.value);
    notifyListeners();
  }

  Color get accentColor {
    switch (_accentTheme) {
      case AccentTheme.indigo:
        return Colors.indigo;
      case AccentTheme.rose:
        return Colors.pink;
      case AccentTheme.emerald:
        return const Color(0xFF10B981);
      case AccentTheme.amber:
        return Colors.amber;
      case AccentTheme.violet:
        return Colors.purple;
    }
  }

  Color get accentColorLight {
    switch (_accentTheme) {
      case AccentTheme.indigo:
        return const Color(0xFF4F46E5);
      case AccentTheme.rose:
        return const Color(0xFFF43F5E);
      case AccentTheme.emerald:
        return const Color(0xFF10B981);
      case AccentTheme.amber:
        return const Color(0xFFF59E0B);
      case AccentTheme.violet:
        return const Color(0xFF8B5CF6);
    }
  }

  Color get accentColorDark {
    switch (_accentTheme) {
      case AccentTheme.indigo:
        return const Color(0xFF6366F1);
      case AccentTheme.rose:
        return const Color(0xFFFB7185);
      case AccentTheme.emerald:
        return const Color(0xFF34D399);
      case AccentTheme.amber:
        return const Color(0xFFFBBF24);
      case AccentTheme.violet:
        return const Color(0xFFA78BFA);
    }
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColorLight,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withOpacity(0.8),
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1E293B),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColorLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColorLight, width: 2),
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColorDark,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F172A).withOpacity(0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF0F172A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColorDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColorDark, width: 2),
        ),
      ),
    );
  }
}
