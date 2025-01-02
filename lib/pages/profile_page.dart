import 'package:flutter/material.dart';
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

 Future<void> _checkPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      _requestPermission();
    } else {
      setState(() {
        isPermissionGranted = true;
      });
    }
  }

 Future<void> _requestPermission() async {
    var result = await Permission.camera.request();
    if (result.isGranted) {
      setState(() {
        isPermissionGranted = true;
      });
    } else {
      await openAppSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berechtigung benötigt, um App-Daten zu lesen')),
   
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App-Nutzungszeit Tracker'),
      ),body: Center(
        child: isPermissionGranted
            ? Text('Berechtigung erteilt. Weiter mit App-Daten...')
            : ElevatedButton(
                onPressed: _requestPermission,
                child: Text('Berechtigung anfordern'),
              )

      ),
    );
     
  }
}
