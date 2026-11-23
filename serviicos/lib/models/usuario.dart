/// Representa o usuário autenticado no aplicativo.
class Usuario {
  final String uid;
  final String nome;
  final String email;

  const Usuario({
    required this.uid,
    required this.nome,
    required this.email,
  });

  /// Converte para o formato salvo no Realtime Database.
  /// O [uid] é usado como chave do nó, por isso não entra no mapa.
  Map<String, dynamic> toMap() => {
        'nome': nome,
        'email': email,
      };

  factory Usuario.fromMap(String uid, Map<dynamic, dynamic> map) {
    return Usuario(
      uid: uid,
      nome: (map['nome'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
    );
  }

  /// Primeiro nome, usado em saudações.
  String get primeiroNome {
    final partes = nome.trim().split(RegExp(r'\s+'));
    return partes.first.isEmpty ? nome : partes.first;
  }

  /// Inicial do nome, usada no avatar.
  String get inicial => nome.trim().isEmpty ? '?' : nome.trim()[0].toUpperCase();
}
