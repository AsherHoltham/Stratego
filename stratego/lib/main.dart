import 'package:flutter/material.dart';
import 'game_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import "dart:io";
import "dart:math";

const port = 61895;

enum PlayerState { setupboard, opponentTurn, myTurn }

class Player {
  HttpClient? client;
  Map<String, String> mChatLog;
  bool first;
  BoardData mGameData;
  Player(this.client, this.mChatLog, this.first, this.mGameData);
}

class PlayerController extends Cubit<Player> {
  PlayerController() : super(Player(null, {}, true, BoardData())) {
    connect();
  }
  void updateTurn(bool first) {
    emit(Player(state.client, state.mChatLog, first, state.mGameData));
  }

  Future<void> connect() async {
    // For HTTP communication, we simply create an HttpClient.

    HttpClient client = HttpClient();
    emit(Player(client, {}, state.first, state.mGameData));
  }

  Future<Map<String, String>> getServerData() async {
    final client = state.client;
    if (client == null) return {};
    final url = Uri.parse("http://localhost:$port");
    try {
      final request = await client.getUrl(url);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      // The server returns a JSON object like:
      // { "headers": "chat", "context": { "key1": "value1", ... } }
      final Map<String, dynamic> data = jsonDecode(responseBody);
      final Map<String, dynamic> contextData = data['context'];
      // Convert contextData to Map<String, String>
      Map<String, String> chatMap = contextData.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      emit(Player(state.client, chatMap, state.first, state.mGameData));
      return chatMap;
    } catch (e) {
      print("Error fetching server data: $e");
      return {};
    }
  }

  Future<void> sendMessage(String message) async {
    final client = state.client;
    if (client == null) return;
    final url = Uri.parse("http://localhost:$port");
    try {
      final request = await client.postUrl(url);
      // Create a JSON payload. You can modify the 'user' field as needed.
      final String userName = state.first ? "Player 1" : "Player 2";
      final payload = jsonEncode({"message": message, "user": userName});
      request.headers.contentType = ContentType.json;
      request.write(payload);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      print("Response from server: $responseBody");
    } catch (e) {
      print("Error sending message: $e");
    }
  }
}

class RouterApp {
  final PlayerController controller;
  RouterApp({required this.controller});

  Route genRoute(RouteSettings settings) {
    if (settings.name == "/" || settings.name == null) {
      return MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: controller,
              child: const GameLaunch(),
            ),
      );
    } else if (settings.name == "game") {
      return MaterialPageRoute(
        builder:
            (_) =>
                BlocProvider.value(value: controller, child: const GamePage()),
      );
    } else if (settings.name == "chat") {
      return MaterialPageRoute(
        builder:
            (_) =>
                BlocProvider.value(value: controller, child: const ChatPage()),
      );
    } else {
      // Fallback to Route1 if an unknown route is requested.
      return MaterialPageRoute(
        builder:
            (_) =>
                BlocProvider.value(value: controller, child: const GamePage()),
      );
    }
  }
}

void main() => runApp(
  BlocProvider(create: (context) => PlayerController(), child: MyApp()),
);

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final PlayerController controller = PlayerController();

  // Create the router, passing the same cubit.
  late final RouterApp router = RouterApp(controller: controller);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game App',
      onGenerateRoute: router.genRoute,
      home: BlocProvider.value(value: controller, child: const GameLaunch()),
    );
  }
}

class GameLaunch extends StatelessWidget {
  const GameLaunch({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = context.read<PlayerController>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              playerController.updateTurn(true);
              Navigator.of(context).pushNamed("game");
            },
            child: const Text("First"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              playerController.updateTurn(false);
              Navigator.of(context).pushNamed("game");
            },
            child: const Text("Second"),
          ),
        ],
      ),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = context.read<PlayerController>();
    String title = "Game";
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // You can add actions, leading icons, etc.
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed("chat");
            },
            child: const Text("Chat"),
          ),
          GameLayout(playerController.state.mGameData),
        ],
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = context.read<PlayerController>();
    final textController = TextEditingController();

    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushReplacementNamed("game"); // Navigate back to GamePage
            },
            child: const Text("Game"),
          ),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: SingleChildScrollView(
              child: BlocBuilder<PlayerController, Player>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        state.mChatLog.entries
                            .map(
                              (entry) => Text('${entry.value}: ${entry.key}'),
                            )
                            .toList()
                            .reversed
                            .toList(),
                  );
                },
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  autofocus: true,
                  decoration: const InputDecoration(filled: true),
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  playerController.sendMessage(textController.text);
                  textController.clear();
                  playerController.getServerData();
                },
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
