import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'screens/configuracoes_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tarefas_screen.dart';
import 'themes/app_theme.dart';
import 'themes/theme_controller.dart';
import 'widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Recupera o tema salvo (SharedPreferences) antes de desenhar o app.
  await ThemeController.instance.carregar();
  runApp(const MinhasTarefasApp());
}

class MinhasTarefasApp extends StatelessWidget {
  const MinhasTarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = ThemeController.instance;

    // Ao mudar o tema, todo o MaterialApp (e portanto todas as telas,
    // inclusive login e cadastro) é reconstruído.
    return ListenableBuilder(
      listenable: tema,
      builder: (context, _) => MaterialApp(
        title: 'Minhas Tarefas',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: tema.themeMode,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: '/',
        routes: {
          '/': (_) => const AuthGate(),
          '/home': (_) => HomeScreen(),
          '/tarefas': (_) => const TarefasScreen(),
          '/configuracoes': (_) => const ConfiguracoesScreen(),
        },
      ),
    );
  }
}
