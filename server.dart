import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'dart:io';

//const port = int.fromEnvironment('APP_PORT', defaultValue: 9203);

void main() async {
  final portString = Platform.environment['APP_PORT'] ?? '9203';
  final port = int.parse(portString);
  print('Server will run on port: $port');
  var handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);

  var server = await shelf_io.serve(handler, 'localhost', port);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

Response _echoRequest(Request request) =>
    Response.ok('Request for "${request.url}"');
