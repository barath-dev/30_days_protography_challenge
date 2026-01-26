import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/lesson.dart';
import '../../models/user_progress.dart';
import '../../models/saved_item.dart';
import '../../services/user_preferences.dart';
import '../../services/lesson_manager.dart';
import '../widgets/full_screen_image_viewer.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson? lesson;
  final String? lessonId;

  const LessonDetailScreen({super.key, this.lesson, this.lessonId});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _progressAnimation;

  Lesson? _lesson;
  bool _isBookmarked = false;
  double _readingProgress = 0.0;
  LessonProgress? _lessonProgress;
  bool _isLoading = true;
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
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
    _progressAnimationController.dispose();
    super.dispose();
  }

  // Helper method to convert actual lesson day to progress day
  int _getProgressDay(int actualDay, DifficultyLevel difficulty) {
    const Map<DifficultyLevel, int> dayOffsets = {
      DifficultyLevel.beginner: 0,
      DifficultyLevel.intermediate: 30,
      DifficultyLevel.advanced: 60,
    };
    final offset = dayOffsets[difficulty] ?? 0;
    return actualDay - offset;
  }

  Future<void> _loadLessonData() async {
    setState(() => _isLoading = true);

    try {
      if (widget.lesson != null) {
        _lesson = widget.lesson;
      } else if (widget.lessonId != null) {
        _lesson = LessonManager.getLessonById(widget.lessonId!);
      }

      if (_lesson != null) {
        final progressDay = _getProgressDay(_lesson!.day, _lesson!.difficulty);

        final userProgress = UserPreferences.currentProgress;
        if (userProgress != null && !userProgress.isDayUnlocked(progressDay)) {
          if (mounted) {
            _showAccessDeniedDialog();
            return;
          }
        }

        _isBookmarked = await UserPreferences.isItemSaved(_lesson!.id);

        if (userProgress != null) {
          _lessonProgress = userProgress.lessonProgress[_lesson!.id];
          _readingProgress = _lessonProgress?.progressPercentage ?? 0.0;
        }

        if (_lessonProgress == null ||
            _lessonProgress!.status == LessonStatus.locked) {
          await _startLesson();
        }

        _animationController.forward();
        _progressAnimationController.forward();
      }
    } catch (e) {
      print('Error loading lesson data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAccessDeniedDialog() {
    final progressDay =
        _lesson != null
            ? _getProgressDay(_lesson!.day, _lesson!.difficulty)
            : 0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Lesson Locked',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This lesson is not available yet.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (_lesson != null) ...[
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
                          'Day $progressDay unlocks: ${_getUnlockTimeText()}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete one lesson per day to maintain your learning momentum.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Back to Timeline',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  String _getUnlockTimeText() {
    if (_lesson == null) return 'Unknown';
    final userProgress = UserPreferences.currentProgress;
    if (userProgress == null) return 'Unknown';
    final progressDay = _getProgressDay(_lesson!.day, _lesson!.difficulty);
    return userProgress.getTimeUntilUnlock(progressDay);
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
    Future.delayed(const Duration(seconds: 2), _saveProgress);
  }

  Future<void> _saveProgress() async {
    if (_lesson == null || _sessionStartTime == null) return;

    final progressDay = _getProgressDay(_lesson!.day, _lesson!.difficulty);
    final userProgress = UserPreferences.currentProgress;
    if (userProgress == null || !userProgress.isDayUnlocked(progressDay)) {
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

    final progressDay = _getProgressDay(_lesson!.day, _lesson!.difficulty);
    final userProgress = UserPreferences.currentProgress;
    if (userProgress == null || !userProgress.isDayUnlocked(progressDay)) {
      _showAccessDeniedDialog();
      return;
    }

    setState(() => _readingProgress = 1.0);
    await _saveProgress();

    final success = await LessonManager.markLessonCompleted(_lesson!.id);

    if (success && mounted) {
      _showCompletionDialog();
    } else if (mounted) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to complete lesson at this time'),
          backgroundColor: theme.cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showCompletionDialog() {
    final currentProgressDay = _getProgressDay(
      _lesson!.day,
      _lesson!.difficulty,
    );
    final nextLesson = LessonManager.getNextLesson(currentProgressDay);
    final timeUntilNext = LessonManager.getTimeUntilNextLesson();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.celebration_rounded,
                    color: colorScheme.tertiary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Lesson Complete!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Excellent work! You\'ve mastered "${_lesson!.title}".',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                if (nextLesson != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.1),
                          colorScheme.secondary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Up Next',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextLesson.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Available: $timeUntilNext',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],
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
                  style: TextStyle(color: theme.textTheme.bodySmall?.color),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (nextLesson != null && timeUntilNext == 'Available now') {
                    _navigateToNextLesson();
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  nextLesson != null && timeUntilNext == 'Available now'
                      ? 'Next Lesson'
                      : 'Back to Timeline',
                ),
              ),
            ],
          ),
    );
  }

  void _navigateToNextLesson() {
    final currentProgressDay = _getProgressDay(
      _lesson!.day,
      _lesson!.difficulty,
    );
    final nextLesson = LessonManager.getNextLesson(currentProgressDay);
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
      final savedItem = SavedItem(
        id: _lesson!.id,
        title: _lesson!.title,
        description: _lesson!.description,
        type: SavedItemType.tip,
        category:
            _lesson!.categories.isNotEmpty
                ? _lesson!.categories.first
                : 'lesson',
        duration: _lesson!.estimatedDuration,
        savedDate: DateTime.now(),
      );
      await UserPreferences.addSavedItem(savedItem);
    } else {
      await UserPreferences.removeSavedItem(_lesson!.id);
    }
  }

  @override
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text('Loading lesson...', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    if (_lesson == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: theme.textTheme.bodySmall?.color,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Lesson not found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The requested lesson could not be loaded',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLessonHeader(),
                              const SizedBox(height: 32),
                              _buildStatsRow(),
                              const SizedBox(height: 32),
                              _buildObjectivesSection(),
                              const SizedBox(height: 32),
                              _buildContentSection(),
                              const SizedBox(height: 32),
                              _buildImageGallery(),
                              const SizedBox(height: 32),
                              if (_lesson!.exercises.isNotEmpty) ...[
                                _buildExercisesSection(),
                                const SizedBox(height: 32),
                              ],
                              _buildTechnicalDetails(),
                              const SizedBox(height: 32),
                              _buildActionButtons(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: _buildAppBarButton(
        icon: Icons.arrow_back_rounded,
        onTap: () => Navigator.pop(context),
      ),
      actions: [
        _buildAppBarButton(
          icon:
              _isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
          onTap: _toggleBookmark,
          isActive: _isBookmarked,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.cardColor, theme.scaffoldBackgroundColor],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _PatternPainter(
                        progress: _progressAnimation.value,
                        primaryColor: colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.3),
                            colorScheme.primary.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getTypeIcon(_lesson!.type),
                        size: 36,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getTypeName(_lesson!.type),
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isActive
                    ? colorScheme.primary.withOpacity(0.5)
                    : theme.dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color:
              isActive ? colorScheme.primary : theme.textTheme.bodyLarge?.color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSection(
      title: 'Lesson Content',
      icon: Icons.auto_stories_rounded,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: MarkdownBody(
          data: _lesson!.content,
          styleSheet: MarkdownStyleSheet(
            h1: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            h2: theme.textTheme.titleLarge?.copyWith(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            h3: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.titleMedium?.color,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            p: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            strong: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            listBullet: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.primary,
            ),
            blockquote: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              fontStyle: FontStyle.italic,
            ),
            blockquoteDecoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: colorScheme.primary, width: 4),
              ),
            ),
            code: theme.textTheme.bodyMedium?.copyWith(
              backgroundColor: theme.scaffoldBackgroundColor,
              fontFamily: 'monospace',
            ),
            codeblockDecoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            blockSpacing: 16,
          ),
          onTapLink: (text, href, title) {
            // Handle links if necessary
          },
        ),
      ),
    );
  }

  IconData _getTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.theory:
        return Icons.auto_stories_rounded;
      case LessonType.practice:
        return Icons.camera_alt_rounded;
      case LessonType.review:
        return Icons.rate_review_rounded;
      case LessonType.planning:
        return Icons.lightbulb_outline_rounded;
      case LessonType.project:
        return Icons.assignment_turned_in_rounded;
      case LessonType.celebration:
        return Icons.celebration_rounded;
    }
  }

  String _getTypeName(LessonType type) {
    switch (type) {
      case LessonType.theory:
        return 'THEORY LESSON';
      case LessonType.practice:
        return 'HANDS-ON PRACTICE';
      case LessonType.review:
        return 'REVIEW & REFLECTION';
      case LessonType.planning:
        return 'PLANNING SESSION';
      case LessonType.project:
        return 'PROJECT WORK';
      case LessonType.celebration:
        return 'MILESTONE';
    }
  }

  Widget _buildProgressIndicator() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.scaffoldBackgroundColor, theme.cardColor],
          ),
        ),
        child: LinearProgressIndicator(
          value: _readingProgress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildLessonHeader() {
    final progressDay = _getProgressDay(_lesson!.day, _lesson!.difficulty);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Day $progressDay • ${_getDifficultyName(_lesson!.difficulty)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: theme.textTheme.bodyMedium?.color,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_lesson!.estimatedDuration} min',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          _lesson!.title,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        if (_lesson!.subtitle.isNotEmpty) ...[
          Text(
            _lesson!.subtitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          _lesson!.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final isCompleted = _lessonProgress?.status == LessonStatus.completed;
    final progressPercentage = (_readingProgress * 100).round();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up_rounded,
            label: 'Progress',
            value: '$progressPercentage%',
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon:
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
            label: 'Status',
            value: isCompleted ? 'Completed' : 'In Progress',
            color: isCompleted ? colorScheme.tertiary : colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.menu_book_rounded,
            label: 'Type',
            value: _getTypeName(_lesson!.type).split(' ')[0],
            color: theme.textTheme.bodyMedium?.color ?? Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
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

  Widget _buildObjectivesSection() {
    if (_lesson!.objectives.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSection(
      title: 'Learning Objectives',
      icon: Icons.flag_rounded,
      child: Column(
        children:
            _lesson!.objectives
                .asMap()
                .entries
                .map(
                  (entry) => Container(
                    margin: EdgeInsets.only(
                      bottom:
                          entry.key < _lesson!.objectives.length - 1 ? 12 : 0,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildExercisesSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSection(
      title: 'Practice Exercises',
      icon: Icons.fitness_center_rounded,
      child: Column(
        children:
            _lesson!.exercises
                .map(
                  (exercise) => Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withOpacity(0.1),
                          colorScheme.secondary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.assignment_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                exercise.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          exercise.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...exercise.steps.asMap().entries.map(
                          (entry) => Container(
                            margin: EdgeInsets.only(
                              bottom:
                                  entry.key < exercise.steps.length - 1
                                      ? 12
                                      : 0,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.primary,
                                        colorScheme.secondary,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: theme.textTheme.bodyMedium?.copyWith(
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
                )
                .toList(),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (_lesson!.imageUrls.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return _buildSection(
      title: 'Visual Guide',
      icon: Icons.image_rounded,
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _lesson!.imageUrls.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final url = _lesson!.imageUrls[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => FullScreenImageViewer(
                            imageUrls: _lesson!.imageUrls,
                            initialIndex: index,
                          ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            color: theme.cardColor,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  color: theme.disabledColor,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not found',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTechnicalDetails() {
    if (_lesson!.technicalDetails.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSection(
      title: 'Technical Details',
      icon: Icons.settings_rounded,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children:
              _lesson!.technicalDetails.entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              entry.key.replaceAll('_', ' ').toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        child,
      ],
    );
  }

  void _navigateToPreviousLesson() {
    final currentProgressDay = _getProgressDay(
      _lesson!.day,
      _lesson!.difficulty,
    );
    final previousLesson = LessonManager.getPreviousLesson(currentProgressDay);
    if (previousLesson != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LessonDetailScreen(lesson: previousLesson),
        ),
      );
    }
  }

  void _scrollToNextSection() {
    _scrollController.animateTo(
      _scrollController.offset + 300,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildActionButtons() {
    final isCompleted = _lessonProgress?.status == LessonStatus.completed;
    final canMarkComplete = _readingProgress >= 0.9;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentProgressDay = _getProgressDay(
      _lesson!.day,
      _lesson!.difficulty,
    );
    final hasPrevious =
        LessonManager.getPreviousLesson(currentProgressDay) != null;
    final hasNext = LessonManager.getNextLesson(currentProgressDay) != null;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient:
                (isCompleted || !canMarkComplete)
                    ? null
                    : LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  (isCompleted || !canMarkComplete)
                      ? theme.dividerColor
                      : Colors.transparent,
            ),
          ),
          child: ElevatedButton(
            onPressed:
                canMarkComplete && !isCompleted
                    ? _markAsCompleted
                    : (!isCompleted ? _scrollToNextSection : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCompleted) ...[
                  Icon(
                    Icons.check_circle_rounded,
                    color: colorScheme.tertiary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else if (canMarkComplete) ...[
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mark as Complete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.menu_book_rounded,
                    color: theme.textTheme.bodySmall?.color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue Reading (${(_readingProgress * 100).round()}%)',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (hasPrevious) ...[
              Expanded(
                child: _buildNavButton(
                  label: 'Previous',
                  icon: Icons.arrow_back_rounded,
                  onPressed: _navigateToPreviousLesson,
                  isPrimary: false,
                ),
              ),
              if (hasNext) const SizedBox(width: 16),
            ],
            if (hasNext) ...[
              Expanded(
                child: _buildNavButton(
                  label: 'Next',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _navigateToNextLesson,
                  isPrimary: true,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient:
            isPrimary
                ? LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.2),
                    colorScheme.secondary.withOpacity(0.1),
                  ],
                )
                : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isPrimary
                  ? colorScheme.primary.withOpacity(0.3)
                  : theme.dividerColor,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (label == 'Previous') ...[
              Icon(
                icon,
                color:
                    isPrimary
                        ? colorScheme.primary
                        : theme.textTheme.bodyMedium?.color,
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color:
                    isPrimary
                        ? colorScheme.primary
                        : theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (label == 'Next') ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                color:
                    isPrimary
                        ? colorScheme.primary
                        : theme.textTheme.bodyMedium?.color,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  _PatternPainter({required this.progress, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = primaryColor.withOpacity(0.05)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.4;

    for (int i = 0; i < 3; i++) {
      final radius = (maxRadius * (i + 1) / 3) * progress;
      canvas.drawCircle(center, radius, paint);
    }

    final iconPaint =
        Paint()
          ..color = primaryColor.withOpacity(0.03)
          ..style = PaintingStyle.fill;

    final gridSpacing = 60.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      for (double y = 0; y < size.height; y += gridSpacing) {
        if ((x / gridSpacing + y / gridSpacing) % 2 == 0) {
          canvas.drawCircle(Offset(x, y), 2 * progress, iconPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
