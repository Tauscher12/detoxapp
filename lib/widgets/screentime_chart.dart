import 'package:detoxapp/providers/app_usage_api_provider.dart';
import 'package:flutter/material.dart';

class ScreentimeChart extends StatelessWidget {
  const ScreentimeChart({super.key});

  @override
  Widget build(BuildContext context) {
    AppUsageApiProvider appUsageApiProvider = AppUsageApiProvider();

    return FutureBuilder<double>(
      future: appUsageApiProvider.fetchTotalTimeFromAPI(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Fehler beim Laden der Daten'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('Keine Daten verfügbar'));
        } else {
          double totalTime = snapshot.data!;
          int hours = (totalTime / 3600).floor();
          int minutes = ((totalTime % 3600) / 60).floor();
          int seconds = (totalTime % 60).floor();
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Gesamte Nutzungszeit: ${hours} Stunden, ${minutes} Minuten und ${seconds} Sekunden',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          );
        }
      },
    );
  }
}
