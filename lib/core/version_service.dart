import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  final String _baseUrl = "web-production-d9d24.up.railway.app";

  Future<Map<String, dynamic>?> checkVersion() async {
    try {
      final url = Uri.parse("https://$_baseUrl/system/version");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Version check error: $e");
    }
    return null;
  }

  Future<bool> isUpdateRequired() async {
    final info = await checkVersion();
    if (info == null) return false;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version; // e.g. "1.0.0"

    final minVersionStr = info['min_version'] as String;

    return _isBelow(currentVersion, minVersionStr);
  }

  bool _isBelow(String current, String min) {
    List<int> c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> m = min.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      int cVal = i < c.length ? c[i] : 0;
      int mVal = i < m.length ? m[i] : 0;
      if (cVal < mVal) return true;
      if (cVal > mVal) return false;
    }
    return false;
  }
}
