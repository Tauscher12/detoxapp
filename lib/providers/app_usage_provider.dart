import 'dart:async';
import 'package:detoxapp/providers/app_usage_api_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/app_usage.dart';

class AppUsageProvider with ChangeNotifier {
  static const platform = MethodChannel('com.example.usage_stats');
  List<AppUsage> _appUsageList = [];
  AppUsageApiProvider appUsageApiprovider = AppUsageApiProvider();

  // Cache to store fetched data
  Timer? _timer;

  AppUsageProvider() {
    _startUsageStatsTimer();
  }

  List<AppUsage> get appUsageList => _appUsageList;

  Future<List<AppUsage>> fetchUsageStats() async {
    try {
      final String result = await platform.invokeMethod('getUsageStats');
      if (result.contains(
          "Berechtigung nicht erteilt. Bitte aktivieren Sie die Berechtigung in den Einstellungen.")) {
        return [
          AppUsage(
            packageName: 'Fehler',
            duration: 0,
            appName: 'Fehler',
            date: DateTime.now(),
          ),
        ];
      } else {
        final lines = result.split('------');
        final appUsageList =
            lines.where((line) => line.trim().isNotEmpty).map((line) {
          final details = line.split(';');
          details.removeWhere((element) => element.contains("com.google.android.apps.nexuslauncher"));
          final packageName = details[0].replaceFirst('App: ', '').trim();
          final duration =
              double.parse(details[1].replaceFirst('Nutzungsdauer: ', '').trim().replaceAll("s", ""));
          final appName =
              details[0].replaceFirst('App Name: ', '').trim().split(".").last;
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
            await appUsageApiprovider.saveUsageStatsToServer(appUsageList);
            await appUsageApiprovider.updateUsageStatsToServer(appUsageList);
          } else {
            _appUsageList.add(newUsage);
          }
        }

        notifyListeners();
        return _appUsageList;
      }
    } on PlatformException {
      return [
        AppUsage(
          packageName: 'Fehler',
          duration: 0,
          appName: 'Fehler',
          date: DateTime.now(),
        ),
      ];
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

 
}
