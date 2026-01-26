import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/lesson.dart';
import '../../models/user_progress.dart';
import '../../services/user_preferences.dart';
import '../../services/lesson_manager.dart';
import 'lesson_detail_screen.dart';
import '../settings/settings_screen.dart';

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
      _userProgress = UserPreferences.currentProgress;

      if (_userProgress != null) {
        _lessons = LessonManager.getLessonsByDifficulty(
          _userProgress!.selectedDifficulty,
        );
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
    if (_userProgress == null) {
      return lesson.day == 1 ? LessonStatus.available : LessonStatus.locked;
    }
    final progressDay = _getProgressDay(lesson.day, lesson.difficulty);
    return _userProgress!.getLessonStatus(lesson.id, progressDay);
  }

  int _getProgressDay(int actualDay, DifficultyLevel difficulty) {
    const Map<DifficultyLevel, int> dayOffsets = {
      DifficultyLevel.beginner: 0,
      DifficultyLevel.intermediate: 30,
      DifficultyLevel.advanced: 60,
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep dark background
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildTimelineContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final difficultyName =
        _userProgress != null
            ? _getDifficultyDisplayName(_userProgress!.selectedDifficulty)
            : 'Unknown';
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: const Color(0xFF121212),
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
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            '$difficultyName Track',
            style: TextStyle(
              color: colorScheme.primary,
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
                    ? colorScheme.primary
                    : Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ).then((_) => _loadData());
          },
          icon: const Icon(Icons.settings, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTimelineContent() {
    if (_userProgress == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'No progress data found',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [_buildTimelineHeader(), Expanded(child: _buildTimelineList())],
    );
  }

  Widget _buildTimelineHeader() {
    final currentDay = _userProgress!.currentDay;
    final progress = _userProgress!.overallProgress;
    final completedLessons =
        _userProgress!.lessonProgress.values
            .where((p) => p.status == LessonStatus.completed)
            .length;

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1E1E), Color(0xFF0D0D0D)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day $currentDay',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Complete',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  Icons.auto_graph_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildGlassStat(
                  Icons.check_circle_outline_rounded,
                  '$completedLessons Lessons',
                  colorScheme.tertiary,
                ),
                const SizedBox(width: 12),
                _buildGlassStat(
                  Icons.local_fire_department_rounded,
                  '${_userProgress!.dailyStreak} Day Streak',
                  const Color(0xFFFF6B00),
                ),
                const SizedBox(width: 12),
                _buildGlassStat(
                  Icons.timer_outlined,
                  '${_getTotalTimeSpent()} Hours',
                  const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStat(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList() {
    if (_lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.white.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'No lessons found',
              style: TextStyle(color: Colors.white70),
            ),
            if (_filterType != null || _filterCategory != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterType = null;
                    _filterCategory = null;
                  });
                  _applyFilters();
                },
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _lessons.length,
      itemBuilder: (context, index) {
        final lesson = _lessons[index];
        final status = _getLessonStatus(lesson);
        final isLast = index == _lessons.length - 1;

        return _buildTimelineItem(lesson, status, isLast);
      },
    );
  }

  Widget _buildTimelineItem(Lesson lesson, LessonStatus status, bool isLast) {
    final progress = _userProgress?.getLessonProgress(lesson.id) ?? 0.0;
    final colorScheme = Theme.of(context).colorScheme;

    // Status Logic
    final isLocked =
        status == LessonStatus.locked || status == LessonStatus.lockedToday;
    final isActive =
        status == LessonStatus.current || status == LessonStatus.inProgress;
    final isCompleted = status == LessonStatus.completed;

    Color statusColor;
    if (isCompleted)
      statusColor = const Color(0xFF4CAF50);
    else if (isActive)
      statusColor = colorScheme.primary;
    else if (isLocked)
      statusColor = Colors.white.withOpacity(0.1);
    else
      statusColor = Colors.white.withOpacity(0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator Column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Node
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? statusColor : const Color(0xFF121212),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? Colors.white : statusColor,
                      width: 2,
                    ),
                    boxShadow:
                        isActive
                            ? [
                              BoxShadow(
                                color: statusColor.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                            : null,
                  ),
                  child: Center(
                    child:
                        isCompleted
                            ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                            : isLocked
                            ? Icon(
                              Icons.lock,
                              size: 14,
                              color: Colors.white.withOpacity(0.3),
                            )
                            : Text(
                              '${lesson.day}',
                              style: TextStyle(
                                color: isActive ? Colors.white : statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                // Connector Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            statusColor.withOpacity(isActive ? 1.0 : 0.5),
                            isCompleted
                                ? statusColor
                                : statusColor.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Lesson Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GestureDetector(
                onTap: () => _onLessonTap(lesson, status),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          isActive
                              ? [
                                colorScheme.primary.withOpacity(0.2),
                                colorScheme.primary.withOpacity(0.05),
                              ]
                              : [
                                const Color(0xFF2D2D2D),
                                const Color(0xFF1A1A1A),
                              ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isActive
                              ? colorScheme.primary.withOpacity(0.5)
                              : Colors.white.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Chips
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildGlassChip(
                              _getLessonTypeIcon(lesson.type),
                              _getLessonTypeName(lesson.type),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Current',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          lesson.title,
                          style: TextStyle(
                            color:
                                isLocked
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          lesson.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Footer: Metadata & Progress
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${lesson.estimatedDuration} min',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            if (isActive && progress > 0)
                              Text(
                                '${(progress * 100).round()}% Done',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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

  // Helper methods for icons and names
  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.theory:
        return Icons.auto_stories;
      case LessonType.practice:
        return Icons.camera_alt;
      case LessonType.review:
        return Icons.refresh;
      case LessonType.planning:
        return Icons.map;
      case LessonType.project:
        return Icons.image;
      case LessonType.celebration:
        return Icons.emoji_events;
    }
  }

  String _getLessonTypeName(LessonType type) {
    return type.toString().split('.').last[0].toUpperCase() +
        type.toString().split('.').last.substring(1);
  }

  void _onLessonTap(Lesson lesson, LessonStatus status) {
    if (status == LessonStatus.locked || status == LessonStatus.lockedToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This lesson is currently locked.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
    ).then((_) => _loadData());
  }

  void _showStatistics() {
    // Implement statistics dialog or navigation
  }

  void _showFilterOptions() {
    // Implement filter bottom sheet
  }
}
