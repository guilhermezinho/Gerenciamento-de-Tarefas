import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../themes/theme_controller.dart';
import '../widgets/drawer_menu.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = ThemeController.instance;
    final usuario = AuthService.instance.usuarioAtual;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      drawer: const DrawerMenu(rotaAtual: '/configuracoes'),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Aparência',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListenableBuilder(
            listenable: tema,
            builder: (context, _) => SwitchListTile(
              secondary: Icon(tema.escuro ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Tema escuro'),
              subtitle: Text(
                tema.escuro ? 'Tema escuro ativado' : 'Tema claro ativado',
              ),
              value: tema.escuro,
              onChanged: (valor) => tema.definirEscuro(valor),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Conta',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(usuario?.nome ?? ''),
            subtitle: Text(usuario?.email ?? ''),
          ),
        ],
      ),
    );
  }
}
