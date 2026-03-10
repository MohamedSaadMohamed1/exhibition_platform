import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/config/app_metadata.dart';
import '../../core/theme/app_colors.dart';

/// App information dialog
class AppInfoDialog extends StatelessWidget {
  const AppInfoDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const AppInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppMetadata.appName,
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  'v${AppConfig.version}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppMetadata.appTagline,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppMetadata.shortDescription,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildLinkItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => _launchUrl(AppMetadata.privacyPolicyUrl),
            ),
            _buildLinkItem(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => _launchUrl(AppMetadata.termsOfServiceUrl),
            ),
            _buildLinkItem(
              icon: Icons.help_outline,
              title: 'FAQ & Support',
              onTap: () => _launchUrl(AppMetadata.faqUrl),
            ),
            _buildLinkItem(
              icon: Icons.language,
              title: 'Website',
              onTap: () => _launchUrl(AppMetadata.websiteUrl),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(
                    Icons.web,
                    () => _launchUrl(AppMetadata.twitterUrl),
                  ),
                  _buildSocialIcon(
                    Icons.camera_alt,
                    () => _launchUrl(AppMetadata.instagramUrl),
                  ),
                  _buildSocialIcon(
                    Icons.facebook,
                    () => _launchUrl(AppMetadata.facebookUrl),
                  ),
                  _buildSocialIcon(
                    Icons.business,
                    () => _launchUrl(AppMetadata.linkedInUrl),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                LegalInfo.copyright,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onTap,
      color: AppColors.textSecondary,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Licenses page
class AppLicensesPage extends StatelessWidget {
  const AppLicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LicensePage(
      applicationName: AppMetadata.appName,
      applicationVersion: 'v${AppConfig.version}',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.event,
          color: Colors.white,
          size: 36,
        ),
      ),
      applicationLegalese: LegalInfo.copyright,
    );
  }
}
