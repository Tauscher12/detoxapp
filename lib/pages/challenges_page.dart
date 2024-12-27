import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../models/task.dart';

class ChallengesPage extends StatefulWidget {
  @override
  _ChallengesPageState createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  @override
  void initState() {
    super.initState();
    // Load data once when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      body: ListView.builder(
        itemCount: taskProvider.tasks.length,
        itemBuilder: (context, index) {
          final task = taskProvider.tasks[index];
          return TaskTile(
            title: task.title,
            isDone: task.isDone,
            onChanged: (value) {
              taskProvider.toggleTaskStatus(task.id); // Aufgabenstatus umkehren
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Beispiel: Neue Aufgabe hinzufügen
          taskProvider.addTask(Task(
            id: DateTime.now().toString(),
            title: 'Neue Challenge ${taskProvider.tasks.length + 1}',
            isDone: false,
          ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
