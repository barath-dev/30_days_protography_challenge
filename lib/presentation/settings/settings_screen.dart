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
          'Settings',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSection('Learning', [
                    _buildDifficultyTile(),
                    _buildResetProgressTile(),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Notifications', [
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
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Appearance', [
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
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Content', [
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
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Privacy', [
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
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('About', [
                    _buildInfoTile('Version', '1.0.0', Icons.info_outline),
                    _buildActionTile(
                      'Licenses',
                      'View open source licenses',
                      Icons.description_outlined,
                      () => showLicensePage(context: context),
                    ),
                  ]),
                ],
              ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
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
      subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
      trailing: Switch(
        value: value,
        onChanged: (val) {
          HapticFeedback.lightImpact();
          onChanged(val);
        },
        activeColor: colorScheme.primary,
      ),
    );
  }

  Widget _buildDifficultyTile() {
    final currentDifficulty = UserPreferences.activeDifficulty;
    final difficultyName =
        currentDifficulty != null
            ? _getDifficultyName(currentDifficulty)
            : 'Not Set';
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
        child: Icon(
          Icons.school_outlined,
          color: colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        'Difficulty Level',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(difficultyName, style: theme.textTheme.bodyMedium),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface),
      onTap: () async {
        HapticFeedback.lightImpact();
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DifficultySelectionScreen()),
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
        child: Icon(Icons.schedule, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        'Reminder Time',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(timeString, style: theme.textTheme.bodyMedium),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface),
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
        child: Icon(Icons.text_fields, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        'Text Size',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${(_settings.textScale * 100).toInt()}%',
            style: theme.textTheme.bodyMedium,
          ),
          Slider(
            value: _settings.textScale,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            activeColor: colorScheme.primary,
            inactiveColor: theme.dividerColor,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.refresh, color: colorScheme.error, size: 20),
      ),
      title: Text(
        'Reset Progress',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Clear all learning progress',
        style: theme.textTheme.bodyMedium,
      ),
      trailing: Icon(Icons.chevron_right, color: colorScheme.error),
      onTap: () {
        HapticFeedback.lightImpact();
        _showResetConfirmDialog();
      },
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
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
      subtitle: Text(value, style: theme.textTheme.bodyMedium),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
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
      subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  void _showResetConfirmDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Reset Progress?', style: theme.textTheme.titleLarge),
            content: Text(
              'This will delete all your progress for the current difficulty level. This action cannot be undone.',
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final difficulty = UserPreferences.activeDifficulty;
                  if (difficulty != null) {
                    await UserPreferences.resetProgressForDifficulty(
                      difficulty,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Progress reset successfully'),
                          backgroundColor: colorScheme.primary,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  'Reset',
                  style: TextStyle(color: colorScheme.error),
                ),
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
