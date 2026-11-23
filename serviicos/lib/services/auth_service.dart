import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/usuario.dart';

/// Erro de autenticação com mensagem já traduzida para o usuário.
class AuthException implements Exception {
  final String mensagem;
  const AuthException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Encapsula o Firebase Authentication (e-mail e senha).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Emite um evento sempre que o usuário entra, sai ou altera o perfil.
  /// O Firebase restaura a sessão sozinho ao reabrir o app.
  Stream<User?> get mudancasDeUsuario => _auth.userChanges();

  User? get usuarioFirebase => _auth.currentUser;

  /// Usuário atual convertido para o Model [Usuario] (ou null se deslogado).
  Usuario? get usuarioAtual {
    final user = _auth.currentUser;
    if (user == null) return null;
    final email = user.email ?? '';
    final nome = (user.displayName != null && user.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (email.contains('@') ? email.split('@').first : 'Usuário');
    return Usuario(uid: user.uid, nome: nome, email: email);
  }

  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      final user = cred.user!;
      await user.updateDisplayName(nome.trim());
      await user.reload();

      final usuario = Usuario(
        uid: user.uid,
        nome: nome.trim(),
        email: user.email ?? email.trim(),
      );

      // Perfil também é salvo no Realtime Database (melhor esforço:
      // se falhar, o nome continua disponível no Firebase Authentication).
      try {
        await FirebaseDatabase.instance
            .ref('usuarios/${user.uid}')
            .set(usuario.toMap())
            .timeout(const Duration(seconds: 8));
      } catch (_) {}

      return usuario;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzirErro(e.code));
    }
  }

  Future<void> login({required String email, required String senha}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzirErro(e.code));
    }
  }

  Future<void> logout() => _auth.signOut();

  String _traduzirErro(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'Senha fraca. Use pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Login por e-mail/senha não está habilitado no Firebase.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro de autenticação ($codigo).';
    }
  }
}
