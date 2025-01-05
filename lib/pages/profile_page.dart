import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(AppUsageTrackerApp());
}

class AppUsageTrackerApp extends StatelessWidget {
  const AppUsageTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PermissionScreen(),
    );
  }
}

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
   _checkPermission();

  }
  void _checkPermission() async {
    if(!isPermissionGranted){
      isPermissionGranted=  await _channel.invokeMethod('getPermission');
    }

  }

 
  static const MethodChannel _channel = MethodChannel('com.example.usage_stats');
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App-Nutzungszeit Tracker'),
      ),body: Center(
        child: isPermissionGranted
            ? Text('Berechtigung erteilt. Weiter mit App-Daten...')
            : ElevatedButton(
      onPressed: () async {
  
         },
         child: Text("Nutzungsstatistik-Berechtigung anfordern"),
)
              

      ),
    );
     
  }

}