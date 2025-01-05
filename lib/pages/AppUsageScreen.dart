import 'package:detoxapp/models/app_usage.dart';
import 'package:detoxapp/providers/icon_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({super.key});



  @override
  _UsageStatsScreenState createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
   IconProvider iconProvider = IconProvider(); 
  Future<List<AppUsage>> fetchUsageStatsFromAPI() async {
    DateTime now = DateTime.now();
  
    final Uri url = Uri.parse('http://10.0.2.2:3001/usagestats').replace(queryParameters: {
    'date':  DateTime(now.year, now.month, now.day).millisecondsSinceEpoch.toString(),
    });
      final response = await http.get(url);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => AppUsage.fromMap(data)).toList();
    } else {
      throw Exception('Failed to load usage stats');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App-Nutzungsstatistiken')),
      body: FutureBuilder<List<AppUsage>>(
        future: fetchUsageStatsFromAPI(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          final usageStats = snapshot.data!;
          return ListView.builder(
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
          );
        },
      ),
    );
  }
}
