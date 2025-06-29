import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/lesson.dart';
import '../models/user_progress.dart';
import '../services/user_preferences.dart';
import '../services/lesson_manager.dart';
import 'lesson_detail_screen.dart';

class LessonTimelineScreen extends StatefulWidget {
  const LessonTimelineScreen({super.key});

  @override
  State<LessonTimelineScreen> createState() => _LessonTimelineScreenState();
}

class _LessonTimelineScreenState extends State<LessonTimelineScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Lesson> _lessons = [];
  UserProgress? _userProgress;
  bool _isLoading = true;
  LessonType? _filterType;
  String? _filterCategory;

  // Simple color scheme
  static const Color _primary = Color(0xFFFF6B35);
  static const Color _background = Color(0xFF0D0D0D);
  static const Color _card = Color(0xFF1A1A1A);
  static const Color _text = Color(0xFF888888);
  static const Color _border = Color(0xFF333333);
  static const Color _success = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load user progress first
      _userProgress = UserPreferences.currentProgress;

      if (_userProgress != null) {
        // Load lessons for the current user's difficulty level only
        _lessons = LessonManager.getLessonsByDifficulty(
          _userProgress!.selectedDifficulty,
        );

        // Apply any active filters
        _applyFilters();
      }

      setState(() => _isLoading = false);
      _controller.forward();
    } catch (e) {
      print('Error loading timeline data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    if (_userProgress == null) return;

    List<Lesson> filteredLessons = LessonManager.getLessonsByDifficulty(
      _userProgress!.selectedDifficulty,
    );

    if (_filterType != null) {
      filteredLessons =
          filteredLessons
              .where((lesson) => lesson.type == _filterType)
              .toList();
    }

    if (_filterCategory != null) {
      filteredLessons =
          filteredLessons
              .where((lesson) => lesson.categories.contains(_filterCategory))
              .toList();
    }

    setState(() {
      _lessons = filteredLessons;
    });
  }

  LessonStatus _getLessonStatus(Lesson lesson) {
    if (_userProgress == null) return LessonStatus.available; //TODO

    // Convert actual lesson day to progress day for status checking
    final progressDay = _getProgressDay(lesson.day, lesson.difficulty);
    return _userProgress!.getLessonStatus(lesson.id, progressDay);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildTimelineContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final difficultyName =
        _userProgress != null
            ? _getDifficultyDisplayName(_userProgress!.selectedDifficulty)
            : 'Unknown';

    return AppBar(
      backgroundColor: _background,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '30-Day Journey',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            '$difficultyName Track',
            style: TextStyle(
              color: _primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showStatistics,
          icon: const Icon(Icons.insights, color: Colors.white),
        ),
        IconButton(
          onPressed: _showFilterOptions,
          icon: Icon(
            Icons.filter_list,
            color:
                (_filterType != null || _filterCategory != null)
                    ? _primary
                    : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(_primary),
      ),
    );
  }

  Widget _buildTimelineContent() {
    if (_userProgress == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: _text, size: 64),
            const SizedBox(height: 16),
            Text(
              'No progress data found',
              style: TextStyle(color: _text, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [_buildProgress(), Expanded(child: _buildTimeline())],
    );
  }

  Widget _buildProgress() {
    if (_userProgress == null) return const SizedBox.shrink();

    final currentDay = _userProgress!.currentDay;
    final progress = _userProgress!.overallProgress;
    final completedLessons =
        _userProgress!.lessonProgress.values
            .where((p) => p.status == LessonStatus.completed)
            .length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $currentDay of 30',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: _border,
            valueColor: AlwaysStoppedAnimation(_primary),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                Icons.check_circle,
                '$completedLessons',
                'Completed',
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                Icons.access_time,
                '${_userProgress!.dailyStreak}',
                'Day Streak',
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                Icons.schedule,
                '${_getTotalTimeSpent()}',
                'Hours',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: _primary, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: _text, fontSize: 12)),
      ],
    );
  }

  int _getTotalTimeSpent() {
    if (_userProgress == null) return 0;
    final totalMinutes = _userProgress!.lessonProgress.values.fold<int>(
      0,
      (sum, progress) => sum + progress.timeSpent,
    );
    return (totalMinutes / 60).round();
  }

  Widget _buildTimeline() {
    if (_lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: _text, size: 64),
            const SizedBox(height: 16),
            Text(
              'No lessons found',
              style: TextStyle(color: _text, fontSize: 16),
            ),
            if (_filterType != null || _filterCategory != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterType = null;
                    _filterCategory = null;
                  });
                  _applyFilters();
                },
                child: Text('Clear Filters', style: TextStyle(color: _primary)),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _primary,
      backgroundColor: _card,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _lessons.length,
        itemBuilder: (context, index) {
          final lesson = _lessons[index];
          final status = _getLessonStatus(lesson);
          final isLast = index == _lessons.length - 1;
          final delay = index * 0.05;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animation = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(delay, (delay + 0.3).clamp(0, 1)),
                ),
              );

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: _buildTimelineItem(lesson, status, isLast),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(Lesson lesson, LessonStatus status, bool isLast) {
    final progress = _userProgress?.getLessonProgress(lesson.id) ?? 0.0;
    final progressDay = _getProgressDay(lesson.day, lesson.difficulty);
    final unlockTime =
        _userProgress?.getTimeUntilUnlock(progressDay) ?? 'Unknown';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column with indicator and line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                _buildIndicator(lesson, status),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _getLineColor(status),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: _buildLessonCard(lesson, status, progress, unlockTime),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLineColor(LessonStatus status) {
    switch (status) {
      case LessonStatus.completed:
        return _success;
      case LessonStatus.current:
      case LessonStatus.inProgress:
        return _primary;
      case LessonStatus.available:
        return _text;
      case LessonStatus.locked:
      case LessonStatus.lockedToday:
        return _border;
    }
  }

  Widget _buildIndicator(Lesson lesson, LessonStatus status) {
    Color color;
    Widget child;

    switch (status) {
      case LessonStatus.completed:
        color = _success;
        child = const Icon(Icons.check, color: Colors.white, size: 16);
        break;
      case LessonStatus.current:
      case LessonStatus.inProgress:
        color = _primary;
        child = Text(
          '${lesson.day}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        break;
      case LessonStatus.available:
        color = _text;
        child = Text(
          '${lesson.day}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        break;
      case LessonStatus.locked:
      case LessonStatus.lockedToday:
        color = _border;
        child = Icon(Icons.lock, color: _text, size: 14);
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border:
            (status == LessonStatus.current ||
                    status == LessonStatus.inProgress)
                ? Border.all(color: Colors.white, width: 2)
                : null,
        boxShadow:
            (status == LessonStatus.current ||
                    status == LessonStatus.inProgress)
                ? [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Center(child: child),
    );
  }

  Widget _buildLessonCard(
    Lesson lesson,
    LessonStatus status,
    double progress,
    String unlockTime,
  ) {
    final isLocked =
        status == LessonStatus.locked || status == LessonStatus.lockedToday;
    final isCompleted = status == LessonStatus.completed;
    final isInProgress = status == LessonStatus.inProgress;
    final canAccess = !isLocked;

    return GestureDetector(
      onTap: () => _onLessonTap(lesson, status),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                (status == LessonStatus.current ||
                        status == LessonStatus.inProgress)
                    ? _primary
                    : _border,
            width:
                (status == LessonStatus.current ||
                        status == LessonStatus.inProgress)
                    ? 2
                    : 1,
          ),
          boxShadow:
              (status == LessonStatus.current ||
                      status == LessonStatus.inProgress)
                  ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(lesson.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getTypeName(lesson.type),
                    style: TextStyle(
                      color: _getTypeColor(lesson.type),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Day ${lesson.day}: ${lesson.title}',
              style: TextStyle(
                color: canAccess ? Colors.white : _text,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lesson.description,
              style: TextStyle(
                color: canAccess ? _text : _text.withOpacity(0.6),
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Show unlock time for locked lessons
            if (isLocked) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, color: _text, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Available: $unlockTime',
                      style: TextStyle(color: _text, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Progress bar for in-progress lessons
            if (isInProgress && progress > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(color: _text, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: _border,
                valueColor: AlwaysStoppedAnimation(_primary),
                minHeight: 3,
                borderRadius: BorderRadius.circular(1.5),
              ),
              const SizedBox(height: 8),
            ],

            Row(
              children: [
                Icon(Icons.schedule, color: _text, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${lesson.estimatedDuration} min',
                  style: TextStyle(color: _text, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category, color: _text, size: 14),
                const SizedBox(width: 4),
                Text(
                  lesson.categories.isNotEmpty
                      ? lesson.categories.first
                      : 'General',
                  style: TextStyle(color: _text, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(LessonStatus status) {
    String text;
    Color color;

    switch (status) {
      case LessonStatus.completed:
        text = 'Completed';
        color = _success;
        break;
      case LessonStatus.current:
        text = 'Current';
        color = _primary;
        break;
      case LessonStatus.inProgress:
        text = 'In Progress';
        color = _primary;
        break;
      case LessonStatus.available:
        text = 'Available';
        color = _text;
        break;
      case LessonStatus.locked:
      case LessonStatus.lockedToday:
        text = 'Locked';
        color = _border;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getTypeColor(LessonType type) {
    switch (type) {
      case LessonType.theory:
        return const Color(0xFF2196F3);
      case LessonType.practice:
        return _primary;
      case LessonType.review:
        return const Color(0xFF9C27B0);
      case LessonType.planning:
        return _success;
      case LessonType.project:
        return const Color(0xFFFFEB3B);
      case LessonType.celebration:
        return const Color(0xFFE91E63);
    }
  }

  String _getTypeName(LessonType type) {
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

  void _onLessonTap(Lesson lesson, LessonStatus status) {
    // if (status == LessonStatus.locked || status == LessonStatus.lockedToday) {
    //   HapticFeedback.lightImpact();
    //   _showLockedDialog();
    //   return;
    // } //TODO

    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
    ).then((_) {
      // Reload data when returning from lesson detail
      _loadData();
    });
  }

  void _showLockedDialog() {
    final userProgress = _userProgress;
    if (userProgress == null) return;

    final nextProgressDay = userProgress.getMaxAvailableDay() + 1;
    final unlockTime = userProgress.getTimeUntilUnlock(nextProgressDay);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                  'This lesson follows our daily learning schedule.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
                      const SizedBox(height: 4),
                      Text(
                        'Complete one lesson per day to build a strong learning habit.',
                        style: TextStyle(color: _text, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
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

  void _showStatistics() {
    final stats = LessonManager.getLessonStatistics();

    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_getDifficultyDisplayName(_userProgress!.selectedDifficulty)} Track',
                  style: TextStyle(color: _primary, fontSize: 14),
                ),
                const SizedBox(height: 20),
                _buildStatRow('Total Lessons', '${stats['totalLessons']}'),
                _buildStatRow('Completed', '${stats['completedLessons']}'),
                _buildStatRow('In Progress', '${stats['inProgressLessons']}'),
                _buildStatRow(
                  'Completion Rate',
                  '${(stats['completionRate'] * 100).round()}%',
                ),
                _buildStatRow(
                  'Total Time Spent',
                  '${stats['totalTimeSpent']} minutes',
                ),
                _buildStatRow(
                  'Current Streak',
                  '${stats['currentStreak']} days',
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: _text, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Lessons',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_filterType != null || _filterCategory != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _filterType = null;
                            _filterCategory = null;
                          });
                          _applyFilters();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Clear All',
                          style: TextStyle(color: _primary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'By Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFilterOption('All Lessons', Icons.list, () {
                  setState(() {
                    _filterType = null;
                    _filterCategory = null;
                  });
                  _applyFilters();
                  Navigator.pop(context);
                }),
                _buildFilterOption('Completed Only', Icons.check_circle, () {
                  // Filter by completed status would need custom logic
                  Navigator.pop(context);
                }),
                _buildFilterOption('Available Lessons', Icons.play_circle, () {
                  // Filter by available status would need custom logic
                  Navigator.pop(context);
                }),
                const SizedBox(height: 16),
                const Text(
                  'By Type',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFilterOption('Theory Lessons', Icons.school, () {
                  setState(() {
                    _filterType = LessonType.theory;
                    _filterCategory = null;
                  });
                  _applyFilters();
                  Navigator.pop(context);
                }),
                _buildFilterOption('Practice Sessions', Icons.camera_alt, () {
                  setState(() {
                    _filterType = LessonType.practice;
                    _filterCategory = null;
                  });
                  _applyFilters();
                  Navigator.pop(context);
                }),
                _buildFilterOption('Projects', Icons.assignment, () {
                  setState(() {
                    _filterType = LessonType.project;
                    _filterCategory = null;
                  });
                  _applyFilters();
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: _text),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
