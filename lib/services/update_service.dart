import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'remote_config_service.dart';
import '../constants/app_colors.dart';

class UpdateService {
  /// Returns true if [current] version is older than [minimum]
  static bool isUpdateRequired(String current, String minimum) {
    final c = current.split('.').map(int.tryParse).map((v) => v ?? 0).toList();
    final m = minimum.split('.').map(int.tryParse).map((v) => v ?? 0).toList();

    while (c.length < 3) { c.add(0); }
    while (m.length < 3) { m.add(0); }

    for (int i = 0; i < 3; i++) {
      if (c[i] < m[i]) return true;
      if (c[i] > m[i]) return false;
    }
    return false;
  }

  /// Call after navigating to HomeScreen — shows blocking dialog if update needed
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final minVersion = RemoteConfigService.minLiveVersion;

      if (!context.mounted) return;

      if (isUpdateRequired(currentVersion, minVersion)) {
        _showUpdateDialog(context);
      }
    } catch (_) {
      // Skip silently on error
    }
  }

  static void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        // ✅ PopScope replaces deprecated WillPopScope
        canPop: false,
        child: AlertDialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.system_update, color: AppColors.primaryColor),
              SizedBox(width: 10),
              Text(
                'Update Required',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            RemoteConfigService.updateMessage,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 15),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.download_rounded),
                label: const Text(
                  'Update Now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: () async {
                  final url = Uri.parse(RemoteConfigService.updateUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
