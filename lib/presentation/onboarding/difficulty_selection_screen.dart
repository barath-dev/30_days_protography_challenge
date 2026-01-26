import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:photography_guide/models/lesson.dart';
import 'package:photography_guide/models/user_progress.dart';
import '../../services/user_preferences.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';

class DifficultySelectionScreen extends StatefulWidget {
  const DifficultySelectionScreen({super.key});

  @override
  State<DifficultySelectionScreen> createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DifficultyLevel? selectedDifficulty;
  bool _isLoading = false;
  Map<DifficultyLevel, bool> _hasProgress = {};

  final List<DifficultyInfo> difficulties = [
    DifficultyInfo(
      level: DifficultyLevel.beginner,
      title: 'Beginner',
      subtitle: 'New to Photography',
      description:
          'Perfect for those just starting their photography journey. Learn camera basics, composition, and fundamental techniques.',
      icon: Icons.camera_alt,
      color: AppConstants.beginnerColor,
      features: [
        'Camera basics and controls',
        'Simple composition rules',
        'Basic lighting techniques',
        'Auto mode to manual transition',
        'Essential photo editing',
      ],
      duration: '15-20 min per lesson',
      totalLessons: 30,
    ),
    DifficultyInfo(
      level: DifficultyLevel.intermediate,
      title: 'Intermediate',
      subtitle: 'Some Experience',
      description:
          'For photographers who know the basics and want to improve their skills with advanced techniques and creative approaches.',
      icon: Icons.tune,
      color: AppConstants.intermediateColor,
      features: [
        'Advanced composition techniques',
        'Manual camera controls',
        'Creative lighting setups',
        'Genre-specific photography',
        'Advanced editing workflows',
      ],
      duration: '20-30 min per lesson',
      totalLessons: 30,
    ),
    DifficultyInfo(
      level: DifficultyLevel.advanced,
      title: 'Advanced',
      subtitle: 'Professional Level',
      description:
          'Master professional techniques, develop your unique style, and learn business aspects of photography.',
      icon: Icons.auto_awesome,
      color: AppConstants.advancedColor,
      features: [
        'Professional shooting techniques',
        'Advanced post-processing',
        'Portfolio development',
        'Business and marketing',
        'Style development',
      ],
      duration: '30-45 min per lesson',
      totalLessons: 30,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadCurrentDifficulty();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
  }

  Future<void> _loadCurrentDifficulty() async {
    selectedDifficulty = UserPreferences.activeDifficulty;

    // Check which difficulties have existing progress
    for (final difficulty in DifficultyLevel.values) {
      _hasProgress[difficulty] = UserPreferences.hasProgressForDifficulty(
        difficulty,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dark Prism Theme: Dark gradient background
    return Scaffold(
      backgroundColor:
          Colors
              .transparent, // Allow gradient from container to show if we wrapped it, but here we can just set body decoration
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildContent(),
                  ),
                ),
              ),
              _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isEditing = UserPreferences.activeDifficulty != null;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.contentPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              if (isEditing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.contentPadding,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                    border: Border.all(
                      color: AppConstants.primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Switch Track',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(AppConstants.contentPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Icon(Icons.help_outline, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.largePadding),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? 'Switch Learning\nTrack'
                      : 'Choose Your\nSkill Level',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppConstants.contentPadding),
                Text(
                  isEditing
                      ? 'Switch between different learning tracks. Your progress is saved for each difficulty level.'
                      : 'Select the level that best matches your current photography experience. You can always switch between tracks later.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      itemCount: difficulties.length,
      itemBuilder: (context, index) {
        final difficulty = difficulties[index];
        final isSelected = selectedDifficulty == difficulty.level;
        final hasProgress = _hasProgress[difficulty.level] ?? false;
        final delay = index * 0.2;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final animation = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(delay, (delay + 0.4).clamp(0, 1)),
              ),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: _buildDifficultyCard(
                  difficulty,
                  isSelected,
                  hasProgress,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDifficultyCard(
    DifficultyInfo difficulty,
    bool isSelected,
    bool hasProgress,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDifficulty = difficulty.level;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? difficulty.color.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(
            AppConstants.extraLargeBorderRadius,
          ),
          border: Border.all(
            color:
                isSelected ? difficulty.color : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: difficulty.color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AppConstants.extraLargeBorderRadius,
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardHeader(difficulty, isSelected, hasProgress),
                  const SizedBox(height: AppConstants.mediumPadding),
                  Text(
                    difficulty.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  _buildFeaturesList(difficulty),
                  const SizedBox(height: AppConstants.mediumPadding),
                  _buildCardFooter(difficulty),
                  if (hasProgress) ...[
                    const SizedBox(height: AppConstants.mediumPadding),
                    _buildProgressIndicator(difficulty),
                  ],
                  if (isSelected) ...[
                    const SizedBox(height: AppConstants.mediumPadding),
                    _buildSelectedIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(
    DifficultyInfo difficulty,
    bool isSelected,
    bool hasProgress,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.contentPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                difficulty.color.withOpacity(0.2),
                difficulty.color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
            border: Border.all(color: difficulty.color.withOpacity(0.3)),
          ),
          child: Icon(
            difficulty.icon,
            color: difficulty.color,
            size: AppConstants.iconSizeDefault,
          ),
        ),
        const SizedBox(width: AppConstants.mediumPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    difficulty.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (hasProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.successColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppConstants.successColor.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        'In Progress',
                        style: TextStyle(
                          color: AppConstants.successColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                difficulty.subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: difficulty.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: difficulty.color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator(DifficultyInfo difficulty) {
    final progress = UserPreferences.getProgressForDifficulty(difficulty.level);
    if (progress == null) return const SizedBox.shrink();

    final completedLessons =
        progress.lessonProgress.values
            .where((p) => p.status == LessonStatus.completed)
            .length;
    final progressPercentage = completedLessons / 30.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completedLessons/30 lessons',
                style: TextStyle(
                  color: difficulty.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(difficulty.color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day ${progress.currentDay}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
              Text(
                '${progress.dailyStreak} day streak',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(DifficultyInfo difficulty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you\'ll learn:',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...difficulty.features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  decoration: BoxDecoration(
                    color: difficulty.color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.4,
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

  Widget _buildCardFooter(DifficultyInfo difficulty) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildInfoChip(Icons.schedule, difficulty.duration),
          const SizedBox(width: 12),
          _buildInfoChip(
            Icons.assignment,
            '${difficulty.totalLessons} lessons',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: AppConstants.primaryColor,
            size: AppConstants.iconSizeSmall,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            'Selected',
            style: TextStyle(
              color: AppConstants.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final isEditing = UserPreferences.activeDifficulty != null;
    final currentDifficulty = UserPreferences.activeDifficulty;
    final isDifferentDifficulty =
        isEditing && currentDifficulty != selectedDifficulty;
    final hasProgress =
        selectedDifficulty != null
            ? (_hasProgress[selectedDifficulty!] ?? false)
            : false;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          if (selectedDifficulty != null) ...[
            Text(
              isEditing
                  ? isDifferentDifficulty
                      ? hasProgress
                          ? 'Continue your progress in ${difficulties.firstWhere((d) => d.level == selectedDifficulty).title} track'
                          : 'Start fresh with ${difficulties.firstWhere((d) => d.level == selectedDifficulty).title} track'
                      : 'Continue with your current learning track'
                  : hasProgress
                  ? 'Continue your existing progress'
                  : 'Ready to start your photography journey?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: selectedDifficulty != null && !_isLoading
                    ? AppConstants.primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow:
                    selectedDifficulty != null && !_isLoading
                        ? [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: ElevatedButton(
                onPressed:
                    selectedDifficulty != null && !_isLoading
                        ? () {
                          HapticFeedback.mediumImpact();
                          _handleContinue();
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedDifficulty != null && !_isLoading
                      ? AppConstants.primaryColor
                      : Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.white.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                        : Text(
                          selectedDifficulty != null
                              ? isEditing
                                  ? isDifferentDifficulty
                                      ? hasProgress
                                          ? 'Switch to ${difficulties.firstWhere((d) => d.level == selectedDifficulty).title}'
                                          : 'Start ${difficulties.firstWhere((d) => d.level == selectedDifficulty).title} Track'
                                      : 'Continue Current Track'
                                  : hasProgress
                                  ? 'Continue Learning'
                                  : 'Start Learning'
                              : 'Select a Difficulty Level',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (selectedDifficulty == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final hasProgress = _hasProgress[selectedDifficulty!] ?? false;

      if (hasProgress) {
        // Switch to existing progress
        await UserPreferences.setActiveDifficulty(selectedDifficulty!);
        if (mounted) {
          await _showSwitchConfirmation();
        }
      } else {
        // Initialize new progress for this difficulty
        await UserPreferences.initializeProgressForDifficulty(
          selectedDifficulty!,
        );
        if (mounted) {
          await _showStartConfirmation();
        }
      }
    } catch (e) {
      print('Error handling difficulty selection: $e');
      if (mounted) {
        _showErrorDialog();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showStartConfirmation() async {
    final difficulty = difficulties.firstWhere(
      (d) => d.level == selectedDifficulty!,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: Row(
              children: [
                Icon(difficulty.icon, color: difficulty.color, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Great Choice!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'You\'ve selected ${difficulty.title} level. Your 30-day photography journey will be customized for your skill level.',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            actions: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppConstants.primaryColor, Color(0xFF6C63FF)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Navigate to HomeScreen and replace the entire stack
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Let\'s Go!'),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _showSwitchConfirmation() async {
    final difficulty = difficulties.firstWhere(
      (d) => d.level == selectedDifficulty!,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: Text(
              'Track Switched!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'You\'ve switched to the ${difficulty.title} track. Your progress has been preserved and you can continue where you left off.',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            actions: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppConstants.primaryColor, Color(0xFF6C63FF)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(
                      context,
                      true,
                    ); // Return to home with refresh flag
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: Text(
              'Error',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Something went wrong. Please try again.',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(color: AppConstants.primaryColor),
                ),
              ),
            ],
          ),
    );
  }
}

class DifficultyInfo {
  final DifficultyLevel level;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;
  final String duration;
  final int totalLessons;

  const DifficultyInfo({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
    required this.duration,
    required this.totalLessons,
  });
}
