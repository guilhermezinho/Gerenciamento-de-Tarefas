import 'package:shared_preferences/shared_preferences.dart';

/// Acesso às preferências locais (SharedPreferences).
class PreferencesService {
  static const String _chaveTemaEscuro = 'tema_escuro';

  /// Retorna true se o usuário escolheu o tema escuro. Padrão: claro.
  Future<bool> carregarTemaEscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveTemaEscuro) ?? false;
  }

  Future<void> salvarTemaEscuro(bool escuro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveTemaEscuro, escuro);
  }
}
