import 'package:flutter/material.dart';
import '../widgets/weekly_calendar.dart';
import '../widgets/screentime_chart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tägliche Übersicht',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ScreentimeChart(), // Widget für die heutige Screen-Time
            SizedBox(height: 20),
            WeeklyCalendar(), // Kalender-Widget
          ],
        ),
      ),
    );
  }
}
