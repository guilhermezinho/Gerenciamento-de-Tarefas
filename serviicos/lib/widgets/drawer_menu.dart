import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Menu lateral (Drawer) com dados do usuário e navegação.
class DrawerMenu extends StatelessWidget {
  /// Rota da tela atual, para destacar o item selecionado.
  final String rotaAtual;

  const DrawerMenu({super.key, required this.rotaAtual});

  void _ir(BuildContext context, String rota) {
    Navigator.pop(context); // fecha o drawer
    if (rota != rotaAtual) {
      Navigator.pushReplacementNamed(context, rota);
    }
  }

  Future<void> _sair(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    await AuthService.instance.logout();
    if (!context.mounted) return;
    // Volta para o AuthGate, que mostrará a tela de login.
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService.instance.usuarioAtual;
    final esquema = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: esquema.primary),
            accountName: Text(
              usuario?.nome ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: esquema.onPrimary,
              ),
            ),
            accountEmail: Text(
              usuario?.email ?? '',
              style: TextStyle(color: esquema.onPrimary),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: esquema.onPrimary,
              child: Text(
                usuario?.inicial ?? '?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: esquema.primary,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Início'),
            selected: rotaAtual == '/home',
            onTap: () => _ir(context, '/home'),
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Minhas tarefas'),
            selected: rotaAtual == '/tarefas',
            onTap: () => _ir(context, '/tarefas'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            selected: rotaAtual == '/configuracoes',
            onTap: () => _ir(context, '/configuracoes'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre o aplicativo'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Minhas Tarefas',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.task_alt, size: 40),
                children: const [
                  Text(
                    'Aplicativo de gerenciamento de tarefas pessoais '
                    'desenvolvido em Flutter, com Firebase Authentication, '
                    'Firebase Realtime Database e SharedPreferences.',
                  ),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () => _sair(context),
          ),
        ],
      ),
    );
  }
}
