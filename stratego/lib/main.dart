import 'package:flutter/material.dart';
import 'game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import "dart:io";
import 'package:window_manager/window_manager.dart';
import 'game_setup.dart';
import 'game_data.dart';

const port = 50040;

class TileType {
  final int pieceVal;
  final int type; // 0 is ambient, 1: player 1, 2: player 2
  TileType(this.pieceVal, this.type);
}

class GameData {
  late List<TileType> mData;

  GameData(this.mData);

  factory GameData.fromJson(Map<String, dynamic> json) {
    List<TileType> tiles =
        (json['mData'] as List)
            .map((tile) => TileType(tile['pieceVal'], tile['type']))
            .toList();
    return GameData(tiles);
  }
}

enum PlayerState { setupboard, waiting, opponentTurn, myTurn }

class Player {
  HttpClient? client;
  Map<String, String> mChatLog;
  bool first;
  GameData mGameData;
  PlayerState mState;
  Player(this.client, this.mChatLog, this.first, this.mGameData, this.mState);
}

class PlayerController extends Cubit<Player> {
  PlayerController()
    : super(Player(null, {}, true, GameData([]), PlayerState.setupboard)) {
    connect();
  }
  void playerSelect(bool first) {
    emit(
      Player(
        state.client,
        state.mChatLog,
        first,
        state.mGameData,
        state.mState,
      ),
    );
  }

  void endTurn() {
    emit(
      Player(
        state.client,
        state.mChatLog,
        state.first,
        state.mGameData,
        PlayerState.opponentTurn,
      ),
    );
  }

  void initGame(BoardData data) {
    GameData newData = GameData([]);
    int playerType = state.first ? 1 : 2;
    for (int i = 0; i < 100; i++) {
      if (data.mPieces[i] == 11) {
        newData.mData.add(TileType(11, 0));
      } else if (data.mPieces[i] == 0) {
        newData.mData.add(TileType(0, 0));
      } else {
        newData.mData.add(TileType(data.mPieces[i], playerType));
      }
    }
    emit(
      Player(
        state.client,
        state.mChatLog,
        state.first,
        newData,
        PlayerState.waiting,
      ),
    );
  }

  /// FINISHED
  Future<void> connect() async {
    // For HTTP communication, we simply create an HttpClient.

    HttpClient client = HttpClient();
    emit(Player(client, {}, state.first, state.mGameData, state.mState));
  }

  /// FINISHED
  Future<Map<String, String>> getChatLog() async {
    final client = state.client;
    if (client == null) return {};
    final url = Uri.parse("http://localhost:$port/chat");
    try {
      final request = await client.getUrl(url);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> data = jsonDecode(responseBody);
      final Map<String, dynamic> contextData = data['context'];
      Map<String, String> chatMap = contextData.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      emit(
        Player(
          state.client,
          chatMap,
          state.first,
          state.mGameData,
          state.mState,
        ),
      );
      return chatMap;
    } catch (e) {
      print("Error fetching server data: $e");
      return {};
    }
  }

  /// FINISHED
  Future<void> sendMessage(String message) async {
    final client = state.client;
    if (client == null) return;
    final url = Uri.parse("http://localhost:$port/chat");
    try {
      final request = await client.postUrl(url);
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

  Future<GameData> getGameData() async {
    final client = state.client;
    if (client == null) return state.mGameData;
    final url = Uri.parse("http://localhost:$port/game");
    try {
      final request = await client.getUrl(url);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> decoded = jsonDecode(responseBody);
      final gameData = GameData.fromJson(decoded);
      emit(
        Player(
          state.client,
          state.mChatLog,
          state.first,
          gameData,
          state.mState,
        ),
      );
      return gameData;
    } catch (e) {
      print("Error fetching game data: $e");
      return state.mGameData;
    }
  }

  Future<void> sendGameData() async {
    final client = state.client;
    if (client == null) return;
    final url = Uri.parse("http://localhost:$port/game");
    try {
      final request = await client.postUrl(url);
      final String userName = state.first ? "Player 1" : "Player 2";
      request.headers.add("id", userName);
      final payload = jsonEncode(state.mGameData);
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
        builder: (context) {
          final playerController = BlocProvider.of<PlayerController>(context);
          return MultiBlocProvider(
            providers: [
              BlocProvider<PlayerController>.value(value: playerController),
              BlocProvider<SetUpBoardController>(
                create:
                    (_) => SetUpBoardController(
                      playerController: playerController,
                    ),
              ),
            ],
            child: const GamePage(),
          );
        },
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1000, 700),
    center: false,
    //backgroundColor: Colors.yellow, // Colors.transparent,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // await Future.delayed( Duration(seconds: 2) );
    await windowManager.show();
    await windowManager.focus();
  });
  WidgetsFlutterBinding.ensureInitialized();
  //maybe hydrate block
  runApp(BlocProvider(create: (context) => PlayerController(), child: MyApp()));
}

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
              playerController.playerSelect(true);
              Navigator.of(context).pushNamed("game");
            },
            child: const Text("Player 1"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              playerController.playerSelect(false);
              Navigator.of(context).pushNamed("game");
            },
            child: const Text("Player 2"),
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
    return BlocBuilder<PlayerController, Player>(
      builder: (context, state) {
        final playerController = context.read<PlayerController>();
        String outtext =
            playerController.state.mState == PlayerState.setupboard
                ? "Set up your board, tap on the right buttons \n to use your pieces"
                : playerController.state.mState == PlayerState.waiting
                ? "Waiting for opponent"
                : playerController.state.mState == PlayerState.myTurn
                ? "Your Turn, move a piece"
                : playerController.state.mState == PlayerState.opponentTurn
                ? "Waiting for opponent..."
                : "Game Over";
        return Scaffold(
          appBar: AppBar(
            title: Text(outtext),
            // You can add actions, leading icons, etc.
          ),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed("chat");
                },
                child: const Text("Chat"),
              ),
              SizedBox(width: 50, height: double.infinity),
              if (playerController.state.mState == PlayerState.setupboard)
                GameSetUpLayout(),
              if (playerController.state.mState == PlayerState.setupboard)
                SizedBox(width: 50, height: double.infinity),
              if (playerController.state.mState == PlayerState.setupboard)
                BagUI(),
            ],
          ),
        );
      },
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
                  playerController.getChatLog();
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
