
import 'dart:convert';
import 'package:detoxapp/models/app_usage.dart';
import 'package:http/http.dart' as http;

class AppUsageApiProvider{
  final Map<String, AppUsage> _usageCache = {};
  Future<List<AppUsage>> fetchUsageStatsFromAPI() async {
    DateTime now = DateTime.now();
  
    final Uri url = Uri.parse('http://10.0.2.2:3001/usagestats').replace(queryParameters: {
    'date':  DateTime(now.year, now.month, now.day).millisecondsSinceEpoch.toString(),
    });
      final response = await http.get(url);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<AppUsage> appUsageList = jsonResponse.map((data) {
        return AppUsage.fromMap(data);
      }).toList();
      return appUsageList;
    
    } else {
      throw Exception('Failed to load usage stats');
    }
  }

  Future<double> fetchTotalTimeFromAPI() async {
    return fetchUsageStatsFromAPI().then((value) {
      double totalTime = 0;
      for (var appUsage in value) {
        totalTime += appUsage.duration;
      }
      return totalTime;
    });
  }

  updateUsageStatsToServer(List<AppUsage> appUsageList) async {
    final url = Uri.parse('http://10.0.2.2:3001/usagestats');
    final headers = {'Content-Type': 'application/json'};
    for (var appUsage in appUsageList) {
      //get the data from the server
      final response = await http.get(Uri.parse(
          '$url?packageName=${appUsage.packageName}&date=${appUsage.date.millisecondsSinceEpoch}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final id = data[0]["id"];
        final body = jsonEncode(appUsage.toJson());
        final putResponse =
            await http.put(Uri.parse("$url/$id"), headers: headers, body: body);
        if (putResponse.statusCode == 200) {}
      }
    }
  }
   Future<void> saveUsageStatsToServer(List<AppUsage> appUsageList) async {
    final url = Uri.parse('http://10.0.2.2:3001/usagestats');
    final headers = {'Content-Type': 'application/json'};

    for (var appUsage in appUsageList) {
      final cacheKey =
          '${appUsage.packageName}-${appUsage.date.toIso8601String()}';
      if (_usageCache.containsKey(cacheKey)) {
        continue;
      }

      final response = await http.get(Uri.parse(
          '$url?packageName=${appUsage.packageName}&date=${appUsage.date.millisecondsSinceEpoch}'));

      if (response.statusCode != 200 || response.body == "[]") {
        final body = jsonEncode(appUsage.toJson());
        final postResponse = await http.post(url, headers: headers, body: body);
        if (postResponse.statusCode == 201) {
          _usageCache[cacheKey] = appUsage; // Update cache
        }
      }
    }
  }
 }
 