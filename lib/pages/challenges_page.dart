import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  _ChallengesPageState createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadChallengeStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('30 Day Challenge'),
        centerTitle: true,
      ),
      body: taskProvider.isChallengeStarted
          ? taskProvider.tasks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      trailing: Checkbox(
                        value: task.isDone,
                        onChanged: (value) async {
                          await taskProvider.toggleTaskStatus(task.id, value!);
                        },
                      ),
                    );
                  },
                )
          : Center(
              child: ElevatedButton(
                onPressed: () async {
                  await taskProvider.startChallenge();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Challenge gestartet!'),
                    ),
                  );
                },
                child: const Text('Start Challenge'),
              ),
            ),
    );
  }
}
