import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/firebase_service.dart';
import '../widgets/tarefa_tile.dart';

/// Cria uma nova tarefa ou edita uma existente (quando [tarefa] é informada).
class CadastroTarefaScreen extends StatefulWidget {
  final Tarefa? tarefa;

  const CadastroTarefaScreen({super.key, this.tarefa});

  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late DateTime _dataVencimento;
  late Prioridade _prioridade;
  late bool _concluida;
  bool _salvando = false;

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tarefa;
    _tituloController = TextEditingController(text: t?.titulo ?? '');
    _descricaoController = TextEditingController(text: t?.descricao ?? '');
    _dataVencimento = t?.dataVencimento ?? DateTime.now();
    _prioridade = t?.prioridade ?? Prioridade.media;
    _concluida = t?.concluida ?? false;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataVencimento,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Data de vencimento',
    );
    if (data != null) setState(() => _dataVencimento = data);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final tarefa = Tarefa(
      id: widget.tarefa?.id ?? '',
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      dataVencimento: _dataVencimento,
      prioridade: _prioridade,
      concluida: _concluida,
    );

    try {
      if (_editando) {
        await FirebaseService.instance.atualizar(tarefa);
      } else {
        await FirebaseService.instance.adicionar(tarefa);
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _editando ? 'Tarefa atualizada.' : 'Tarefa cadastrada.',
            ),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Erro ao salvar a tarefa.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar tarefa' : 'Nova tarefa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _escolherData,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de vencimento',
                    prefixIcon: Icon(Icons.event),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  child: Text(formatoData.format(_dataVencimento)),
                ),
              ),
              const SizedBox(height: 24),
              Text('Prioridade',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<Prioridade>(
                showSelectedIcon: false,
                segments: [
                  for (final p in Prioridade.values)
                    ButtonSegment(
                      value: p,
                      label: Text(p.rotulo),
                      icon: Icon(Icons.flag, color: p.cor),
                    ),
                ],
                selected: {_prioridade},
                onSelectionChanged: (s) =>
                    setState(() => _prioridade = s.first),
              ),
              const SizedBox(height: 24),
              Text('Situação', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Pendente'),
                    icon: Icon(Icons.hourglass_empty),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Concluída'),
                    icon: Icon(Icons.check_circle_outline),
                  ),
                ],
                selected: {_concluida},
                onSelectionChanged: (s) =>
                    setState(() => _concluida = s.first),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_editando ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
