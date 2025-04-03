import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';

List<Map<String, dynamic>> tasks = [];

void main() async {
  final router = Router();

  router.get('/tasks', (Request request) {
    return Response.ok(
      jsonEncode(tasks),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.post('/tasks', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final newTask = {
      'id': tasks.length + 1,
      'title': payload['title'],
      'completed': false,
    };
    tasks.add(newTask);
    return Response.ok(
      jsonEncode({'message': 'Task added'}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.delete('/tasks/<id>', (Request request, String id) {
    tasks.removeWhere((task) => task['id'].toString() == id);
    return Response.ok(
      jsonEncode({'message': 'Task deleted'}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  final server = await shelf_io.serve(router, InternetAddress.anyIPv4, 8080);
  print('Servidor rodando em http://${server.address.host}:${server.port}');
}
