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

  // Design constants
  static const Color _primary = Color(0xFFFF6B35);
  static const Color _background = Color(0xFF0D0D0D);
  static const Color _card = Color(0xFF1A1A1A);
  static const Color _text = Color(0xFF888888);
  static const Color _border = Color(0xFF333333);
  static const Color _success = Color(0xFF4CAF50);

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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(_primary),
              ),
              const SizedBox(height: 16),
              Text('Loading your journey...', style: TextStyle(color: _text)),
            ],
          ),
        ),
      );
    }

    if (_userProgress == null || _activeDifficulty == null) {
      return _buildWelcomeScreen();
    }

    return Scaffold(
      backgroundColor: _background,
      drawer: _buildSidebar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          color: _primary,
          backgroundColor: _card,
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
    return Scaffold(
      backgroundColor: _background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(Icons.camera_alt, color: _primary, size: 48),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to\nPhotography Guide',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Master photography in 30 days with personalized\nlessons tailored to your skill level',
                textAlign: TextAlign.center,
                style: TextStyle(color: _text, fontSize: 16, height: 1.5),
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
                    backgroundColor: _primary,
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

    return Drawer(
      backgroundColor: _card,
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
                  colors: [_primary, _primary.withOpacity(0.8)],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
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
                color: _background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
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
                        _success,
                      ),
                      _buildStatItem(
                        'Streak',
                        '${stats['currentStreak'] ?? 0}',
                        Icons.local_fire_department,
                        _primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (stats['completionRate'] ?? 0.0).toDouble(),
                    backgroundColor: _border,
                    valueColor: AlwaysStoppedAnimation(_primary),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${((stats['completionRate'] ?? 0.0) * 100).round()}% Current Track Complete',
                    style: TextStyle(color: _text, fontSize: 12),
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
                  const Divider(color: Color(0xFF333333), height: 32),
                  _buildDrawerItem(Icons.settings, 'Settings', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
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
                style: TextStyle(color: _text, fontSize: 12),
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(label, style: TextStyle(color: _text, fontSize: 12)),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: _text, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildHeader() {
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
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: Icon(Icons.menu, color: Colors.white, size: 24),
                ),
              ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, color: _primary, size: 16),
              const SizedBox(width: 8),
              Text(
                _getDifficultyDisplayName(_activeDifficulty!),
                style: TextStyle(
                  color: _primary,
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
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
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
                      color: _primary,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting $userName',
          style: TextStyle(
            color: _text,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ready to continue\nyour journey?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary.withOpacity(0.1), _primary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.1),
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
                      style: TextStyle(color: _text, fontSize: 12),
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
                    color: _success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _success.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: _success, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: _success,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentLesson!.description,
            style: TextStyle(color: _text, fontSize: 15, height: 1.5),
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
                  style: TextStyle(
                    color: _text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}% complete',
                  style: TextStyle(
                    color: _primary,
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
                color: _border,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primary, _primary.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withOpacity(0.3),
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
                backgroundColor: canAccess ? _primary : _border,
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
                color: _border.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: _text, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available ${LessonManager.getTimeUntilNextLesson(_activeDifficulty)}',
                          style: TextStyle(
                            color: _text,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Complete lessons daily to maintain your learning streak',
                          style: TextStyle(
                            color: _text.withOpacity(0.7),
                            fontSize: 12,
                          ),
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
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_success.withOpacity(0.15), _success.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _success.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _success.withOpacity(0.1),
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
              color: _success.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: _success.withOpacity(0.3), width: 2),
            ),
            child: Icon(Icons.emoji_events, color: _success, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            '${_getDifficultyDisplayName(_activeDifficulty!)} Track Complete!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You\'ve mastered all 30 lessons in your ${_getDifficultyDisplayName(_activeDifficulty!).toLowerCase()} photography journey. Time to capture the world with your new skills!',
            style: TextStyle(color: _text, fontSize: 16, height: 1.5),
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
                    backgroundColor: _success,
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
                    backgroundColor: _primary,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _text, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: _text,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(LessonStatus? status) {
    switch (status) {
      case LessonStatus.completed:
        return _success;
      case LessonStatus.inProgress:
        return _primary;
      case LessonStatus.current:
        return _primary;
      case LessonStatus.available:
        return Colors.blue;
      case LessonStatus.locked:
      case LessonStatus.lockedToday:
        return _text;
      default:
        return _text;
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

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.schedule, color: _primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Lesson Locked',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This lesson follows our daily learning schedule to help you build consistent learning habits.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next lesson available: $unlockTime',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Daily lessons help you maintain focus and avoid burnout while building strong learning habits.',
                        style: TextStyle(color: _text, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Understood', style: TextStyle(color: _primary)),
              ),
            ],
          ),
    );
  }

  Widget _buildProgressOverview() {
    final currentDay = _userProgress?.currentDay ?? 1;
    final progress = _userProgress?.overallProgress ?? 0.0;
    final streak = _userProgress?.dailyStreak ?? 0;

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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _success.withOpacity(0.3)),
                ),
                child: Text(
                  'Day $currentDay',
                  style: TextStyle(
                    color: _success,
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
                        color: _primary,
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
                          color: _primary,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$streak',
                          style: TextStyle(
                            color: _primary,
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
            backgroundColor: _border,
            valueColor: AlwaysStoppedAnimation(_primary),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.timeline,
                title: 'View Timeline',
                subtitle: 'All 30 lessons',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LessonTimelineScreen(),
                    ),
                  );
                  await _loadUserData();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.bookmark,
                title: 'Saved Content',
                subtitle: 'Your bookmarks',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedItemsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _primary, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: _text, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final completedLessons =
        _userProgress?.lessonProgress.values
            .where((p) => p.status == LessonStatus.completed)
            .take(3)
            .toList() ??
        [];

    if (completedLessons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...completedLessons.map((progress) {
          final lesson = LessonManager.getLessonById(progress.lessonId);
          if (lesson == null) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.check, color: _success, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${_getProgressDay(lesson.day, lesson.difficulty)}: ${lesson.title}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Completed ${progress.timeSpent} min ago',
                        style: TextStyle(color: _text, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    );
  }

  void _showDetailedStats() {
    final stats = LessonManager.getLessonStatistics(_activeDifficulty);

    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getDifficultyDisplayName(_activeDifficulty!)} Track Statistics',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildStatRow('Total Lessons', '${stats['totalLessons']}'),
                _buildStatRow('Completed', '${stats['completedLessons']}'),
                _buildStatRow(
                  'Completion Rate',
                  '${(stats['completionRate'] * 100).round()}%',
                ),
                _buildStatRow(
                  'Time Spent',
                  '${stats['totalTimeSpent']} minutes',
                ),
                _buildStatRow(
                  'Current Streak',
                  '${stats['currentStreak']} days',
                ),
                _buildStatRow(
                  'Difficulty Level',
                  _getDifficultyDisplayName(_activeDifficulty!),
                ),
              ],
            ),
          ),
    );
  }

  void _showAllTracksProgress() {
    final allStats = LessonManager.getAllStatistics();
    final availableDifficulties = UserPreferences.getAvailableDifficulties();

    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
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
                const Text(
                  'All Learning Tracks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
                                  ? _primary.withOpacity(0.1)
                                  : _background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isActive ? _primary.withOpacity(0.3) : _border,
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
                                  style: TextStyle(
                                    color: isActive ? _primary : Colors.white,
                                    fontSize: 18,
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
                                      color: _primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Active',
                                      style: TextStyle(
                                        color: _primary,
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
                              backgroundColor: _border.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation(
                                isActive ? _primary : _success,
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
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: _text, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: _text, fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'About Photography Guide',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Photography Guide is your companion for mastering photography in 30 days. With personalized lessons, practice exercises, and progress tracking, you\'ll develop your skills systematically across multiple difficulty levels.',
              style: TextStyle(color: _text, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Got it', style: TextStyle(color: _primary)),
              ),
            ],
          ),
    );
  }
}
