import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:postgres/postgres.dart';

/// Класс для управления пулом соединений с базой данных
class ConnectionPool {
  final int maxConnections;
  final List<Connection> _connections = [];
  final List<Connection> _busyConnections = [];

  ConnectionPool(this.maxConnections);

  /// Инициализация пула соединений
  Future<void> init() async {
    for (var i = 0; i < maxConnections; i++) {
      final conn = await _createConnection();
      _connections.add(conn);
    }
  }

  /// Создание нового соединения
  Future<Connection> _createConnection() async {
    return await Connection.open(
      Endpoint(
        host: 'db',
        database: 'testdb',
        username: 'user',
        password: 'password',
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  /// Получение свободного соединения
  Future<Connection> getConnection() async {
    while (_connections.isEmpty) {
      await Future.delayed(Duration(milliseconds: 10)); // Ждем освобождения
    }
    final conn = _connections.removeLast();
    _busyConnections.add(conn);
    return conn;
  }

  /// Освобождение соединения после использования
  void releaseConnection(Connection conn) {
    _busyConnections.remove(conn);
    _connections.add(conn);
  }

  /// Закрытие всех соединений при завершении работы сервера
  Future<void> closeAll() async {
    for (var conn in _connections) {
      await conn.close();
    }
    for (var conn in _busyConnections) {
      await conn.close();
    }
    _connections.clear();
    _busyConnections.clear();
  }
}

/// Глобальный пул соединений
final pool = ConnectionPool(10);

/// Функция для получения пользователя по ID
Future<Response> getUser(Request request) async {
  final id = int.tryParse(request.url.pathSegments.last);
  if (id == null) return Response.badRequest(body: 'Invalid ID');

  final conn = await pool.getConnection(); // Берем соединение из пула

  try {
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
  } catch (e) {
    return Response.internalServerError(body: 'Database error: $e');
  } finally {
    pool.releaseConnection(conn); // Возвращаем соединение в пул
  }
}

void main() async {
  await pool.init(); // Инициализируем пул соединений

  final router = Pipeline()
      .addMiddleware(logRequests())
      .addHandler((Request request) async {
    if (request.url.pathSegments.length == 2 &&
        request.url.pathSegments.first == 'users') {
      return await getUser(request);
    }
    return Response.notFound('Not found');
  });

  final server = await shelf_io.serve(router, InternetAddress.anyIPv4, 8080);
  print('Dart Shelf running on http://${server.address.host}:${server.port}');

  // Закрываем соединения при завершении работы сервера
  ProcessSignal.sigint.watch().listen((_) async {
    print('Closing database connections...');
    await pool.closeAll();
    exit(0);
  });
}
