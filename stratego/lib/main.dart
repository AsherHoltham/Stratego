import 'package:flutter/material.dart';
import 'game_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import "dart:io";
import "dart:math";

const port = 64369;

class Player {
  HttpClient? client;
  Map<String, String> mChatLog = {};
  Player(this.client, this.mChatLog);
}

class PlayerController extends Cubit<Player> {
  PlayerController() : super(Player(null, {})) {
    connect();
  }

  Future<void> connect() async {
    // For HTTP communication, we simply create an HttpClient.

    HttpClient client = HttpClient();
    emit(Player(client, {}));
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
      emit(Player(state.client, chatMap));
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
      final payload = jsonEncode({"message": message, "user": "Player"});
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

void main() => runApp(
  BlocProvider(create: (context) => PlayerController(), child: const MyApp()),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = context.read<PlayerController>();
    final TextEditingController textController = TextEditingController();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Player Chat")),
        body: Column(
          // Removed Center here
          mainAxisAlignment:
              MainAxisAlignment.start, // Align children at the top
          children: [
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
                              .map((entry) {
                                return Text(
                                  '${DateTime.now().toIso8601String()}: ${entry.key}',
                                );
                              })
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
      ),
    );
  }
}
