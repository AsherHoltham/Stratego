import 'package:flutter/material.dart';
import 'game_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import "dart:io";
import "dart:math";

const port = 55722;

BoardData testData = BoardData();

class Player {
  HttpClient? client;
  Player(this.client);
}

class PlayerController extends Cubit<Player> {
  PlayerController() : super(Player(null)) {
    connect();
  }

  Future<void> connect() async {
    // For HTTP communication, we simply create an HttpClient.

    HttpClient client = HttpClient();
    emit(Player(client));
  }

  Future<Map<int, String>> getServerData() async {
    final client = state.client;
    if (client == null) return {};
    final url = Uri.parse("http://localhost:$port");
    try {
      final request = await client.getUrl(url);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      // The server returns a JSON map of chat entries.
      final Map<String, dynamic> data = jsonDecode(responseBody);
      Map<int, String> chatMap = {};
      data.forEach((key, value) {
        chatMap[int.tryParse(key) ?? 0] =
            "User: ${value['user']}, Message: ${value['message']}";
      });
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
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PixelGrid(boardData: testData.mPieces),
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
                },
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BoardState {
  final List<int> mBoardLayout;
  BoardState(this.mBoardLayout);
}

class BoardController extends Cubit<BoardState> {
  BoardController() : super(BoardState(List.generate(100, (index) => 0)));

  void update(List<int> newBoard) {
    emit(BoardState(newBoard));
  }
}

// ignore: use_key_in_widget_constructors
class Board extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardController, BoardState>(
      builder: (context, state) => Container(),
    );
  }
}
