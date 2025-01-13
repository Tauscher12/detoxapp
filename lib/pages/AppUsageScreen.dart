import 'package:detoxapp/models/app_usage.dart';
import 'package:detoxapp/providers/app_usage_api_provider.dart';
import 'package:detoxapp/providers/icon_provider.dart';
import 'package:detoxapp/widgets/statistic_chart.dart';
import 'package:flutter/material.dart';


class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({super.key});

  @override
  _UsageStatsScreenState createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
   IconProvider iconProvider = IconProvider(); 
   AppUsageApiProvider appUsageApiProvider = AppUsageApiProvider();
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App-Nutzungsstatistiken')),
      body: FutureBuilder<List<AppUsage>>(
        future: appUsageApiProvider.fetchUsageStatsFromAPI(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          final usageStats = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: UsageStatsChart(usageStats: usageStats),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: usageStats.length,
                  itemBuilder: (context, index) {
                    final stat = usageStats[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: FutureBuilder<Widget>(
                        future:iconProvider.getIconForPackageName(stat.packageName),
                        builder: (context, iconSnapshot) {
                          if (iconSnapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              leading: CircularProgressIndicator(),
                              title: Text(stat.appName),
                              subtitle: Text('Nutzungsdauer: ${stat.duration}'),
                            );
                          }
                          return ListTile(
                            leading: iconSnapshot.data,
                            title: Text(stat.appName),
                            subtitle: Text('Nutzungsdauer: ${stat.duration}'),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
