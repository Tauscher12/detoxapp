import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/app_usage.dart';

class AppUsageProvider with ChangeNotifier {
  static const platform = MethodChannel('com.example.usage_stats');

  List<AppUsage> _appUsageList = [];
  final Map<String, AppUsage> _usageCache = {}; // Cache to store fetched data
  Timer? _timer;

  AppUsageProvider() {
    _startUsageStatsTimer();
  }

  List<AppUsage> get appUsageList => _appUsageList;

  Future<List<AppUsage>> fetchUsageStats() async {
    try {
      final String result = await platform.invokeMethod('getUsageStats');
      final lines = result.split('------');
      final appUsageList = lines
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
            final details = line.split(';');
            final packageName = details[0].replaceFirst('App: ', '').trim();
            final duration = details[1].replaceFirst('Nutzungsdauer: ', '').trim();
            final appName = details[0].replaceFirst('App Name: ', '').trim().split(".").last;
            final date = details[2].replaceFirst('Date: ', '').trim();
            return AppUsage(
              packageName: packageName,
              duration: duration,
              appName: appName,
              date: DateTime.fromMillisecondsSinceEpoch(int.parse(date)),
            );
          }).toList();

      // Update local data
      for (var newUsage in appUsageList) {
        final existingUsageIndex = _appUsageList.indexWhere((usage) =>
            usage.packageName == newUsage.packageName &&
            usage.date.day == newUsage.date.day &&
            usage.date.month == newUsage.date.month &&
            usage.date.year == newUsage.date.year);

        if (existingUsageIndex != -1) {
          _appUsageList[existingUsageIndex] = newUsage;
          await saveUsageStatsToServer(appUsageList);
          await updateUsageStatsToServer(appUsageList);

        } else {
          _appUsageList.add(newUsage);
        }
      }



      notifyListeners();
      return _appUsageList;
    } on PlatformException  {
      return [
        AppUsage(
          packageName: 'Fehler',
          duration: "0",
          appName: 'Fehler',
          date: DateTime.now(),
        ),
      ];
    }
  }

  Future<void> saveUsageStatsToServer(List<AppUsage> appUsageList) async {
    final url = Uri.parse('http://10.0.2.2:3001/usagestats');
    final headers = {'Content-Type': 'application/json'};

    for (var appUsage in appUsageList) {
      final cacheKey = '${appUsage.packageName}-${appUsage.date.toIso8601String()}';
      if (_usageCache.containsKey(cacheKey)) {
        continue;
      }

      final response = await http.get(Uri.parse('$url?packageName=${appUsage.packageName}&date=${appUsage.date.millisecondsSinceEpoch}'));

      if (response.statusCode != 200 || response.body == "[]") {
        final body = jsonEncode(appUsage.toJson());
        final postResponse = await http.post(url, headers: headers, body: body);
        if (postResponse.statusCode == 201) {
          _usageCache[cacheKey] = appUsage; // Update cache
        } 
      } 
    }
  }

  void _startUsageStatsTimer() {
    _timer = Timer.periodic(Duration(seconds: 15), (timer) async {
      _appUsageList = await fetchUsageStats();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  updateUsageStatsToServer(List<AppUsage> appUsageList) async {

    final url = Uri.parse('http://10.0.2.2:3001/usagestats');
    final headers = {'Content-Type': 'application/json'};
    for (var appUsage in appUsageList){
      //get the data from the server
      final response = await http.get(Uri.parse('$url?packageName=${appUsage.packageName}&date=${appUsage.date.millisecondsSinceEpoch}'));

      if(response.statusCode==200){
        final data = jsonDecode(response.body);
        final id = data[0]["id"];
        final body = jsonEncode(appUsage.toJson());
        final putResponse = await http.put(Uri.parse("$url/$id"), headers: headers, body: body);
        if(putResponse.statusCode == 200){
      }
    }
  }

  }
}