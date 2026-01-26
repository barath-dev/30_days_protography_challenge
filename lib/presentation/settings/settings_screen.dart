import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:photography_guide/models/lesson.dart';
import '../../services/user_preferences.dart';
import '../../utils/constants.dart';
import '../onboarding/difficulty_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AppSettings _settings;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      _settings = await UserPreferences.getAppSettings();
    } catch (e) {
      _settings = AppSettings.defaultSettings();
    }
    setState(() => _isLoading = false);
    _animationController.forward();
  }

  Future<void> _saveSettings(AppSettings newSettings) async {
    await UserPreferences.saveAppSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
            stops: [0.0, 1.0],
          ),
        ),
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    color: AppConstants.primaryColor,
                  ),
                )
                : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
                  children: [
                    _buildAnimatedSection(0, 'Learning', [
                      _buildDifficultyTile(),
                      const SizedBox(height: 12),
                      _buildResetProgressTile(),
                    ]),
                    const SizedBox(height: 32),
                    _buildAnimatedSection(1, 'Notifications', [
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
                        const SizedBox(height: 12),
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
                        if (_settings.dailyReminders) ...[
                          const SizedBox(height: 12),
                          _buildReminderTimeTile(),
                        ],
                      ],
                    ]),
                    const SizedBox(height: 32),
                    _buildAnimatedSection(2, 'Appearance', [
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
                      const SizedBox(height: 12),
                      _buildTextScaleTile(),
                    ]),
                    const SizedBox(height: 32),
                    _buildAnimatedSection(3, 'Content', [
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
                    const SizedBox(height: 32),
                    _buildAnimatedSection(4, 'Privacy & About', [
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
                      const SizedBox(height: 12),
                      _buildInfoTile('Version', '1.0.0', Icons.info_outline),
                      const SizedBox(height: 12),
                      _buildActionTile(
                        'Licenses',
                        'View open source licenses',
                        Icons.description_outlined,
                        () => showLicensePage(context: context),
                      ),
                    ]),
                  ],
                ),
      ),
    );
  }

  Widget _buildAnimatedSection(int index, String title, List<Widget> children) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              index * 0.1,
              0.6 + (index * 0.1),
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildGlassContainer({
    required Widget child,
    VoidCallback? onTap,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.08),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return _buildGlassContainer(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onChanged(val);
            },
            activeColor: AppConstants.primaryColor,
            activeTrackColor: AppConstants.primaryColor.withOpacity(0.3),
            inactiveThumbColor: Colors.white.withOpacity(0.6),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyTile() {
    final currentDifficulty = UserPreferences.activeDifficulty;
    final difficultyName =
        currentDifficulty != null
            ? _getDifficultyName(currentDifficulty)
            : 'Not Set';

    // Choose color based on difficulty
    Color diffColor = AppConstants.primaryColor;
    if (currentDifficulty == DifficultyLevel.beginner)
      diffColor = AppConstants.beginnerColor;
    if (currentDifficulty == DifficultyLevel.intermediate)
      diffColor = AppConstants.intermediateColor;
    if (currentDifficulty == DifficultyLevel.advanced)
      diffColor = AppConstants.advancedColor;

    return _buildGlassContainer(
      onTap: () async {
        HapticFeedback.lightImpact();
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DifficultySelectionScreen()),
        );
        if (result == true && mounted) {
          setState(() {});
        }
      },
      borderColor: diffColor.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: diffColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: diffColor.withOpacity(0.3)),
            ),
            child: Icon(Icons.school_outlined, color: diffColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Difficulty Level',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  difficultyName,
                  style: TextStyle(
                    color: diffColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTimeTile() {
    final time = _settings.reminderTime;
    final timeString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return _buildGlassContainer(
      onTap: () async {
        HapticFeedback.lightImpact();
        final newTime = await showTimePicker(
          context: context,
          initialTime: _settings.reminderTime,
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppConstants.primaryColor,
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (newTime != null) {
          _saveSettings(_settings.copyWith(reminderTime: newTime));
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.schedule,
              color: AppConstants.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reminder Time',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeString,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              timeString,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextScaleTile() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.text_fields,
                  color: AppConstants.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Text Size',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Adjust content reading size',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(_settings.textScale * 100).toInt()}%',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppConstants.primaryColor,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: Colors.white,
              overlayColor: AppConstants.primaryColor.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _settings.textScale,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                _saveSettings(_settings.copyWith(textScale: value));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetProgressTile() {
    return _buildGlassContainer(
      onTap: () {
        HapticFeedback.lightImpact();
        _showResetConfirmDialog();
      },
      borderColor: AppConstants.errorColor.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.refresh,
              color: AppConstants.errorColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reset Progress',
                  style: TextStyle(
                    color: AppConstants.errorColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clear all learning progress',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return _buildGlassContainer(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return _buildGlassContainer(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: const Text(
              'Reset Progress?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'This will delete all your progress for the current difficulty level. This action cannot be undone.',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
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
                          content: const Text(
                            'Progress reset successfully',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: AppConstants.successColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(color: AppConstants.errorColor),
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
