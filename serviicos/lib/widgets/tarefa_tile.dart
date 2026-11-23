import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/tarefa.dart';

final DateFormat formatoData = DateFormat('dd/MM/yyyy');

/// Cor e ícone associados a cada prioridade.
extension PrioridadeVisual on Prioridade {
  Color get cor {
    switch (this) {
      case Prioridade.baixa:
        return Colors.green;
      case Prioridade.media:
        return Colors.orange;
      case Prioridade.alta:
        return Colors.red;
    }
  }

  IconData get icone {
    switch (this) {
      case Prioridade.baixa:
        return Icons.keyboard_arrow_down;
      case Prioridade.media:
        return Icons.drag_handle;
      case Prioridade.alta:
        return Icons.priority_high;
    }
  }
}

/// Item da lista de tarefas (usado dentro do ListView).
class TarefaTile extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback onTap;
  final ValueChanged<bool?> onAlternar;

  const TarefaTile({
    super.key,
    required this.tarefa,
    required this.onTap,
    required this.onAlternar,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final cor = tarefa.prioridade.cor;
    final corData = tarefa.atrasada ? esquema.error : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: tarefa.concluida, onChanged: onAlternar),
        title: Text(
          tarefa.titulo,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 12,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event, size: 16, color: corData),
                  const SizedBox(width: 4),
                  Text(
                    formatoData.format(tarefa.dataVencimento) +
                        (tarefa.atrasada ? ' (atrasada)' : ''),
                    style: TextStyle(color: corData),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flag, size: 16, color: cor),
                  const SizedBox(width: 4),
                  Text(tarefa.prioridade.rotulo),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tarefa.concluida
                        ? Icons.check_circle
                        : Icons.hourglass_empty,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(tarefa.concluida ? 'Concluída' : 'Pendente'),
                ],
              ),
            ],
          ),
        ),
        trailing: CircleAvatar(
          radius: 16,
          backgroundColor: cor.withValues(alpha: 0.18),
          child: Icon(tarefa.prioridade.icone, color: cor, size: 20),
        ),
      ),
    );
  }
}
