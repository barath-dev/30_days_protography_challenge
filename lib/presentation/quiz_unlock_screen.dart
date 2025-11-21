import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/lesson.dart';
import '../models/quiz_result.dart';
import '../services/user_preferences.dart';
import '../services/navigation_service.dart';

class QuizUnlockScreen extends StatefulWidget {
  final DifficultyLevel targetLevel;
  final DifficultyLevel? currentLevel;

  const QuizUnlockScreen({
    super.key,
    required this.targetLevel,
    this.currentLevel,
  });

  @override
  State<QuizUnlockScreen> createState() => _QuizUnlockScreenState();
}

class _QuizUnlockScreenState extends State<QuizUnlockScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  bool _hasAttemptedQuiz = false;

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
    _checkQuizStatus();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkQuizStatus() {
    // FIXED: Check quiz status for the prerequisite level, not target level
    final prerequisiteLevel = _getPrerequisiteLevel(widget.targetLevel);
    if (prerequisiteLevel != null) {
      _hasAttemptedQuiz = UserPreferences.hasAttemptedQuiz(prerequisiteLevel);
    }
  }

  // FIXED: Get the prerequisite level for unlocking
  DifficultyLevel? _getPrerequisiteLevel(DifficultyLevel targetLevel) {
    switch (targetLevel) {
      case DifficultyLevel.intermediate:
        return DifficultyLevel.beginner;
      case DifficultyLevel.advanced:
        return DifficultyLevel.intermediate;
      case DifficultyLevel.beginner:
        return null; // Beginner has no prerequisite
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * _slideAnimation.value),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildLevelPreview(),
          const SizedBox(height: 32),
          _buildQuizRequirement(),
          const SizedBox(height: 40),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
            const Spacer(),
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
                  Icon(Icons.quiz, color: _primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Level Quiz',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Unlock ${_getDifficultyDisplayName(widget.targetLevel)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Complete the quiz to access advanced photography techniques and unlock your next learning journey.',
          style: TextStyle(color: _text, fontSize: 18, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildLevelPreview() {
    final targetColor = _getDifficultyColor(widget.targetLevel);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [targetColor.withOpacity(0.1), targetColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: targetColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: targetColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: targetColor.withOpacity(0.3), width: 2),
            ),
            child: Icon(
              _getDifficultyIcon(widget.targetLevel),
              color: targetColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${_getDifficultyDisplayName(widget.targetLevel)} Level',
            style: TextStyle(
              color: targetColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getLevelDescription(widget.targetLevel),
            style: TextStyle(color: _text, fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizRequirement() {
    final prerequisiteLevel = _getPrerequisiteLevel(widget.targetLevel);
    final prerequisiteName =
        prerequisiteLevel != null
            ? _getDifficultyDisplayName(prerequisiteLevel)
            : '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.quiz, color: _primary, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Quiz Requirements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRequirementItem(
            Icons.help_outline,
            'Answer 10 Questions',
            'Test your $prerequisiteName level photography knowledge',
          ),
          _buildRequirementItem(
            Icons.timer,
            'No Time Limit',
            'Take your time to think through each answer',
          ),
          _buildRequirementItem(
            Icons.check_circle_outline,
            '70% Pass Rate',
            'Get 7 out of 10 questions correct to pass',
          ),
          if (_hasAttemptedQuiz)
            _buildRequirementItem(
              Icons.refresh,
              'Retake Available',
              'You can retake the quiz if needed',
              isHighlighted: true,
            ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(
    IconData icon,
    String title,
    String description, {
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isHighlighted
                ? _primary.withOpacity(0.1)
                : _background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isHighlighted
                  ? _primary.withOpacity(0.3)
                  : _border.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isHighlighted ? _primary : _text, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isHighlighted ? _primary : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: _text, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _startQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _border,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _isLoading ? 0 : 8,
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
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.quiz, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _hasAttemptedQuiz ? 'Retake Quiz' : 'Start Quiz',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Maybe Later',
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // FIXED: Quiz start method with correct level logic
  Future<void> _startQuiz() async {
    setState(() => _isLoading = true);

    try {
      HapticFeedback.mediumImpact();

      // FIXED: Use prerequisite level for the quiz, not target level
      final prerequisiteLevel = _getPrerequisiteLevel(widget.targetLevel);
      if (prerequisiteLevel == null) {
        print('❌ No prerequisite level for ${widget.targetLevel.name}');
        return;
      }

      print('🎯 Starting unlock quiz for ${widget.targetLevel.name}');
      print('📚 Quiz will test ${prerequisiteLevel.name} knowledge');

      // Navigate to quiz with CORRECT parameters
      final result = await NavigationService.toQuiz(
        quizTitle:
            'Unlock ${_getDifficultyDisplayName(widget.targetLevel)} Level',
        lessonId: 'unlock_${widget.targetLevel.name}',
        quizLevel: prerequisiteLevel, // FIXED: Use prerequisite level
        isUnlockQuiz: true,
      );

      if (mounted) {
        if (result != null) {
          print(
            '🎯 Quiz completed: ${result.scoreText}, passed: ${result.passed}',
          );
          print('🔍 Quiz level was: ${result.quizLevel.name}');
          print('🎯 Target level to unlock: ${widget.targetLevel.name}');

          // Save quiz result (this will unlock the target level if passed)
          await UserPreferences.saveQuizResult(result);

          if (result.passed) {
            // FIXED: Don't auto-navigate, let user choose
            _showSuccessDialog(result);
          } else {
            // Quiz failed - update state but stay on screen
            setState(() => _hasAttemptedQuiz = true);
            _showFailureDialog(result);
          }
        } else {
          // Quiz was cancelled
          print('🎯 Quiz was cancelled');
        }
      }
    } catch (e) {
      debugPrint('Error starting quiz: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error starting quiz. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // FIXED: Success dialog with proper navigation
  void _showSuccessDialog(QuizResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, color: _success, size: 48),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You scored ${result.scoreText} (${result.percentageText})!\n\nYou\'ve unlocked ${_getDifficultyDisplayName(widget.targetLevel)} level. Ready to take your photography to the next level?',
                  style: TextStyle(color: _text, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog only
                  // Don't auto-navigate, let the user return naturally
                  Navigator.pop(context, true); // Return success to parent
                },
                child: Text('Continue', style: TextStyle(color: _primary)),
              ),
            ],
          ),
    );
  }

  void _showFailureDialog(QuizResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Keep Trying!',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You scored ${result.scoreText} (${result.percentageText}). You need at least 7/10 to unlock the next level.',
                  style: TextStyle(color: _text, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: _primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Review the lessons and try again when you\'re ready!',
                          style: TextStyle(
                            color: _primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Try Again', style: TextStyle(color: _primary)),
              ),
            ],
          ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
    }
  }

  IconData _getDifficultyIcon(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Icons.school;
      case DifficultyLevel.intermediate:
        return Icons.trending_up;
      case DifficultyLevel.advanced:
        return Icons.workspace_premium;
    }
  }

  String _getLevelDescription(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Learn the fundamentals of photography with easy-to-follow lessons covering camera basics, composition, and essential techniques.';
      case DifficultyLevel.intermediate:
        return 'Advance your skills with more complex techniques, creative compositions, and professional photography methods.';
      case DifficultyLevel.advanced:
        return 'Master professional photography with advanced lighting, post-processing, and commercial photography techniques.';
    }
  }
}
