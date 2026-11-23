import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/drawer_menu.dart';
import 'cadastro_tarefa_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final Stream<List<Tarefa>> _tarefas =
      FirebaseService.instance.observarTarefas();

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService.instance.usuarioAtual;

    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      drawer: const DrawerMenu(rotaAtual: '/home'),
      body: StreamBuilder<List<Tarefa>>(
        stream: _tarefas,
        builder: (context, snapshot) {
          final tarefas = snapshot.data ?? const <Tarefa>[];
          final total = tarefas.length;
          final concluidas = tarefas.where((t) => t.concluida).length;
          final pendentes = total - concluidas;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Olá, ${usuario?.nome ?? ''}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Veja o resumo das suas tarefas.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              if (snapshot.hasError)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Não foi possível carregar as tarefas. '
                      'Verifique sua conexão e as regras do banco.',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  _ResumoCard(
                    titulo: 'Cadastradas',
                    valor: total,
                    icone: Icons.list_alt,
                    cor: Colors.indigo,
                  ),
                  _ResumoCard(
                    titulo: 'Pendentes',
                    valor: pendentes,
                    icone: Icons.hourglass_bottom,
                    cor: Colors.orange,
                  ),
                  _ResumoCard(
                    titulo: 'Concluídas',
                    valor: concluidas,
                    icone: Icons.check_circle,
                    cor: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Nova tarefa'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CadastroTarefaScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.checklist),
                label: const Text('Ver minhas tarefas'),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/tarefas'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String titulo;
  final int valor;
  final IconData icone;
  final Color cor;

  const _ResumoCard({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icone, color: cor, size: 30),
              const SizedBox(height: 8),
              Text(
                '$valor',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                titulo,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
