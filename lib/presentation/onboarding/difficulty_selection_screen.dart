import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photography_guide/models/lesson.dart';
import 'package:photography_guide/models/user_progress.dart';
import '../../services/user_preferences.dart';
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

  // Design constants
  static const Color _primary = Color(0xFFFF6B35);
  static const Color _background = Color(0xFF0D0D0D);
  static const Color _card = Color(0xFF1A1A1A);
  static const Color _text = Color(0xFF888888);
  static const Color _border = Color(0xFF333333);
  static const Color _success = Color(0xFF4CAF50);

  final List<DifficultyInfo> difficulties = [
    DifficultyInfo(
      level: DifficultyLevel.beginner,
      title: 'Beginner',
      subtitle: 'New to Photography',
      description:
          'Perfect for those just starting their photography journey. Learn camera basics, composition, and fundamental techniques.',
      icon: Icons.camera_alt,
      color: Color(0xFF4CAF50),
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
      color: Color(0xFFFF6B35),
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
      color: Color(0xFF9C27B0),
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
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
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
    );
  }

  Widget _buildHeader() {
    final isEditing = UserPreferences.activeDifficulty != null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              if (isEditing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primary, width: 1),
                  ),
                  child: Text(
                    'Switch Track',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.help_outline, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 30),
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
                const SizedBox(height: 12),
                Text(
                  isEditing
                      ? 'Switch between different learning tracks. Your progress is saved for each difficulty level.'
                      : 'Select the level that best matches your current photography experience. You can always switch between tracks later.',
                  style: TextStyle(color: _text, fontSize: 16, height: 1.5),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? difficulty.color : _border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: difficulty.color.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(difficulty, isSelected, hasProgress),
            const SizedBox(height: 16),
            Text(
              difficulty.description,
              style: TextStyle(color: _text, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            _buildFeaturesList(difficulty),
            const SizedBox(height: 16),
            _buildCardFooter(difficulty),
            if (hasProgress) ...[
              const SizedBox(height: 16),
              _buildProgressIndicator(difficulty),
            ],
            if (isSelected) ...[
              const SizedBox(height: 16),
              _buildSelectedIndicator(),
            ],
          ],
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
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: difficulty.color.withOpacity(isSelected ? 1.0 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            difficulty.icon,
            color: isSelected ? Colors.white : difficulty.color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    difficulty.title,
                    style: TextStyle(
                      color: isSelected ? difficulty.color : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasProgress) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _success.withOpacity(0.3)),
                      ),
                      child: Text(
                        'In Progress',
                        style: TextStyle(
                          color: _success,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                difficulty.subtitle,
                style: TextStyle(color: _text, fontSize: 14),
              ),
            ],
          ),
        ),
        if (isSelected)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: difficulty.color,
              shape: BoxShape.circle,
            ),
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
        color: _background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border.withOpacity(0.5)),
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
                  color: Colors.white,
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
            backgroundColor: _border.withOpacity(0.3),
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
                style: TextStyle(color: _text, fontSize: 11),
              ),
              Text(
                '${progress.dailyStreak} day streak',
                style: TextStyle(color: _text, fontSize: 11),
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
            color: Colors.white,
            fontSize: 14,
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
                    style: TextStyle(color: _text, fontSize: 13, height: 1.4),
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
    return Row(
      children: [
        _buildInfoChip(Icons.schedule, difficulty.duration),
        const SizedBox(width: 12),
        _buildInfoChip(Icons.assignment, '${difficulty.totalLessons} lessons'),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _border.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _text, size: 12),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: _text, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSelectedIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: _primary, size: 16),
          const SizedBox(width: 8),
          Text(
            'Selected',
            style: TextStyle(
              color: _primary,
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
      padding: const EdgeInsets.all(20),
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
              style: TextStyle(color: _text, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  selectedDifficulty != null && !_isLoading
                      ? () {
                        HapticFeedback.mediumImpact();
                        _handleContinue();
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _border,
                disabledForegroundColor: _text,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: selectedDifficulty != null ? 4 : 0,
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
        ],
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (selectedDifficulty == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final currentDifficulty = UserPreferences.activeDifficulty;
      final isDifferentDifficulty = currentDifficulty != selectedDifficulty;
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
            backgroundColor: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(difficulty.icon, color: difficulty.color, size: 28),
                const SizedBox(width: 12),
                Text('Great Choice!', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              'You\'ve selected ${difficulty.title} level. Your 30-day photography journey will be customized for your skill level.',
              style: TextStyle(color: _text),
            ),
            actions: [
              ElevatedButton(
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
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Let\'s Go!'),
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
            backgroundColor: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Track Switched!',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'You\'ve switched to the ${difficulty.title} track. Your progress has been preserved and you can continue where you left off.',
              style: TextStyle(color: _text),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(
                    context,
                    true,
                  ); // Return to home with refresh flag
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue'),
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
            backgroundColor: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Error', style: TextStyle(color: Colors.white)),
            content: Text(
              'Something went wrong. Please try again.',
              style: TextStyle(color: _text),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: _primary)),
              ),
            ],
          ),
    );
  }
}

// Data model for difficulty information (unchanged)
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
