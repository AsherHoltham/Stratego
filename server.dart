import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'dart:async';

class ChatLog {
  Map<String, String> mLog = {};
}

class GameData {
  List<TileType> mData = [];
  List<TileType> p1Data = [];
  List<TileType> p2Data = [];
  bool recBoardConfig1 = false;
  bool recBoardConfig2 = false;

  Completer<void> _bothDataCompleter = Completer<void>();

  GameData();

  Future<void> waitForBothPlayers() => _bothDataCompleter.future;

  void mergeAndStartGame() {
    for (int p2Index = 0; p2Index < 60; p2Index++) {
      final tile = p2Data[p2Index];
      mData[p2Index] = TileType(tile.pieceVal, tile.type);
    }
    for (int p1Index = 60; p1Index < 100; p1Index++) {
      final tile = p1Data[p1Index];
      mData[p1Index] = TileType(tile.pieceVal, tile.type);
    }
    if (!_bothDataCompleter.isCompleted) {
      _bothDataCompleter.complete();
    }
  }
}

class TileType {
  int pieceVal;
  int type;
  TileType(this.pieceVal, this.type);
}

Future<Response> chatController(Request request, ChatLog log) async {
  if (request.method == 'GET') {
    final responseBody = jsonEncode({
      'headers': 'chat',
      'context': log.mLog,
    });
    return Response.ok(responseBody,
        headers: {'Content-Type': 'application/json'});
  } else if (request.method == 'POST') {
    final payload = await request.readAsString();
    final Map<String, dynamic> data = jsonDecode(payload);
    log.mLog[data["message"]] = data["user"];
    return Response.ok('Received chat POST with payload: $payload');
  } else {
    return Response(405, body: 'Method not allowed');
  }
}

Future<Response> gameController(Request request, GameData gameData) async {
  if (request.method == 'GET') {
    final responseBody = jsonEncode({
      'headers': 'game',
      'context': gameData.mData,
    });
    return Response.ok(responseBody,
        headers: {'Content-Type': 'application/json'});
  } else if (request.method == 'POST') {
    final playerID = request.headers['id'];
    final payload = await request.readAsString();
    final List<dynamic> rawData = jsonDecode(payload);
    final List<TileType> data = rawData.map<TileType>((tile) {
      return TileType(tile['pieceVal'] as int, tile['type'] as int);
    }).toList();
    if (playerID == 'p1' && !gameData.recBoardConfig1) {
      print("here");
      gameData.recBoardConfig1 = true;
      gameData.p1Data = data;
      print("${data.toString()}");
    } else if (playerID == 'p2' && !gameData.recBoardConfig2) {
      gameData.recBoardConfig2 = true;
      gameData.p2Data = data;
    } else {
      gameData.mData = data;
    }
    if (gameData.recBoardConfig1 && gameData.recBoardConfig2) {
      gameData.mergeAndStartGame();
    }
    await gameData.waitForBothPlayers();

    final responseData = {
      'message': 'data',
      'data': gameData.mData.asMap().map((key, tile) => MapEntry(
          key.toString(), {'pieceVal': tile.pieceVal, 'type': tile.type}))
    };

    return Response.ok(jsonEncode(responseData),
        headers: {'Content-Type': 'application/json'});
  } else {
    return Response(405, body: 'Method not allowed');
  }
}

void main(List<String> args) async {
  final chatLog = ChatLog();
  final gameData = GameData();
  final router = Router();

  router.get('/chat', (Request request) => chatController(request, chatLog));
  router.post('/chat', (Request request) => chatController(request, chatLog));
  router.get('/game', (Request request) => gameController(request, gameData));
  router.post('/game', (Request request) => gameController(request, gameData));

  var handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  final port = int.parse(Platform.environment['APP_PORT'] ?? '8080');
  final server = await io.serve(handler, '0.0.0.0', port);

  print('Server listening on port ${server.port}');
}
