import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateCheck extends StatefulWidget {
  const UpdateCheck({super.key});

  @override
  State<UpdateCheck> createState() => _UpdateCheckState();
}

class _UpdateCheckState extends State<UpdateCheck> {
  @override
  void initState() {
    super.initState();
    _checkForUpdates(); // Check for updates when the app starts
  }

  Future<void> _checkForUpdates() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;

    // Replace these URLs with your actual App Store and Play Store links
    const String appStoreUrl = "https://apps.apple.com/app/id6443648390";
    const String playStoreUrl =
        "https://play.google.com/store/apps/details?id=com.papayatrading.point";

    // Replace this with your method to fetch the latest version dynamically
    const String latestVersion = "1.2.0";

    if (_isVersionNewer(latestVersion, currentVersion)) {
      _showUpdateDialog(appStoreUrl, playStoreUrl);
    }
  }

  bool _isVersionNewer(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) {
        return true;
      } else if (latestParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false;
  }

  void _showUpdateDialog(String appStoreUrl, String playStoreUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Available"),
        content: const Text(
            "A new version of the app is available. Please update to the latest version for a better experience."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final String storeUrl =
                  Platform.isIOS ? appStoreUrl : playStoreUrl;
              launchUrl(Uri.parse(storeUrl),
                  mode: LaunchMode.externalApplication);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Update Checker"),
      ),
      body: const Center(
        child: Text("Welcome to the App!"),
      ),
    );
  }
}
