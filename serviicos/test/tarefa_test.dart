import 'package:flutter_test/flutter_test.dart';
import 'package:serviicos/models/tarefa.dart';
import 'package:serviicos/models/usuario.dart';

void main() {
  test('Tarefa converte para Map e de volta', () {
    final original = Tarefa(
      id: 'abc',
      titulo: 'Estudar Flutter',
      descricao: 'Revisar Drawer e ListView',
      dataVencimento: DateTime(2026, 12, 1),
      prioridade: Prioridade.alta,
      concluida: true,
    );

    final copia = Tarefa.fromMap('abc', original.toMap());

    expect(copia.id, 'abc');
    expect(copia.titulo, original.titulo);
    expect(copia.descricao, original.descricao);
    expect(copia.dataVencimento, original.dataVencimento);
    expect(copia.prioridade, Prioridade.alta);
    expect(copia.concluida, isTrue);
  });

  test('Prioridade desconhecida vira média', () {
    expect(Prioridade.fromNome('xyz'), Prioridade.media);
  });

  test('Tarefa pendente com data passada está atrasada', () {
    final t = Tarefa(
      titulo: 'x',
      dataVencimento: DateTime.now().subtract(const Duration(days: 3)),
    );
    expect(t.atrasada, isTrue);
    expect(t.copyWith(concluida: true).atrasada, isFalse);
  });

  test('Usuario converte para Map e de volta', () {
    const u = Usuario(uid: 'u1', nome: 'Guilherme Santana', email: 'g@x.com');
    final copia = Usuario.fromMap('u1', u.toMap());
    expect(copia.nome, u.nome);
    expect(copia.email, u.email);
    expect(u.primeiroNome, 'Guilherme');
    expect(u.inicial, 'G');
  });
}
