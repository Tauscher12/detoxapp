import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UsageStatsScreen extends StatefulWidget {
  @override
  _UsageStatsScreenState createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  static const platform = MethodChannel('com.example.usage_stats');
  Map<String, Uint8List> iconCache = {};

  Future<List<Map<String, dynamic>>> fetchUsageStats() async {
    try {
      final String result = await platform.invokeMethod('getUsageStats');
      final lines = result.split('------');
      return lines
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
            final details = line.split(';');
            final packageName = details[0].replaceFirst('App: ', '').trim();
            final duration = details[1].replaceFirst('Nutzungsdauer: ', '').trim();
            return {'packageName': packageName, 'duration': duration};
          })
          .toList();
    } on PlatformException catch (e) {
      return [
        {'packageName': 'Fehler', 'duration': e.message ?? 'Keine Details verfügbar'}
      ];
    }
  }

  Future<Widget> getIconForPackageName(String packageName) async {
    print('Fetching icon for package: $packageName');
    if (iconCache.containsKey(packageName)) {
      print('Icon found in cache for package: $packageName');
      return Image.memory(iconCache[packageName]!, width: 40, height: 40);
    }

    try {
      final Uint8List? iconData = await platform.invokeMethod(
        'getAppIcon',
        {'packageName': packageName},
      );
      if (iconData != null) {
        print('Icon data fetched for package: $packageName');
        iconCache[packageName] = iconData;
        return Image.memory(iconData, width: 40, height: 40);
      } else {
        print('No icon data returned for package: $packageName');
      }
    } catch (e) {
      print('Error loading icon for $packageName: $e');
    }

    // Fallback-Icon
    print('Using fallback icon for package: $packageName');
    return Icon(Icons.apps, color: Colors.blue, size: 40);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App-Nutzungsstatistiken')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsageStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Keine Daten verfügbar.'));
          }

          final usageStats = snapshot.data!;
          return ListView.builder(
            itemCount: usageStats.length,
            itemBuilder: (context, index) {
              final stat = usageStats[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: FutureBuilder<Widget>(
                  future: getIconForPackageName(stat['packageName']),
                  builder: (context, iconSnapshot) {
                    if (iconSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text(stat['packageName']),
                        subtitle: Text('Nutzungsdauer: ${stat['duration']}'),
                      );
                    }
                    return ListTile(
                      leading: iconSnapshot.data,
                      title: Text(stat['packageName']),
                      subtitle: Text('Nutzungsdauer: ${stat['duration']}'),
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
