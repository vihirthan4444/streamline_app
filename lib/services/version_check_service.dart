import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionCheckService {
  final String baseUrl = "https://web-production-d9d24.up.railway.app";

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final int currentBuild = int.parse(info.buildNumber);

      // Determine platform key
      String platformKey = 'android';
      if (Platform.isWindows) platformKey = 'windows';

      print("DEBUG: BaseURL is '$baseUrl'");
      final uri = Uri.parse("$baseUrl/api/v1/app/version");
      print("DEBUG: Requesting '$uri'");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final platformData = data[platformKey];

        if (platformData == null) return;

        final int serverBuild = platformData['build'];
        final bool force = platformData['force'];
        final String url = platformData['url'];

        if (serverBuild > currentBuild) {
          if (context.mounted) {
            await _showUpdateDialog(
                context, force, url, platformData['version']);
          }
        }
      }
    } catch (e) {
      print("Version check check failed: $e");
    }
  }

  Future<void> _showUpdateDialog(
      BuildContext context, bool force, String url, String version) async {
    await showDialog(
      barrierDismissible: !force,
      context: context,
      builder: (_) => PopScope(
        canPop: !force,
        child: AlertDialog(
          title: const Text("Update Available"),
          content: Text(force
              ? "A critical update (v$version) is required to continue using Streamline."
              : "A new version (v$version) is available. Would you like to update?"),
          actions: [
            if (!force)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Later"),
              ),
            ElevatedButton(
              onPressed: () => _launchURL(url),
              child: const Text("Update Now"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $url');
    }
  }
}
