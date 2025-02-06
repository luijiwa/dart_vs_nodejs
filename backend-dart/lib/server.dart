import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:postgres/postgres.dart';

Future<Response> getUser(Request request, Connection conn) async {
  final id = int.tryParse(request.url.pathSegments.last);
  if (id == null) return Response.badRequest(body: 'Invalid ID');

  final results = await conn.execute(
    Sql.named('SELECT id, name, age FROM users WHERE id=@id'),
    parameters: {'id': id},
  );

  if (results.isEmpty) return Response.notFound('User not found');

  final row = results.first.toColumnMap();
  final response = {
    'id': row['id'],
    'name': row['name'],
    'age': row['age'],
    'extra_info': '${row['name']} is ${row['age']} years old'
  };

  return Response.ok(jsonEncode(response),
      headers: {'Content-Type': 'application/json'});
}

void main() async {
  final conn = await Connection.open(
    Endpoint(
      host: 'db',
      database: 'testdb',
      username: 'user',
      password: 'password',
    ),
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );

  final router = Pipeline()
      .addMiddleware(logRequests())
      .addHandler((Request request) async {
    if (request.url.pathSegments.length == 2 &&
        request.url.pathSegments.first == 'users') {
      return await getUser(request, conn);
    }
    return Response.notFound('Not found');
  });

  final server = await shelf_io.serve(router, InternetAddress.anyIPv4, 8080);
  print('Dart Shelf running on http://${server.address.host}:${server.port}');
}
