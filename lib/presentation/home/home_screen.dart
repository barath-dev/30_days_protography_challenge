import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/lesson.dart';
import '../../models/user_progress.dart';
import '../../services/user_preferences.dart';
import '../../services/lesson_manager.dart';
import 'saved_items_screen.dart';
import 'lesson_timeline_screen.dart';
import 'lesson_detail_screen.dart';
import '../onboarding/difficulty_selection_screen.dart';
import '../settings/settings_screen.dart';
import '../help/help_support_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  UserProgress? _userProgress;
  DifficultyLevel? _activeDifficulty;
  Lesson? _currentLesson;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Force reload user preferences to get fresh data
      await UserPreferences.init();

      _activeDifficulty = UserPreferences.activeDifficulty;
      _userProgress = UserPreferences.currentProgress;

      if (_userProgress != null && _activeDifficulty != null) {
        await UserPreferences.updateStreak();
        await LessonManager.unlockTodaysLesson(_activeDifficulty);

        // Reload progress after potential updates
        _userProgress = UserPreferences.currentProgress;

        _currentLesson = LessonManager.getCurrentLesson(_activeDifficulty);
      }

      if (mounted) {
        _animationController.forward();
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Force refresh method that can be called when data changes
  Future<void> _forceRefresh() async {
    if (mounted) {
      _animationController.reset();
      await _loadUserData();
    }
  }

  String _getDifficultyDisplayName(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
    }
  }

  // Helper method to convert actual lesson day to progress day
  int _getProgressDay(int actualDay, DifficultyLevel difficulty) {
    const Map<DifficultyLevel, int> dayOffsets = {
      DifficultyLevel.beginner: 0, // Days 1-30
      DifficultyLevel.intermediate: 30, // Days 31-60
      DifficultyLevel.advanced: 60, // Days 61-90
    };
    final offset = dayOffsets[difficulty] ?? 0;
    return actualDay - offset;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your journey...',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            ],
          ),
        ),
      );
    }

    if (_userProgress == null || _activeDifficulty == null) {
      return _buildWelcomeScreen();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _buildSidebar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          color: colorScheme.primary,
          backgroundColor: theme.cardColor,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildWelcomeSection(),
                  const SizedBox(height: 32),
                  _buildContinueLearningWidget(),
                  const SizedBox(height: 32),
                  _buildProgressOverview(),
                  const SizedBox(height: 32),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: colorScheme.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to\nLearn photography in 30days',
                textAlign: TextAlign.center,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Master photography in 30 days with personalized\nlessons tailored to your skill level',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DifficultySelectionScreen(),
                      ),
                    );

                    // If difficulty was selected, refresh the home screen
                    if (result == true) {
                      await _forceRefresh();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'Start Your Journey',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final difficulty = _activeDifficulty;
    final stats = LessonManager.getLessonStatistics(_activeDifficulty);
    final availableDifficulties = UserPreferences.getAvailableDifficulties();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: theme.cardColor,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Photography Student',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (difficulty != null)
                    Text(
                      '${_getDifficultyDisplayName(difficulty)} Level',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  if (availableDifficulties.length > 1) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${availableDifficulties.length} tracks started',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Progress Summary
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        'Completed',
                        '${stats['completedLessons'] ?? 0}',
                        Icons.check_circle,
                        colorScheme.tertiary,
                      ),
                      _buildStatItem(
                        'Streak',
                        '${stats['currentStreak'] ?? 0}',
                        Icons.local_fire_department,
                        colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (stats['completionRate'] ?? 0.0).toDouble(),
                    backgroundColor: theme.dividerColor,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${((stats['completionRate'] ?? 0.0) * 100).round()}% Current Track Complete',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildDrawerItem(Icons.timeline, 'Lesson Timeline', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LessonTimelineScreen(),
                      ),
                    );
                  }),
                  _buildDrawerItem(Icons.bookmark_outline, 'Saved Items', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedItemsScreen(),
                      ),
                    );
                  }),
                  _buildDrawerItem(
                    Icons.tune,
                    'Switch Learning Track',
                    () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DifficultySelectionScreen(),
                        ),
                      );

                      // If difficulty was changed, refresh the home screen
                      if (result == true) {
                        await _forceRefresh();
                      }
                    },
                  ),
                  _buildDrawerItem(Icons.insights, 'Progress Stats', () {
                    Navigator.pop(context);
                    _showDetailedStats();
                  }),
                  if (availableDifficulties.length > 1)
                    _buildDrawerItem(
                      Icons.compare_arrows,
                      'All Tracks Progress',
                      () {
                        Navigator.pop(context);
                        _showAllTracksProgress();
                      },
                    ),
                  const Divider(height: 32),
                  _buildDrawerItem(Icons.settings, 'Settings', () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                    // Refresh data when returning from settings (e.g. reset progress)
                    _loadUserData();
                  }),
                  _buildDrawerItem(Icons.help_outline, 'Help & Support', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    );
                  }),
                  _buildDrawerItem(Icons.info_outline, 'About', () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  }),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Photography Guide v1.0',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.textTheme.bodyMedium?.color, size: 22),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder:
              (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Icon(
                    Icons.menu,
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, color: colorScheme.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                _getDifficultyDisplayName(_activeDifficulty!),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.onSurface,
                  size: 24,
                ),
                // Notification dot
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    final greeting = _getGreeting();
    final userName = 'Photographer'; // Could be dynamic from user preferences
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting $userName',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ready to continue\nyour journey?',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueLearningWidget() {
    if (_currentLesson == null) {
      return _buildCourseCompletedBanner();
    }

    final progress =
        _userProgress?.getLessonProgress(_currentLesson!.id) ?? 0.0;

    // Convert actual lesson day to progress day for status checking
    final progressDay = _getProgressDay(
      _currentLesson!.day,
      _currentLesson!.difficulty,
    );
    final canAccess = _userProgress?.isDayUnlocked(progressDay) ?? false;
    final status = _userProgress?.getLessonStatus(
      _currentLesson!.id,
      progressDay,
    );

    final isCompleted = status == LessonStatus.completed;
    final isInProgress = progress > 0 && progress < 1.0;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(status, isInProgress),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Day ${_getProgressDay(_currentLesson!.day, _currentLesson!.difficulty)} of 30',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.tertiary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: colorScheme.tertiary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: colorScheme.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Lesson Title and Description
          Text(
            _currentLesson!.title,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentLesson!.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyMedium?.color,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 20),

          // Progress bar for in-progress lessons
          if (isInProgress) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}% complete',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Lesson metadata
          Row(
            children: [
              _buildMetaChip(
                Icons.access_time,
                '${_currentLesson!.estimatedDuration} min',
              ),
              const SizedBox(width: 12),
              _buildMetaChip(
                _getLessonTypeIcon(_currentLesson!.type),
                _getLessonTypeName(_currentLesson!.type),
              ),
              const SizedBox(width: 12),
              if (_currentLesson!.exercises.isNotEmpty)
                _buildMetaChip(
                  Icons.assignment_outlined,
                  '${_currentLesson!.exercises.length} exercises',
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  canAccess
                      ? () async {
                        HapticFeedback.mediumImpact();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    LessonDetailScreen(lesson: _currentLesson),
                          ),
                        );
                        await _loadUserData();
                      }
                      : () {
                        HapticFeedback.lightImpact();
                        _showLessonLockedDialog();
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canAccess ? colorScheme.primary : theme.disabledColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: canAccess ? 4 : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canAccess
                        ? isCompleted
                            ? Icons.replay
                            : isInProgress
                            ? Icons.play_arrow
                            : Icons.play_circle_filled
                        : Icons.lock,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canAccess
                        ? isCompleted
                            ? 'Review Lesson'
                            : isInProgress
                            ? 'Continue Learning'
                            : 'Start Lesson'
                        : 'Lesson Locked',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lock indicator for locked lessons
          if (!canAccess) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: theme.textTheme.bodyMedium?.color,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available ${LessonManager.getTimeUntilNextLesson(_activeDifficulty)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Complete lessons daily to maintain your learning streak',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseCompletedBanner() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final successColor = colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            successColor.withOpacity(0.15),
            successColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: successColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: successColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: successColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(Icons.emoji_events, color: successColor, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            '${_getDifficultyDisplayName(_activeDifficulty!)} Track Complete!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Keep white for contrast
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You\'ve mastered all 30 lessons in your ${_getDifficultyDisplayName(_activeDifficulty!).toLowerCase()} photography journey. Time to capture the world with your new skills!',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LessonTimelineScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Review Journey'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DifficultySelectionScreen(),
                      ),
                    );
                    if (result == true) {
                      await _forceRefresh();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Try New Track'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.textTheme.bodyMedium?.color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(LessonStatus? status) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    switch (status) {
      case LessonStatus.completed:
        return colorScheme.tertiary;
      case LessonStatus.inProgress:
        return colorScheme.primary;
      case LessonStatus.current:
        return colorScheme.primary;
      case LessonStatus.available:
        return Colors.blue;
      case LessonStatus.locked:
      case LessonStatus.lockedToday:
        return theme.disabledColor;
      default:
        return theme.disabledColor;
    }
  }

  IconData _getStatusIcon(LessonStatus? status) {
    switch (status) {
      case LessonStatus.completed:
        return Icons.check_circle;
      case LessonStatus.inProgress:
        return Icons.play_circle_filled;
      case LessonStatus.current:
        return Icons.radio_button_unchecked;
      case LessonStatus.available:
        return Icons.play_circle_outline;
      case LessonStatus.locked:
      case LessonStatus.lockedToday:
        return Icons.lock;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  String _getStatusText(LessonStatus? status, bool isInProgress) {
    switch (status) {
      case LessonStatus.completed:
        return 'Lesson Completed';
      case LessonStatus.inProgress:
        return isInProgress ? 'Continue Learning' : 'Ready to Start';
      case LessonStatus.current:
        return 'Today\'s Lesson';
      case LessonStatus.available:
        return 'Available Now';
      case LessonStatus.locked:
      case LessonStatus.lockedToday:
        return 'Coming Soon';
      default:
        return 'Ready to Learn';
    }
  }

  String _getLessonTypeName(LessonType type) {
    switch (type) {
      case LessonType.theory:
        return 'Theory';
      case LessonType.practice:
        return 'Practice';
      case LessonType.review:
        return 'Review';
      case LessonType.planning:
        return 'Planning';
      case LessonType.project:
        return 'Project';
      case LessonType.celebration:
        return 'Celebration';
    }
  }

  void _showLessonLockedDialog() {
    final nextProgressDay = _userProgress?.getMaxAvailableDay() ?? 1;
    final unlockTime =
        _userProgress?.getTimeUntilUnlock(nextProgressDay + 1) ?? 'Unknown';
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
            title: Row(
              children: [
                Icon(Icons.schedule, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text('Lesson Locked', style: theme.textTheme.titleLarge),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This lesson follows our daily learning schedule to help you build consistent learning habits.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next lesson available: $unlockTime',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Daily lessons help you maintain focus and avoid burnout while building strong learning habits.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Understood',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildProgressOverview() {
    final currentDay = _userProgress?.currentDay ?? 1;
    final progress = _userProgress?.overallProgress ?? 0.0;
    final streak = _userProgress?.dailyStreak ?? 0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getDifficultyDisplayName(_activeDifficulty!)} Track',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Keep white for contrast on dark card
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.tertiary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Day $currentDay',
                  style: TextStyle(
                    color: colorScheme.tertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Complete',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$streak',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Day Streak',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.dividerColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.theory:
        return Icons.school;
      case LessonType.practice:
        return Icons.camera_alt;
      case LessonType.review:
        return Icons.refresh;
      case LessonType.planning:
        return Icons.schedule;
      case LessonType.project:
        return Icons.assignment;
      case LessonType.celebration:
        return Icons.celebration;
    }
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Daily Challenge',
                Icons.camera,
                colorScheme.primary,
                () {
                  // Navigate to daily challenge
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Community',
                Icons.people_outline,
                colorScheme.tertiary,
                () {
                  // Navigate to community
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text('Tap to open', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LessonTimelineScreen(),
                  ),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Placeholder for recent activity list
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  color: theme.textTheme.bodyMedium?.color,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text('No recent activity', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text(
                  'Start a lesson to see your activity here',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            isDark
                ? [const Color(0xFF2D2D2D), const Color(0xFF1A1A1A)]
                : [
                  theme.cardColor,
                  theme.cardColor,
                ], // Use solid color for light mode or adjust as needed
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: theme.dividerColor),
      boxShadow:
          isDark
              ? null
              : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
    );
  }

  void _showDetailedStats() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stats = LessonManager.getLessonStatistics(_activeDifficulty);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (context, scrollController) => ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Your Progress Stats',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildStatCard(
                      'Total Lessons',
                      '${stats['totalLessons']}',
                      Icons.library_books,
                      colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Completed',
                      '${stats['completedLessons']}',
                      Icons.check_circle,
                      colorScheme.tertiary,
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Remaining',
                      '${stats['remainingLessons']}',
                      Icons.timelapse,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Completion Rate',
                      '${((stats['completionRate'] ?? 0.0) * 100).round()}%',
                      Icons.pie_chart,
                      Colors.blue,
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyMedium),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllTracksProgress() {
    final allStats = LessonManager.getAllStatistics();
    final availableDifficulties = UserPreferences.getAvailableDifficulties();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Learning Tracks',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: availableDifficulties.length,
                    itemBuilder: (context, index) {
                      final difficulty = availableDifficulties[index];
                      final difficultyName = _getDifficultyDisplayName(
                        difficulty,
                      );
                      final stats =
                          allStats[difficulty.toString().split('.').last] ?? {};
                      final isActive = difficulty == _activeDifficulty;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? colorScheme.primary.withOpacity(0.1)
                                  : theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isActive
                                    ? colorScheme.primary.withOpacity(0.3)
                                    : theme.dividerColor,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  difficultyName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color:
                                        isActive ? colorScheme.primary : null,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Active',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMiniStatItem(
                                    'Completed',
                                    '${stats['completedLessons'] ?? 0}/30',
                                  ),
                                ),
                                Expanded(
                                  child: _buildMiniStatItem(
                                    'Progress',
                                    '${((stats['completionRate'] ?? 0.0) * 100).round()}%',
                                  ),
                                ),
                                Expanded(
                                  child: _buildMiniStatItem(
                                    'Streak',
                                    '${stats['currentStreak'] ?? 0}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value:
                                  (stats['completionRate'] ?? 0.0).toDouble(),
                              backgroundColor: theme.dividerColor.withOpacity(
                                0.3,
                              ),
                              valueColor: AlwaysStoppedAnimation(
                                isActive
                                    ? colorScheme.primary
                                    : colorScheme.tertiary,
                              ),
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMiniStatItem(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  void _showAboutDialog() {
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
            title: Text(
              'About Photography Guide',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Photography Guide is your companion for mastering photography in 30 days. With personalized lessons, practice exercises, and progress tracking, you\'ll develop your skills systematically across multiple difficulty levels.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Got it',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
    );
  }
}
