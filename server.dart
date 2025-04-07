import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'dart:io';
import 'dart:convert';

//const port = int.fromEnvironment('APP_PORT', defaultValue: 9203);
enum GameState { setup, firstPlayerTurn, secondPlayerTurn, endOfGame }

class Game {
  GameState mState = GameState.setup;
  Map<int, int> mBoardData = {};
  Game() {
    Map.fromIterable(
      List.generate(100, (index) => index),
      key: (item) => item,
      value: (item) => 0,
    );
    mBoardData[52] = 11;
    mBoardData[53] = 11;
    mBoardData[56] = 11;
    mBoardData[57] = 11;
    mBoardData[42] = 11;
    mBoardData[43] = 11;
    mBoardData[46] = 11;
    mBoardData[47] = 11;
  }
}

class ChatLog {
  Map<String, String> mLog = {};
  ChatLog(this.mLog);
}

void main() async {
  ChatLog log = ChatLog({});
  final portString = Platform.environment['APP_PORT'] ?? '9203';
  final port = int.parse(portString);
  print('Server will run on port: $port');

  // Pass log to the controller via a closure.
  var handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler((Request request) => _gameController(request, log));

  var server = await shelf_io.serve(handler, 'localhost', port);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

Future<Response> _gameController(Request request, ChatLog log) async {
  // If the method is GET, read the query parameters.
  if (request.method == 'GET') {
    final queryParams = request.url.queryParameters;
    final responseBody = jsonEncode({
      'headers': "chat",
      'context': log.mLog,
    });
    return Response.ok(
      responseBody,
      headers: {'Content-Type': 'application/json'},
    );
  }
  // If the method is POST, read the body.
  else if (request.method == 'POST') {
    final payload = await request.readAsString();
    final Map<String, dynamic> data = jsonDecode(payload);
    log.mLog[data["message"]] = data["user"];
    return Response.ok('Received POST with payload: $payload');
  }
  // For any other methods, return a 405 Method Not Allowed.
  else {
    return Response(405, body: 'Method not allowed');
  }
}
