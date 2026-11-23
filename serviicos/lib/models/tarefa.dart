/// Prioridade de uma tarefa.
enum Prioridade {
  baixa('Baixa'),
  media('Média'),
  alta('Alta');

  final String rotulo;
  const Prioridade(this.rotulo);

  /// Reconstrói a prioridade a partir do nome salvo no banco.
  static Prioridade fromNome(String? nome) {
    return Prioridade.values.firstWhere(
      (p) => p.name == nome,
      orElse: () => Prioridade.media,
    );
  }
}

/// Representa uma tarefa do usuário.
class Tarefa {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataVencimento;
  final Prioridade prioridade;
  final bool concluida;

  const Tarefa({
    this.id = '',
    required this.titulo,
    this.descricao = '',
    required this.dataVencimento,
    this.prioridade = Prioridade.media,
    this.concluida = false,
  });

  /// Converte para o formato salvo no Realtime Database.
  /// O [id] é a chave do nó, por isso não entra no mapa.
  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descricao': descricao,
        'dataVencimento': dataVencimento.millisecondsSinceEpoch,
        'prioridade': prioridade.name,
        'concluida': concluida,
      };

  factory Tarefa.fromMap(String id, Map<dynamic, dynamic> map) {
    final millis = (map['dataVencimento'] as num?)?.toInt() ?? 0;
    return Tarefa(
      id: id,
      titulo: (map['titulo'] ?? '').toString(),
      descricao: (map['descricao'] ?? '').toString(),
      dataVencimento: DateTime.fromMillisecondsSinceEpoch(millis),
      prioridade: Prioridade.fromNome(map['prioridade']?.toString()),
      concluida: map['concluida'] == true,
    );
  }

  Tarefa copyWith({
    String? id,
    String? titulo,
    String? descricao,
    DateTime? dataVencimento,
    Prioridade? prioridade,
    bool? concluida,
  }) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      prioridade: prioridade ?? this.prioridade,
      concluida: concluida ?? this.concluida,
    );
  }

  /// Verdadeiro se a tarefa está pendente e o vencimento já passou (por dia).
  bool get atrasada {
    if (concluida) return false;
    final hoje = DateTime.now();
    final dia = DateTime(hoje.year, hoje.month, hoje.day);
    final venc = DateTime(
      dataVencimento.year,
      dataVencimento.month,
      dataVencimento.day,
    );
    return venc.isBefore(dia);
  }
}
