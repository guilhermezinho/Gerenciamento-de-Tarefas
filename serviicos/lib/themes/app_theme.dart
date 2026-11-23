import 'package:flutter/material.dart';

/// Temas claro e escuro da aplicação.
class AppTheme {
  AppTheme._();

  static const Color _corBase = Colors.indigo;

  static ThemeData get lightTheme => _construir(Brightness.light);
  static ThemeData get darkTheme => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brilho) {
    final esquema = ColorScheme.fromSeed(
      seedColor: _corBase,
      brightness: brilho,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
      ),
    );
  }
}
