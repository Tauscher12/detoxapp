
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IconProvider {

static const platform = MethodChannel('com.example.usage_stats');
Map<String, Uint8List> iconCache = {};

  Future<Widget> getIconForPackageName(String packageName) async {
    if (iconCache.containsKey(packageName)) {
      return Image.memory(iconCache[packageName]!, width: 40, height: 40);
    }

  try {
    final Uint8List? iconData = await platform.invokeMethod(
      'getAppIcon',
      {'packageName': packageName},
    );
    if (iconData != null) {
      iconCache[packageName] = iconData;
      return Image.memory(iconData, width: 40, height: 40);
    } else {
      throw Exception('Failed to load usage stats');
    }
  } catch (e) {
    return Icon(Icons.error, size: 40);
  }

  }
}