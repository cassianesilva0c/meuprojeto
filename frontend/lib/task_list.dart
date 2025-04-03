import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskListWidget extends StatefulWidget {
  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  // Função para buscar as tarefas do backend
  Future<void> fetchTasks() async {
    final response = await http.get(Uri.parse('http://localhost:8080/tasks'));
    if (response.statusCode == 200) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    }
  }

  // Função para adicionar uma nova tarefa
  Future<void> addTask(String title) async {
    await http.post(
      Uri.parse('http://localhost:8080/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );
    fetchTasks(); // Atualiza a lista após adicionar
  }

  // Função para excluir uma tarefa
  Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse('http://localhost:8080/tasks/$id'));
    fetchTasks(); // Atualiza a lista após remover
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController taskController = TextEditingController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: taskController,
            decoration: InputDecoration(labelText: 'Nova Tarefa'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (taskController.text.isNotEmpty) {
              addTask(taskController.text);
              taskController.clear();
            }
          },
          child: Text('Adicionar Tarefa'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task['title']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteTask(task['id']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
