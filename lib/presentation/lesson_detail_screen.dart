import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/lesson.dart';
import '../models/user_progress.dart';
import '../models/saved_item.dart';
import '../services/user_preferences.dart';
import '../services/lesson_manager.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson? lesson;
  final String? lessonId;

  const LessonDetailScreen({super.key, this.lesson, this.lessonId});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Lesson? _lesson;
  bool _isBookmarked = false;
  double _readingProgress = 0.0;
  LessonProgress? _lessonProgress;
  bool _isLoading = true;
  DateTime? _sessionStartTime;

  // Design constants
  static const Color _primaryColor = Color(0xFFFF6B35);
  static const Color _backgroundColor = Color(0xFF0D0D0D);
  static const Color _cardColor = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF888888);
  static const Color _borderColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_updateProgress);
    _sessionStartTime = DateTime.now();
    _loadLessonData();
  }

  @override
  void dispose() {
    _saveProgress();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLessonData() async {
    setState(() => _isLoading = true);

    try {
      // Get lesson data
      if (widget.lesson != null) {
        _lesson = widget.lesson;
      } else if (widget.lessonId != null) {
        _lesson = LessonManager.getLessonById(widget.lessonId!);
      }

      if (_lesson != null) {
        // Check if lesson can be accessed (daily restrictions)
        final userProgress = UserPreferences.currentProgress;
        if (userProgress != null && !userProgress.isDayUnlocked(_lesson!.day)) {
          // Show access denied and return to previous screen
          if (mounted) {
            _showAccessDeniedDialog();
            return;
          }
        }

        // Check if lesson is bookmarked
        _isBookmarked = await UserPreferences.isItemSaved(_lesson!.id);

        // Get lesson progress
        if (userProgress != null) {
          _lessonProgress = userProgress.lessonProgress[_lesson!.id];
          _readingProgress = _lessonProgress?.progressPercentage ?? 0.0;
        }

        // Start lesson if not started (and allowed)
        if (_lessonProgress == null ||
            _lessonProgress!.status == LessonStatus.locked) {
          await _startLesson();
        }

        _animationController.forward();
      }
    } catch (e) {
      print('Error loading lesson data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: _cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.lock, color: _primaryColor, size: 24),
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
                Text(
                  'This lesson is not available yet.',
                  style: TextStyle(color: _textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 12),
                if (_lesson != null) ...[
                  Text(
                    'Day ${_lesson!.day} will be unlocked: ${_getUnlockTimeText()}',
                    style: TextStyle(color: _primaryColor, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete one lesson per day to maintain your learning momentum.',
                    style: TextStyle(color: _textSecondary, fontSize: 14),
                  ),
                ],
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Return to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Back to Timeline'),
              ),
            ],
          ),
    );
  }

  String _getUnlockTimeText() {
    if (_lesson == null) return 'Unknown';

    final userProgress = UserPreferences.currentProgress;
    if (userProgress == null) return 'Unknown';

    return userProgress.getTimeUntilUnlock(_lesson!.day);
  }

  Future<void> _startLesson() async {
    if (_lesson == null) return;

    final startProgress = LessonProgress(
      lessonId: _lesson!.id,
      status: LessonStatus.inProgress,
      progressPercentage: 0.0,
      timeSpent: 0,
      lastAccessed: DateTime.now(),
      startedAt: DateTime.now(),
    );

    await UserPreferences.updateLessonProgress(_lesson!.id, startProgress);
    setState(() => _lessonProgress = startProgress);
  }

  void _updateProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final newProgress =
          maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;

      if (newProgress != _readingProgress) {
        setState(() => _readingProgress = newProgress);
        _saveProgressDebounced();
      }
    }
  }

  void _saveProgressDebounced() {
    // Simple debouncing to avoid too frequent saves
    Future.delayed(const Duration(seconds: 2), _saveProgress);
  }

  Future<void> _saveProgress() async {
    if (_lesson == null || _sessionStartTime == null) return;

    // Check if we can still save progress (daily restrictions)
    final userProgress = UserPreferences.currentProgress;
    if (userProgress == null || !userProgress.isDayUnlocked(_lesson!.day)) {
      return;
    }

    final sessionDuration =
        DateTime.now().difference(_sessionStartTime!).inMinutes;
    await LessonManager.updateLessonProgress(
      _lesson!.id,
      _readingProgress,
      sessionDuration,
    );
  }

  Future<void> _markAsCompleted() async {
    if (_lesson == null) return;

    // Check if we can complete this lesson (daily restrictions)
    final userProgress = UserPreferences.currentProgress;
    if (userProgress == null || !userProgress.isDayUnlocked(_lesson!.day)) {
      _showAccessDeniedDialog();
      return;
    }

    setState(() => _readingProgress = 1.0);
    await _saveProgress();

    final success = await LessonManager.markLessonCompleted(_lesson!.id);

    if (success && mounted) {
      _showCompletionDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to complete lesson at this time'),
          backgroundColor: _cardColor,
        ),
      );
    }
  }

  void _showCompletionDialog() {
    final nextLesson = LessonManager.getNextLesson(_lesson!.day);
    final timeUntilNext = LessonManager.getTimeUntilNextLesson();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.celebration, color: _primaryColor, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Lesson Complete!',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Great job! You\'ve completed "${_lesson!.title}".',
                  style: TextStyle(color: _textSecondary),
                ),
                const SizedBox(height: 16),
                if (nextLesson != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Lesson: ${nextLesson.title}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Available: $timeUntilNext',
                          style: TextStyle(color: _primaryColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Congratulations! You\'ve completed the entire 30-day course!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Review Later',
                  style: TextStyle(color: _textSecondary),
                ),
              ),
              if (nextLesson != null && timeUntilNext == 'Available now')
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToNextLesson();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Next Lesson'),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context); // Return to timeline/home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Back to Timeline'),
                ),
            ],
          ),
    );
  }

  void _navigateToNextLesson() {
    final nextLesson = LessonManager.getNextLesson(_lesson!.day);
    if (nextLesson != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LessonDetailScreen(lesson: nextLesson),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _toggleBookmark() async {
    if (_lesson == null) return;

    setState(() => _isBookmarked = !_isBookmarked);
    HapticFeedback.lightImpact();

    if (_isBookmarked) {
      final savedItem = SavedItem.fromLesson(_lesson!, DateTime.now());
      await UserPreferences.addSavedItem(savedItem);
    } else {
      await UserPreferences.removeSavedItem(_lesson!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
          ),
        ),
      );
    }

    if (_lesson == null) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: _backgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: const Center(
          child: Text(
            'Lesson not found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLessonHeader(),
                        const SizedBox(height: 30),
                        _buildObjectivesSection(),
                        const SizedBox(height: 30),
                        _buildContentSection(),
                        const SizedBox(height: 30),
                        if (_lesson!.exercises.isNotEmpty) ...[
                          _buildExercisesSection(),
                          const SizedBox(height: 30),
                        ],
                        _buildTechnicalDetails(),
                        const SizedBox(height: 30),
                        _buildActionButtons(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: _backgroundColor,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _cardColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _toggleBookmark,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked ? _primaryColor : Colors.white,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          _primaryColor.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _primaryColor, width: 2),
                    gradient: RadialGradient(
                      colors: [
                        _primaryColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(
                    _getTypeIcon(_lesson!.type),
                    size: 40,
                    color: _primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.theory:
        return Icons.school;
      case LessonType.practice:
        return Icons.camera_alt;
      case LessonType.review:
        return Icons.rate_review;
      case LessonType.planning:
        return Icons.info;
      case LessonType.project:
        return Icons.assignment;
      case LessonType.celebration:
        return Icons.celebration;
    }
  }

  Widget _buildProgressIndicator() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 4,
        color: _cardColor,
        child: LinearProgressIndicator(
          value: _readingProgress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
        ),
      ),
    );
  }

  Widget _buildLessonHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primaryColor, width: 1),
              ),
              child: Text(
                'Day ${_lesson!.day} • ${_getDifficultyName(_lesson!.difficulty)}',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.access_time, color: _textSecondary, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_lesson!.estimatedDuration} min read',
                  style: TextStyle(color: _textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _lesson!.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _lesson!.description,
          style: TextStyle(color: _textSecondary, fontSize: 16, height: 1.5),
        ),
      ],
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

  Widget _buildObjectivesSection() {
    if (_lesson!.objectives.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flag, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Learning Objectives',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._lesson!.objectives.map(
            (objective) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      objective,
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lesson Content',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Text(
            _lesson!.content,
            style: TextStyle(color: _textSecondary, fontSize: 16, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Practice Exercises',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._lesson!.exercises.map(
          (exercise) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor.withOpacity(0.1), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assignment, color: _primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      exercise.title,
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  exercise.description,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ...exercise.steps.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTechnicalDetails() {
    if (_lesson!.technicalDetails.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Technical Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._lesson!.technicalDetails.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      entry.key.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isCompleted = _lessonProgress?.status == LessonStatus.completed;
    final canMarkComplete =
        _readingProgress >= 0.8; // 80% reading progress required

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                (isCompleted || !canMarkComplete) ? null : _markAsCompleted,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _borderColor,
              disabledForegroundColor: _textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isCompleted
                  ? 'Completed ✓'
                  : canMarkComplete
                  ? 'Mark as Complete'
                  : 'Continue Reading (${(_readingProgress * 100).round()}%)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final previousLesson = LessonManager.getPreviousLesson(
                    _lesson!.day,
                  );
                  if (previousLesson != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => LessonDetailScreen(lesson: previousLesson),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: _borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final nextLesson = LessonManager.getNextLesson(_lesson!.day);
                  if (nextLesson != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonDetailScreen(lesson: nextLesson),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: _borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
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
      border: Border.all(color: _borderColor, width: 1),
    );
  }
}
