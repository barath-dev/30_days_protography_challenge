import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(context, 'Frequently Asked Questions', [
            _buildFAQItem(
              context,
              'How does the daily unlock system work?',
              'Lessons are unlocked one per day based on when you started the course. This helps maintain a consistent learning pace and prevents overwhelming yourself with too much content at once.',
            ),
            _buildFAQItem(
              context,
              'Can I switch between difficulty levels?',
              'Yes! You can switch between Beginner, Intermediate, and Advanced tracks at any time from Settings. Your progress is saved separately for each difficulty level.',
            ),
            _buildFAQItem(
              context,
              'What happens if I miss a day?',
              'Don\'t worry! While your daily streak may reset, your overall progress is preserved. You can continue from where you left off, and lessons will continue to unlock daily.',
            ),
            _buildFAQItem(
              context,
              'How can I reset my progress?',
              'Go to Settings and tap on "Reset Progress". This will clear all progress for your current difficulty level. Note that this action cannot be undone.',
            ),
            _buildFAQItem(
              context,
              'Are lessons available offline?',
              'Yes! All lesson content is available offline once you\'ve opened the app at least once. Images and videos may require an initial download.',
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'Getting Started', [
            _buildHelpItem(
              context,
              Icons.camera_alt,
              'Choose Your Level',
              'Select the difficulty level that matches your photography experience.',
            ),
            _buildHelpItem(
              context,
              Icons.calendar_today,
              'Daily Learning',
              'Complete one lesson each day to build skills progressively.',
            ),
            _buildHelpItem(
              context,
              Icons.bookmark,
              'Save Content',
              'Bookmark important lessons and tips for quick reference.',
            ),
            _buildHelpItem(
              context,
              Icons.trending_up,
              'Track Progress',
              'Monitor your learning journey with detailed statistics.',
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'Contact & Feedback', [
            _buildContactItem(
              context,
              Icons.email_outlined,
              'Email Support',
              'support@photographyguide.app',
              () {
                Clipboard.setData(
                  const ClipboardData(text: 'support@photographyguide.app'),
                );
                _showSnackbar(context, 'Email copied to clipboard');
              },
            ),
            _buildContactItem(
              context,
              Icons.bug_report_outlined,
              'Report a Bug',
              'Help us improve the app',
              () {
                _showSnackbar(context, 'Bug reporting feature coming soon');
              },
            ),
            _buildContactItem(
              context,
              Icons.feedback_outlined,
              'Send Feedback',
              'Share your thoughts and suggestions',
              () {
                _showSnackbar(context, 'Feedback feature coming soon');
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'Resources', [
            _buildResourceItem(
              context,
              Icons.menu_book_outlined,
              'User Guide',
              'Complete guide to using the app',
              () {
                _showSnackbar(context, 'User guide coming soon');
              },
            ),
            _buildResourceItem(
              context,
              Icons.video_library_outlined,
              'Video Tutorials',
              'Learn through video demonstrations',
              () {
                _showSnackbar(context, 'Video tutorials coming soon');
              },
            ),
            _buildResourceItem(
              context,
              Icons.forum_outlined,
              'Community Forum',
              'Connect with other learners',
              () {
                _showSnackbar(context, 'Community forum coming soon');
              },
            ),
          ]),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(
                  'Learn photography in 30days',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Version 1.0.0', style: textTheme.bodySmall),
                const SizedBox(height: 16),
                Text(
                  'Educational Project',
                  style: textTheme.bodySmall?.copyWith(
                    color: textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: List.generate(
              children.length,
              (index) => Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Divider(color: theme.dividerColor, height: 1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Theme(
      data: theme.copyWith(
        dividerColor: Colors.transparent,
        expansionTileTheme: ExpansionTileThemeData(
          iconColor: colorScheme.onSurface,
          collapsedIconColor: colorScheme.onSurface,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          question,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        description,
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurface,
        size: 20,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  Widget _buildResourceItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurface,
        size: 20,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
