import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Design constants
  static const Color _primary = Color(0xFFFF6B35);
  static const Color _background = Color(0xFF0D0D0D);
  static const Color _card = Color(0xFF1A1A1A);
  static const Color _text = Color(0xFF888888);
  static const Color _border = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            'Frequently Asked Questions',
            [
              _buildFAQItem(
                'How does the daily unlock system work?',
                'Lessons are unlocked one per day based on when you started the course. This helps maintain a consistent learning pace and prevents overwhelming yourself with too much content at once.',
              ),
              _buildFAQItem(
                'Can I switch between difficulty levels?',
                'Yes! You can switch between Beginner, Intermediate, and Advanced tracks at any time from Settings. Your progress is saved separately for each difficulty level.',
              ),
              _buildFAQItem(
                'What happens if I miss a day?',
                'Don\'t worry! While your daily streak may reset, your overall progress is preserved. You can continue from where you left off, and lessons will continue to unlock daily.',
              ),
              _buildFAQItem(
                'How can I reset my progress?',
                'Go to Settings and tap on "Reset Progress". This will clear all progress for your current difficulty level. Note that this action cannot be undone.',
              ),
              _buildFAQItem(
                'Are lessons available offline?',
                'Yes! All lesson content is available offline once you\'ve opened the app at least once. Images and videos may require an initial download.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Getting Started',
            [
              _buildHelpItem(
                Icons.camera_alt,
                'Choose Your Level',
                'Select the difficulty level that matches your photography experience.',
              ),
              _buildHelpItem(
                Icons.calendar_today,
                'Daily Learning',
                'Complete one lesson each day to build skills progressively.',
              ),
              _buildHelpItem(
                Icons.bookmark,
                'Save Content',
                'Bookmark important lessons and tips for quick reference.',
              ),
              _buildHelpItem(
                Icons.trending_up,
                'Track Progress',
                'Monitor your learning journey with detailed statistics.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Contact & Feedback',
            [
              _buildContactItem(
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
                Icons.bug_report_outlined,
                'Report a Bug',
                'Help us improve the app',
                () {
                  _showSnackbar(
                    context,
                    'Bug reporting feature coming soon',
                  );
                },
              ),
              _buildContactItem(
                Icons.feedback_outlined,
                'Send Feedback',
                'Share your thoughts and suggestions',
                () {
                  _showSnackbar(
                    context,
                    'Feedback feature coming soon',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Resources',
            [
              _buildResourceItem(
                Icons.menu_book_outlined,
                'User Guide',
                'Complete guide to using the app',
                () {
                  _showSnackbar(context, 'User guide coming soon');
                },
              ),
              _buildResourceItem(
                Icons.video_library_outlined,
                'Video Tutorials',
                'Learn through video demonstrations',
                () {
                  _showSnackbar(context, 'Video tutorials coming soon');
                },
              ),
              _buildResourceItem(
                Icons.forum_outlined,
                'Community Forum',
                'Connect with other learners',
                () {
                  _showSnackbar(context, 'Community forum coming soon');
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(
                  'Photography Guide',
                  style: TextStyle(
                    color: _text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: _text, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Text(
                  'Educational Project',
                  style: TextStyle(
                    color: _text.withOpacity(0.7),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: _text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: List.generate(
              children.length,
              (index) => Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Divider(color: _border, height: 1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: _text, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: _text, fontSize: 12),
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: _text, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  Widget _buildResourceItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: _text, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
