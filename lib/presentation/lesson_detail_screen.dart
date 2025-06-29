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

  // Enhanced design constants
  static const Color _primaryColor = Color(0xFFFF6B35);
  static const Color _secondaryColor = Color(0xFFFFB800);
  static const Color _backgroundColor = Color(0xFF0B0B0B);
  static const Color _surfaceColor = Color(0xFF1C1C1E);
  static const Color _cardColor = Color(0xFF2C2C2E);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFAAAAAA);
  static const Color _textTertiary = Color(0xFF666666);
  static const Color _borderColor = Color(0xFF3C3C3E);
  static const Color _successColor = Color(0xFF30D158);
  static const Color _warningColor = Color(0xFFFF9F0A);

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: _surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    color: _warningColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lesson Locked',
                  style: TextStyle(
                    color: _textPrimary,
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
                  style: TextStyle(color: _textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (_lesson != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day $progressDay unlocks: ${_getUnlockTimeText()}',
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete one lesson per day to maintain your learning momentum.',
                          style: TextStyle(color: _textSecondary, fontSize: 13),
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
                    color: _primaryColor,
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
    if (userProgress == null || !userProgress.isDayUnlocked(progressDay))
      return;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to complete lesson at this time'),
          backgroundColor: _surfaceColor,
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

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.celebration_rounded,
                    color: _successColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lesson Complete!',
                  style: TextStyle(
                    color: _textPrimary,
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
                  style: TextStyle(color: _textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 20),
                if (nextLesson != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _primaryColor.withOpacity(0.1),
                          _secondaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: _primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Up Next',
                              style: TextStyle(
                                color: _primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextLesson.title,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Available: $timeUntilNext',
                          style: TextStyle(color: _primaryColor, fontSize: 13),
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
                  style: TextStyle(color: _textTertiary),
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
                  backgroundColor: _primaryColor,
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading lesson...',
                style: TextStyle(color: _textSecondary, fontSize: 16),
              ),
            ],
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
            icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, color: _textTertiary, size: 64),
              const SizedBox(height: 16),
              Text(
                'Lesson not found',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The requested lesson could not be loaded',
                style: TextStyle(color: _textSecondary, fontSize: 16),
              ),
            ],
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
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: _backgroundColor,
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
              colors: [_surfaceColor, _backgroundColor],
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
                        primaryColor: _primaryColor,
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
                            _primaryColor.withOpacity(0.3),
                            _primaryColor.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                        border: Border.all(
                          color: _primaryColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getTypeIcon(_lesson!.type),
                        size: 36,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getTypeName(_lesson!.type),
                        style: TextStyle(
                          color: _primaryColor,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _surfaceColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? _primaryColor.withOpacity(0.5) : _borderColor,
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
          color: isActive ? _primaryColor : _textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return _buildSection(
      title: 'Lesson Content',
      icon: Icons.auto_stories_rounded,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildFormattedContent(_lesson!.content)],
        ),
      ),
    );
  }

  Widget _buildFormattedContent(String content) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      // Handle main headings (bold with **)
      if (line.startsWith('**') && line.endsWith('**') && line.length > 4) {
        widgets.add(const SizedBox(height: 20));
        widgets.add(
          Text(
            line.substring(2, line.length - 2),
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 16));
      }
      // Handle bullet points with emojis or markdown
      else if (line.startsWith('• ') ||
          line.startsWith('- ') ||
          line.startsWith('✅ ') ||
          line.startsWith('❌ ') ||
          line.startsWith('💡 ') ||
          line.startsWith('🎯 ') ||
          line.startsWith('📌 ') ||
          line.startsWith('📷 ') ||
          line.startsWith('📸 ') ||
          line.startsWith('🇮🇳 ') ||
          line.startsWith('👁️ ') ||
          line.startsWith('🧩 ')) {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor.withOpacity(0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (line.contains('✅') ||
                    line.contains('❌') ||
                    line.contains('💡') ||
                    line.contains('🎯') ||
                    line.contains('📌') ||
                    line.contains('📷') ||
                    line.contains('📸') ||
                    line.contains('🇮🇳') ||
                    line.contains('👁️') ||
                    line.contains('🧩')) ...[
                  Text(
                    line.substring(0, 2),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormattedText(line.substring(2).trim()),
                  ),
                ] else ...[
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
                    child: _buildFormattedText(line.substring(2).trim()),
                  ),
                ],
              ],
            ),
          ),
        );
      }
      // Handle numbered lists
      else if (RegExp(r'^\d+\.').hasMatch(line)) {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor.withOpacity(0.5)),
            ),
            child: _buildFormattedText(line),
          ),
        );
      }
      // Regular paragraphs
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildFormattedText(line),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildFormattedText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*([^*]+)\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before the match
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: TextStyle(color: _textSecondary, fontSize: 15, height: 1.6),
          ),
        );
      }

      // Add the italic text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: _primaryColor,
            fontSize: 15,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            height: 1.6,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: TextStyle(color: _textSecondary, fontSize: 15, height: 1.6),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children:
            spans.isEmpty
                ? [
                  TextSpan(
                    text: text,
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ]
                : spans,
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
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_backgroundColor, _surfaceColor]),
        ),
        child: LinearProgressIndicator(
          value: _readingProgress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
        ),
      ),
    );
  }

  Widget _buildLessonHeader() {
    final progressDay = _getProgressDay(_lesson!.day, _lesson!.difficulty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Day $progressDay • ${_getDifficultyName(_lesson!.difficulty)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_rounded, color: _textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${_lesson!.estimatedDuration} min',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 13,
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
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        if (_lesson!.subtitle.isNotEmpty) ...[
          Text(
            _lesson!.subtitle,
            style: TextStyle(
              color: _primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          _lesson!.description,
          style: TextStyle(
            color: _textSecondary,
            fontSize: 17,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final isCompleted = _lessonProgress?.status == LessonStatus.completed;
    final progressPercentage = (_readingProgress * 100).round();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up_rounded,
            label: 'Progress',
            value: '$progressPercentage%',
            color: _primaryColor,
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
            color: isCompleted ? _successColor : _secondaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.menu_book_rounded,
            label: 'Type',
            value: _getTypeName(_lesson!.type).split(' ')[0],
            color: _textSecondary,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
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
          Text(
            value,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _textTertiary,
              fontSize: 12,
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
                      color: _primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _primaryColor.withOpacity(0.1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              color: _textPrimary,
                              fontSize: 15,
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
                          _primaryColor.withOpacity(0.1),
                          _secondaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _primaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.assignment_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                exercise.title,
                                style: TextStyle(
                                  color: _textPrimary,
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
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 15,
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
                              color: _surfaceColor.withOpacity(0.5),
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
                                      colors: [_primaryColor, _secondaryColor],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: _textPrimary,
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
                )
                .toList(),
      ),
    );
  }

  Widget _buildTechnicalDetails() {
    if (_lesson!.technicalDetails.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: 'Technical Details',
      icon: Icons.settings_rounded,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
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
                              style: TextStyle(
                                color: _primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 14,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: _textPrimary,
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

  Widget _buildActionButtons() {
    final isCompleted = _lessonProgress?.status == LessonStatus.completed;
    final canMarkComplete = _readingProgress >= 0.8;
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
                    : LinearGradient(colors: [_primaryColor, _secondaryColor]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  (isCompleted || !canMarkComplete)
                      ? _borderColor
                      : Colors.transparent,
            ),
          ),
          child: ElevatedButton(
            onPressed:
                (isCompleted || !canMarkComplete) ? null : _markAsCompleted,
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
                    color: _successColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: _successColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else if (canMarkComplete) ...[
                  const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Mark as Complete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else ...[
                  Icon(Icons.menu_book_rounded, color: _textTertiary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Continue Reading (${(_readingProgress * 100).round()}%)',
                    style: TextStyle(
                      color: _textTertiary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (hasPrevious) ...[
              Expanded(
                child: _buildNavButton(
                  label: 'Previous',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () {
                    final previousLesson = LessonManager.getPreviousLesson(
                      currentProgressDay,
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
                ),
              ),
              if (hasNext) const SizedBox(width: 12),
            ],
            if (hasNext) ...[
              Expanded(
                child: _buildNavButton(
                  label: 'Next',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    final nextLesson = LessonManager.getNextLesson(
                      currentProgressDay,
                    );
                    if (nextLesson != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => LessonDetailScreen(lesson: nextLesson),
                        ),
                      );
                    }
                  },
                  isPrimary: !hasPrevious,
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
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient:
            isPrimary
                ? LinearGradient(
                  colors: [
                    _primaryColor.withOpacity(0.2),
                    _secondaryColor.withOpacity(0.1),
                  ],
                )
                : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrimary ? _primaryColor.withOpacity(0.3) : _borderColor,
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
                color: isPrimary ? _primaryColor : _textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? _primaryColor : _textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (label == 'Next') ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                color: isPrimary ? _primaryColor : _textSecondary,
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
