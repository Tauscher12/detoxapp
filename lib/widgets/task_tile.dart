import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final String title;
  final bool isDone;
  final ValueChanged<bool?> onChanged; // Besserer Typ für onChanged

  const TaskTile({
    Key? key,
    required this.title,
    required this.isDone,
    required this.onChanged,
  }) : super(key: key); // const Konstruktor

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          decoration: isDone ? TextDecoration.lineThrough : null, // Durchgestrichen, falls erledigt
        ),
      ),
      leading: Checkbox(
        value: isDone,
        onChanged: onChanged,
      ),
    );
  }
}
