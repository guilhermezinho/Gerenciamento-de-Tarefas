import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuração do Firebase do projeto "cadastro-de-servico".
/// Suporta Web (Chrome) e Android.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Plataforma não suportada. Use Android ou Web (Chrome).',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDGwquudthfBlKapBScrEhEJkhIZ_4UrkM',
    appId: '1:824463007201:web:76c027bb81f6544bc146a0',
    messagingSenderId: '824463007201',
    projectId: 'cadastro-de-servico',
    authDomain: 'cadastro-de-servico.firebaseapp.com',
    databaseURL: 'https://cadastro-de-servico-default-rtdb.firebaseio.com',
    storageBucket: 'cadastro-de-servico.firebasestorage.app',
    measurementId: 'G-JG33ZFGZ5G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4c3nBXJblVdBVWW3KX3hj6P9uwCdG7fY',
    appId: '1:824463007201:android:b6bd534341c45f36c146a0',
    messagingSenderId: '824463007201',
    projectId: 'cadastro-de-servico',
    databaseURL: 'https://cadastro-de-servico-default-rtdb.firebaseio.com',
    storageBucket: 'cadastro-de-servico.firebasestorage.app',
  );
}
