import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;

    final sections = [
      _PolicySection(
        icon: LucideIcons.database,
        title: s.dataCollection,
        body: s.dataCollectionText,
      ),
      _PolicySection(
        icon: LucideIcons.userCircle,
        title: s.privacyAccountData,
        body: s.privacyAccountDataText,
      ),
      _PolicySection(
        icon: LucideIcons.activity,
        title: s.dataUsage,
        body: s.dataUsageText,
      ),
      _PolicySection(
        icon: LucideIcons.share2,
        title: s.thirdPartySharing,
        body: s.thirdPartySharingText,
      ),
      _PolicySection(
        icon: LucideIcons.shield,
        title: s.privacySecurity,
        body: s.privacySecurityText,
      ),
      _PolicySection(
        icon: LucideIcons.clock,
        title: s.privacyDataRetention,
        body: s.privacyDataRetentionText,
      ),
      _PolicySection(
        icon: LucideIcons.userX,
        title: s.privacyAccountDeletion,
        body: s.privacyAccountDeletionText,
      ),
      _PolicySection(
        icon: LucideIcons.baby,
        title: s.privacyChildren,
        body: s.privacyChildrenText,
      ),
      _PolicySection(
        icon: LucideIcons.mail,
        title: s.contactInformation,
        body: s.contactInformationText,
      ),
      _PolicySection(
        icon: LucideIcons.fileText,
        title: s.privacyPolicyChanges,
        body: s.privacyPolicyChangesText,
      ),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.privacyPolicy),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.08),
              borderRadius: AppRadius.rL,
              border: Border.all(color: colors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.shieldCheck, color: colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.privacyPolicy,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  s.privacyPolicyLastUpdated,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  s.privacyPolicyIntro,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SectionCard(section: section),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection {
  const _PolicySection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final _PolicySection section;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.rM,
                ),
                child: Icon(section.icon, size: 18, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            section.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textMuted,
                  height: 1.55,
                ),
          ),
        ],
      ),
    );
  }
}
