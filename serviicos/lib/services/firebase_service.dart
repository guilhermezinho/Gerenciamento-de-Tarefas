import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/tarefa.dart';

/// CRUD das tarefas no Firebase Realtime Database.
///
/// Estrutura no banco:  tarefas/{uid}/{idDaTarefa}
/// O uid SEMPRE vem do usuário autenticado, então cada usuário só
/// consegue ler e gravar o próprio nó (reforçado também pelas regras
/// do banco, veja database.rules.json).
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Nenhum usuário autenticado.');
    }
    return user.uid;
  }

  DatabaseReference get _tarefasRef =>
      FirebaseDatabase.instance.ref('tarefas/$_uid');

  /// Listener em tempo real: emite a lista completa sempre que algo muda
  /// (criação, edição, exclusão, inclusive vindas de outros dispositivos).
  Stream<List<Tarefa>> observarTarefas() {
    return _tarefasRef.onValue.map((event) {
      final valor = event.snapshot.value;
      final tarefas = <Tarefa>[];
      if (valor is Map) {
        valor.forEach((chave, dados) {
          if (dados is Map) {
            tarefas.add(Tarefa.fromMap(chave.toString(), dados));
          }
        });
      }
      tarefas.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
      return tarefas;
    });
  }

  /// Create
  Future<void> adicionar(Tarefa tarefa) {
    final novoNo = _tarefasRef.push();
    return _aguardar(novoNo.set(tarefa.toMap()));
  }

  /// Update
  Future<void> atualizar(Tarefa tarefa) {
    return _aguardar(_tarefasRef.child(tarefa.id).set(tarefa.toMap()));
  }

  /// Alterna entre pendente e concluída.
  Future<void> alternarSituacao(Tarefa tarefa) {
    return _aguardar(
      _tarefasRef.child(tarefa.id).update({'concluida': !tarefa.concluida}),
    );
  }

  /// Delete
  Future<void> excluir(String id) {
    return _aguardar(_tarefasRef.child(id).remove());
  }

  /// Read (consulta pontual)
  Future<Tarefa?> buscar(String id) async {
    final snapshot = await _tarefasRef.child(id).get();
    final valor = snapshot.value;
    if (valor is Map) return Tarefa.fromMap(id, valor);
    return null;
  }

  /// Sem internet, o Realtime Database grava localmente e só confirma o
  /// Future quando reconectar. Para não travar a interface, esperamos no
  /// máximo alguns segundos; a gravação continua e sincroniza depois.
  Future<void> _aguardar(Future<void> operacao) async {
    try {
      await operacao.timeout(const Duration(seconds: 8));
    } on TimeoutException {
      // Offline: o dado já está no cache local e será sincronizado.
    }
  }
}
