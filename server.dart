import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'dart:io';

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

void main() async {
  final portString = Platform.environment['APP_PORT'] ?? '9203';
  final port = int.parse(portString);
  print('Server will run on port: $port');
  var handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_gameController);

  var server = await shelf_io.serve(handler, 'localhost', port);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

Future<Response> _gameController(Request request) async {
  // If the method is GET, read the query parameters.
  if (request.method == 'GET') {
    final queryParams = request.url.queryParameters;
    return Response.ok('Received GET with query parameters: $queryParams');
  }
  // If the method is POST, read the body.
  else if (request.method == 'POST') {
    final payload = await request.readAsString();
    return Response.ok('Received POST with payload: $payload');
  }
  // For any other methods, return a 405 Method Not Allowed.
  else {
    return Response(405, body: 'Method not allowed');
  }
}
