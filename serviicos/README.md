# Minhas Tarefas (serviicos)

Aplicativo em **Flutter** para gerenciamento de tarefas pessoais, com
**Firebase Authentication** (e-mail/senha), **Firebase Realtime Database**
e **SharedPreferences**. Roda em **Android** e **Web (Chrome)**.

## Pré-requisitos
- Flutter SDK instalado (`flutter doctor` sem erros)
- Android Studio / emulador Android (ou aparelho com depuração USB)
- Google Chrome (para rodar na web)

## Configuração do Firebase

Projeto Firebase utilizado: **cadastro-de-servico**.

| Plataforma | ID do aplicativo |
|---|---|
| Web | `1:824463007201:web:76c027bb81f6544bc146a0` |
| Android (`com.company.servico`) | `1:824463007201:android:b6bd534341c45f36c146a0` |

A configuração já está pronta em:
- `lib/firebase_options.dart` -> `DefaultFirebaseOptions.web` e `.android`
  (escolhidas automaticamente por `currentPlatform`, equivalentes ao
  `firebaseConfig` do SDK JavaScript do Firebase);
- `android/app/google-services.json` -> configuração nativa do Android.

Para usar **outro** projeto Firebase, rode `flutterfire configure` na raiz
(ele regenera `lib/firebase_options.dart` e o `google-services.json`).

### Ajustes no Console do Firebase (uma única vez)
1. **Authentication -> Sign-in method:** habilitar **E-mail/senha**.
2. **Authentication -> Settings -> Authorized domains:** garantir `localhost`.
3. **Realtime Database:** criar o banco e, na aba **Regras**, colar o
   conteúdo de `database.rules.json` e **Publicar** (cada usuário só acessa
   `tarefas/{seu uid}`).
4. No Google Cloud Console, as chaves de API do projeto não podem estar
   restritas de forma que bloqueiem a *Identity Toolkit API*.

## Como executar

```bash
flutter clean
flutter pub get

flutter run -d chrome          # Web
flutter devices                # lista os dispositivos
flutter run -d <id-android>    # Android (emulador ou aparelho)
```

> Após alterar `firebase_options.dart`, pare o app e rode de novo
> (hot reload/restart não reaplica a inicialização do Firebase).

## Estrutura

```
lib/
 ├── main.dart                        Inicialização, rotas e ThemeMode
 ├── firebase_options.dart            Configuração Firebase (Web + Android)
 ├── models/
 │   ├── usuario.dart                 uid, nome, email
 │   └── tarefa.dart                  id, titulo, descricao, dataVencimento,
 │                                    prioridade (enum), concluida
 ├── screens/
 │   ├── login_screen.dart
 │   ├── cadastro_usuario_screen.dart
 │   ├── home_screen.dart             Nome do usuário + contadores
 │   ├── tarefas_screen.dart          ListView, filtros e detalhes
 │   ├── cadastro_tarefa_screen.dart  Criar / editar tarefa
 │   └── configuracoes_screen.dart    Tema claro/escuro
 ├── services/
 │   ├── auth_service.dart            Firebase Authentication
 │   ├── firebase_service.dart        CRUD + listener (Realtime Database)
 │   └── preferences_service.dart     SharedPreferences
 ├── widgets/
 │   ├── drawer_menu.dart             Drawer de navegação
 │   ├── auth_gate.dart               Login x Home conforme a sessão
 │   └── tarefa_tile.dart             Item da lista (cor/ícone de prioridade)
 └── themes/
     ├── app_theme.dart               lightTheme / darkTheme (ThemeData)
     └── theme_controller.dart        ThemeMode + persistência
```

## Requisitos do enunciado -> onde estão

| Requisito | Implementação |
|---|---|
| RF01 Autenticação | `auth_service.dart`, `login_screen.dart`, `cadastro_usuario_screen.dart`; sessão mantida pelo Firebase via `AuthGate` |
| RF02 Tela inicial | `home_screen.dart` (nome + cadastradas/pendentes/concluídas) |
| RF03 Drawer | `drawer_menu.dart` (Início, Minhas tarefas, Configurações, Sobre, Sair + nome/e-mail) |
| RF04 Cadastro de tarefas | `cadastro_tarefa_screen.dart` |
| RF05 Listagem | `tarefas_screen.dart` (`ListView.builder`, cor/ícone de prioridade, detalhes ao tocar) |
| RF06 Gerenciamento | criar, consultar, editar, excluir e alternar situação |
| RF07 Realtime Database | `firebase_service.dart`: `onValue` (listener em tempo real), dados em `tarefas/{uid}`; regras em `database.rules.json` |
| RF08 SharedPreferences | `preferences_service.dart` + `theme_controller.dart` |
| RF09 Temas | `app_theme.dart` (`ThemeData`, `lightTheme`, `darkTheme`) e `themeMode` no `MaterialApp` |

## Capturas de tela
Veja a pasta `docs/capturas/`.

## Testes

```bash
flutter test
```
