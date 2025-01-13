import 'package:flutter/foundation.dart';
import '../models/task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool isChallengeStarted = false;
  int currentDay = 1;

  List<Task> get tasks {
    return [..._tasks];
  }

  /// Lädt die Aufgaben basierend auf dem Status der Challenge
  Future<void> loadData() async {
  final uri = Uri.parse("http://10.0.2.2:3001/tasks");
  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      if (data is List) {
        // Fetch the challenge for the current day
        _tasks = data
            .where((taskJson) =>
                data.indexOf(taskJson) == currentDay - 1) // Match currentDay
            .map((taskJson) => Task.fromJson(taskJson))
            .toList();

        notifyListeners(); // Notify listeners to update UI
      } else {
        throw Exception("Unexpected data format: Expected a list");
      }
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  } catch (e) {
    print('Error loading tasks: $e');
    rethrow;
  }
}



  /// Lädt den aktuellen Challenge-Status vom Server
  bool _isLoading = false;

Future<void> loadChallengeStatus() async {
  final uri = Uri.parse("http://10.0.2.2:3001/challengeStatus/1");

  print('Fetching challenge status from: $uri');

  try {
    final response = await http.get(uri);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      isChallengeStarted = data['isStarted'];

      // Calculate current day based on startDate
      final startDate = DateTime.parse(data['startDate']);
      final now = DateTime.now();
      currentDay = now.difference(startDate).inDays + 1; // Increment day by 1

      // Ensure currentDay does not exceed the total number of tasks
      if (currentDay > 30) currentDay = 30;

      // Load tasks if the challenge is started
      if (isChallengeStarted) {
        await loadData();
      }

      notifyListeners();
    } else {
      throw Exception('Failed to load challenge status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error loading challenge status: $e');
    rethrow;
  }
}


  /// Startet die Challenge und aktualisiert den Status auf dem Server
  Future<void> startChallenge() async {
  final uri = Uri.parse("http://10.0.2.2:3001/challengeStatus/1");
  final startDate = DateTime.now().toIso8601String(); // Current date as ISO string

  try {
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'isStarted': true,
        'currentDay': 1,
        'startDate': startDate, // Save the start date
      }),
    );

    if (response.statusCode == 200) {
      isChallengeStarted = true;
      currentDay = 1;

      // Optionally store start date locally in TaskProvider
      notifyListeners();
    } else {
      throw Exception('Failed to start challenge');
    }
  } catch (e) {
    print('Error starting challenge: $e');
    rethrow;
  }
}

  /// Aufgabenstatus umkehren und auf dem Server aktualisieren
  Future<void> toggleTaskStatus(String id, bool isDone) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      isDone: isDone,
    );

    // Lokales Update
    _tasks[taskIndex] = updatedTask;
    notifyListeners();

    // Server-Update
    final uri = Uri.parse("http://10.0.2.2:3001/tasks/$id");
    try {
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isDone': isDone}),
      );

      if (response.statusCode >= 400) {
        // Rückgängig machen, falls das Update fehlschlägt
        _tasks[taskIndex] = task;
        notifyListeners();
      }
    } catch (e) {
      // Fehlerbehandlung: Lokalen Zustand wiederherstellen
      _tasks[taskIndex] = task;
      notifyListeners();
      rethrow;
    }
  }
}
