class AppUsage {
  final String packageName;
  final double duration;
  final String appName;
  final DateTime date ;

  AppUsage({required this.packageName, required this.duration, required this.appName, required this.date});

  factory AppUsage.fromMap(Map<String, dynamic> map) {
    return AppUsage(
      packageName: map['packageName'],
      duration: double.parse(map['duration'].toString() ),
      appName: map['appName'],
      date: DateTime.fromMicrosecondsSinceEpoch(int.parse(map['date'])),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'duration': duration,
      'appName': appName,
      'date': date.toString(),
    };
  }
   Map<String, dynamic> toJson() {

    return {

      'packageName': packageName,

      'duration': duration,

      'appName': appName,

      'date': date.millisecondsSinceEpoch.toString(),

    };

  }
}