import 'package:flutter/foundation.dart';
import '../models/task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class TaskProvider with ChangeNotifier {

Future<void> loadData() async {
  final uri = Uri.parse("http://localhost:3001/tasks");
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    _tasks = data.map((taskJson) => Task.fromJson(taskJson)).toList();
    notifyListeners(); // UI aktualisieren
  } else {
    throw Exception('Failed to load tasks');
  }
}
  List<Task> _tasks = [];

  List<Task> get tasks {
    return [..._tasks];
  }

   Future<void> addTask(Task task) async {
    final uri = Uri.parse("http://localhost:3001/tasks");
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 201) {
        _tasks.add(Task.fromJson(jsonDecode(response.body)));
        notifyListeners();
      } else {
        throw Exception('Failed to add task');
      }
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }


  void toggleTaskStatus(String id) {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = Task(
        id: _tasks[taskIndex].id,
        title: _tasks[taskIndex].title,
        isDone: !_tasks[taskIndex].isDone, // Status umkehren
      );
      notifyListeners(); // UI benachrichtigen
    }
  }
}
