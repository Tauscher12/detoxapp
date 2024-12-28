import 'package:flutter/material.dart';

class WeeklyCalendar extends StatelessWidget {
  const WeeklyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final day = DateTime.now().subtract(Duration(days: DateTime.now().weekday - index - 1));
        return Column(
          children: [
            Text(
              "${day.day}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"][index],
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        );
      }),
    );
  }
}
