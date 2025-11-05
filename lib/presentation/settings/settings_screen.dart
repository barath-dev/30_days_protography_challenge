import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photography_guide/models/lesson.dart';
import '../../services/user_preferences.dart';
import '../onboarding/difficulty_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;
  bool _isLoading = true;

  // Design constants
  static const Color _primary = Color(0xFFFF6B35);
  static const Color _background = Color(0xFF0D0D0D);
  static const Color _card = Color(0xFF1A1A1A);
  static const Color _text = Color(0xFF888888);
  static const Color _border = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      _settings = await UserPreferences.getAppSettings();
    } catch (e) {
      _settings = AppSettings.defaultSettings();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings(AppSettings newSettings) async {
    await UserPreferences.saveAppSettings(newSettings);
    setState(() => _settings = newSettings);
  }

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
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSection(
                  'Learning',
                  [
                    _buildDifficultyTile(),
                    _buildResetProgressTile(),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Notifications',
                  [
                    _buildSwitchTile(
                      'Enable Notifications',
                      'Receive daily reminders and updates',
                      Icons.notifications_outlined,
                      _settings.notificationsEnabled,
                      (value) {
                        _saveSettings(
                          _settings.copyWith(notificationsEnabled: value),
                        );
                      },
                    ),
                    if (_settings.notificationsEnabled) ...[
                      _buildSwitchTile(
                        'Daily Reminders',
                        'Get reminded to complete daily lessons',
                        Icons.alarm,
                        _settings.dailyReminders,
                        (value) {
                          _saveSettings(
                            _settings.copyWith(dailyReminders: value),
                          );
                        },
                      ),
                      if (_settings.dailyReminders) _buildReminderTimeTile(),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Appearance',
                  [
                    _buildSwitchTile(
                      'Dark Mode',
                      'Use dark theme throughout the app',
                      Icons.dark_mode_outlined,
                      _settings.darkModeEnabled,
                      (value) {
                        _saveSettings(
                          _settings.copyWith(darkModeEnabled: value),
                        );
                      },
                    ),
                    _buildTextScaleTile(),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Content',
                  [
                    _buildSwitchTile(
                      'Auto-play Videos',
                      'Automatically play videos in lessons',
                      Icons.play_circle_outline,
                      _settings.autoPlayVideos,
                      (value) {
                        _saveSettings(
                          _settings.copyWith(autoPlayVideos: value),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Privacy',
                  [
                    _buildSwitchTile(
                      'Analytics',
                      'Help improve the app by sharing usage data',
                      Icons.analytics_outlined,
                      _settings.analyticsEnabled,
                      (value) {
                        _saveSettings(
                          _settings.copyWith(analyticsEnabled: value),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'About',
                  [
                    _buildInfoTile('Version', '1.0.0', Icons.info_outline),
                    _buildActionTile(
                      'Licenses',
                      'View open source licenses',
                      Icons.description_outlined,
                      () => showLicensePage(context: context),
                    ),
                  ],
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
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
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: _text, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: (val) {
          HapticFeedback.lightImpact();
          onChanged(val);
        },
        activeColor: _primary,
      ),
    );
  }

  Widget _buildDifficultyTile() {
    final currentDifficulty = UserPreferences.activeDifficulty;
    final difficultyName = currentDifficulty != null
        ? _getDifficultyName(currentDifficulty)
        : 'Not Set';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.school_outlined, color: _primary, size: 20),
      ),
      title: const Text(
        'Difficulty Level',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        difficultyName,
        style: TextStyle(color: _text, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
      onTap: () async {
        HapticFeedback.lightImpact();
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DifficultySelectionScreen(),
          ),
        );
        if (result == true && mounted) {
          // Refresh settings if difficulty changed
          setState(() {});
        }
      },
    );
  }

  Widget _buildReminderTimeTile() {
    final time = _settings.reminderTime;
    final timeString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.schedule, color: _primary, size: 20),
      ),
      title: const Text(
        'Reminder Time',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        timeString,
        style: TextStyle(color: _text, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
      onTap: () async {
        HapticFeedback.lightImpact();
        final newTime = await showTimePicker(
          context: context,
          initialTime: _settings.reminderTime,
        );
        if (newTime != null) {
          _saveSettings(_settings.copyWith(reminderTime: newTime));
        }
      },
    );
  }

  Widget _buildTextScaleTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.text_fields, color: _primary, size: 20),
      ),
      title: const Text(
        'Text Size',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${(_settings.textScale * 100).toInt()}%',
            style: TextStyle(color: _text, fontSize: 12),
          ),
          Slider(
            value: _settings.textScale,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            activeColor: _primary,
            inactiveColor: _border,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              _saveSettings(_settings.copyWith(textScale: value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResetProgressTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.refresh, color: Colors.red, size: 20),
      ),
      title: const Text(
        'Reset Progress',
        style: TextStyle(
          color: Colors.red,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Clear all learning progress',
        style: TextStyle(color: _text, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.red),
      onTap: () {
        HapticFeedback.lightImpact();
        _showResetConfirmDialog();
      },
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
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
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: _text, fontSize: 12),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
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
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: _text, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reset Progress?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will delete all your progress for the current difficulty level. This action cannot be undone.',
          style: TextStyle(color: _text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _text)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final difficulty = UserPreferences.activeDifficulty;
              if (difficulty != null) {
                await UserPreferences.resetProgressForDifficulty(difficulty);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Progress reset successfully'),
                      backgroundColor: _primary,
                    ),
                  );
                }
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getDifficultyName(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
    }
  }
}
