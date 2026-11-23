import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

/// Decide a tela inicial conforme a sessão do Firebase:
/// logado -> Home; deslogado -> Login. Como o Firebase mantém a sessão,
/// o usuário continua autenticado ao fechar e reabrir o app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.mudancasDeUsuario,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // Não usar const: precisa reconstruir quando o perfil mudar.
          return HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
