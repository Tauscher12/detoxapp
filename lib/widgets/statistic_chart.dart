import 'package:flutter/material.dart';
import 'package:detoxapp/models/app_usage.dart';
import 'package:flutter_charts/flutter_charts.dart';

class UsageStatsChart extends StatelessWidget {
  final List<AppUsage> usageStats;

  UsageStatsChart({required this.usageStats});

  @override
  Widget build(BuildContext context) {
    var data = [
      usageStats.map((usage) => double.parse(usage.duration.replaceAll("s", ""))).toList(),
    ];

    var chartData = ChartData(
      dataRows: data,
      chartOptions:  ChartOptions(),
      dataRowsLegends: ['Usage Duration'], // Nur ein Element, da es nur eine Datenreihe gibt
      xUserLabels: usageStats.map((usage) => usage.appName).toList(),
    );


    return Container(
      width: MediaQuery.of(context).size.width, // Sicherstellen, dass das Diagramm eine gültige Breite hat
      height: 300, // Eine feste Höhe für das Diagramm festlegen
      child: VerticalBarChart(
        painter: VerticalBarChartPainter(
          verticalBarChartContainer: VerticalBarChartTopContainer(
            chartData: chartData,
          ),
        ),
      ),
    );
  }
}