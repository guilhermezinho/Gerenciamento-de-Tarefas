import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/firebase_service.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/tarefa_tile.dart';
import 'cadastro_tarefa_screen.dart';

enum _Filtro { todas, pendentes, concluidas }

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  // Listener em tempo real do Realtime Database.
  late final Stream<List<Tarefa>> _tarefas =
      FirebaseService.instance.observarTarefas();
  _Filtro _filtro = _Filtro.todas;

  List<Tarefa> _filtrar(List<Tarefa> tarefas) {
    switch (_filtro) {
      case _Filtro.todas:
        return tarefas;
      case _Filtro.pendentes:
        return tarefas.where((t) => !t.concluida).toList();
      case _Filtro.concluidas:
        return tarefas.where((t) => t.concluida).toList();
    }
  }

  void _abrirCadastro([Tarefa? tarefa]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CadastroTarefaScreen(tarefa: tarefa)),
    );
  }

  Future<void> _confirmarExclusao(Tarefa tarefa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja excluir "${tarefa.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await FirebaseService.instance.excluir(tarefa.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Tarefa excluída.')));
  }

  /// Detalhes da tarefa selecionada, com ações de editar, excluir e
  /// alterar a situação.
  void _mostrarDetalhes(Tarefa tarefa) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tarefa.titulo,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                tarefa.descricao.isEmpty
                    ? 'Sem descrição.'
                    : tarefa.descricao,
                style: Theme.of(ctx).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _linhaDetalhe(
                Icons.event,
                'Vencimento',
                formatoData.format(tarefa.dataVencimento),
              ),
              _linhaDetalhe(
                Icons.flag,
                'Prioridade',
                tarefa.prioridade.rotulo,
                cor: tarefa.prioridade.cor,
              ),
              _linhaDetalhe(
                tarefa.concluida ? Icons.check_circle : Icons.hourglass_empty,
                'Situação',
                tarefa.concluida ? 'Concluída' : 'Pendente',
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    icon: Icon(
                      tarefa.concluida ? Icons.undo : Icons.check,
                    ),
                    label: Text(
                      tarefa.concluida
                          ? 'Marcar como pendente'
                          : 'Marcar como concluída',
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      FirebaseService.instance.alternarSituacao(tarefa);
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _abrirCadastro(tarefa);
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(ctx).colorScheme.error,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmarExclusao(tarefa);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linhaDetalhe(IconData icone, String rotulo, String valor,
      {Color? cor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icone, size: 20, color: cor),
          const SizedBox(width: 8),
          Text('$rotulo: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(valor),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas tarefas')),
      drawer: const DrawerMenu(rotaAtual: '/tarefas'),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova tarefa',
        onPressed: () => _abrirCadastro(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: SegmentedButton<_Filtro>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: _Filtro.todas, label: Text('Todas')),
                ButtonSegment(
                    value: _Filtro.pendentes, label: Text('Pendentes')),
                ButtonSegment(
                    value: _Filtro.concluidas, label: Text('Concluídas')),
              ],
              selected: {_filtro},
              onSelectionChanged: (s) => setState(() => _filtro = s.first),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Tarefa>>(
              stream: _tarefas,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Não foi possível carregar as tarefas. '
                        'Verifique sua conexão e as regras do banco.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tarefas = _filtrar(snapshot.data!);
                if (tarefas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inbox_outlined, size: 64),
                        const SizedBox(height: 8),
                        Text(
                          _filtro == _Filtro.todas
                              ? 'Nenhuma tarefa cadastrada.\n'
                                  'Toque em + para criar a primeira.'
                              : 'Nenhuma tarefa nesta categoria.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88, top: 4),
                  itemCount: tarefas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefas[index];
                    return TarefaTile(
                      key: ValueKey(tarefa.id),
                      tarefa: tarefa,
                      onTap: () => _mostrarDetalhes(tarefa),
                      onAlternar: (_) =>
                          FirebaseService.instance.alternarSituacao(tarefa),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
