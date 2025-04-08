import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class ChatLog {
  Map<String, String> mLog = {};
}

class GameData {
  Map<int, TileType> mData = {};
  Map<int, TileType> p1Data = {};
  Map<int, TileType> p2Data = {};
  bool recBoardConfig1 = false;
  bool recBoardConfig2 = false;
  GameData();
}

class TileType {
  final int pieceVal;
  final int type; // 0 is ambient, 1: player 1, 2: player 2
  TileType(this.pieceVal, this.type);
}

List<TileType> reverse(List<TileType> data) {
  List<TileType> reverseData = List<TileType>.filled(data.length, data[0]);
  for (int i = 0; i < data.length; i++) {
    reverseData[data.length - 1 - i] = data[i];
  }
  return reverseData;
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
    final payload = await request.readAsString();
    final Map<int, TileType> data = jsonDecode(payload);
    gameData.mData = data;
    return Response.ok('Received game POST with payload: $payload');
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

  // Construct a pipeline that adds logging middleware.
  var handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  final port = int.parse(Platform.environment['APP_PORT'] ?? '8080');
  final server = await io.serve(handler, '0.0.0.0', port);

  print('Server listening on port ${server.port}');
}
