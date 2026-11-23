import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

/// Controla o ThemeMode do app e o persiste com SharedPreferences.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  final PreferencesService _prefs = PreferencesService();

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get escuro => _themeMode == ThemeMode.dark;

  /// Lê a preferência salva (chamar antes do runApp).
  Future<void> carregar() async {
    final escuro = await _prefs.carregarTemaEscuro();
    _themeMode = escuro ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> definirEscuro(bool escuro) async {
    _themeMode = escuro ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _prefs.salvarTemaEscuro(escuro);
  }
}
