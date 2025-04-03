import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

// Caminho do arquivo JSON para persistência
const String filePath = 'backend/tasks.json';

// Função para carregar tarefas do arquivo JSON
List<Map<String, dynamic>> loadTasks() {
  final file = File(filePath);
  if (!file.existsSync()) return [];
  return List<Map<String, dynamic>>.from(jsonDecode(file.readAsStringSync()));
}

// Função para salvar tarefas no arquivo JSON
void saveTasks(List<Map<String, dynamic>> tasks) {
  final file = File(filePath);
  file.writeAsStringSync(jsonEncode(tasks));
}

// Lista de tarefas (simulação de banco de dados)
List<Map<String, dynamic>> tasks = loadTasks();

void main() async {
  final router = Router();

  // Rota para obter todas as tarefas
  router.get('/tasks', (Request request) {
    return Response.ok(jsonEncode(tasks), headers: {'Content-Type': 'application/json'});
  });

  // Rota para adicionar uma nova tarefa
  router.post('/tasks', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final newTask = {
      'id': tasks.length + 1,
      'title': payload['title'],
      'completed': false
    };
    tasks.add(newTask);
    saveTasks(tasks);
    return Response.ok(jsonEncode({'message': 'Task added'}), headers: {'Content-Type': 'application/json'});
  });

  // Rota para excluir uma tarefa
  router.delete('/tasks/<id>', (Request request, String id) {
    tasks.removeWhere((task) => task['id'].toString() == id);
    saveTasks(tasks);
    return Response.ok(jsonEncode({'message': 'Task deleted'}), headers: {'Content-Type': 'application/json'});
  });

  // Rota para marcar uma tarefa como concluída
  router.patch('/tasks/<id>', (Request request, String id) async {
    final index = tasks.indexWhere((task) => task['id'].toString() == id);
    if (index == -1) {
      return Response.notFound(jsonEncode({'message': 'Task not found'}));
    }
    tasks[index]['completed'] = !tasks[index]['completed'];
    saveTasks(tasks);
    return Response.ok(jsonEncode({'message': 'Task updated'}), headers: {'Content-Type': 'application/json'});
  });

  // Iniciando o servidor
  final server = await shelf_io.serve(router, InternetAddress.anyIPv4, 8080);
  print('Servidor rodando em http://${server.address.host}:${server.port}');
}
