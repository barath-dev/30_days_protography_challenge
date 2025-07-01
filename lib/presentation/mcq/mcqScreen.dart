import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuizScreen extends StatefulWidget {
  final String quizTitle;
  final String lessonId;

  const QuizScreen({
    super.key,
    this.quizTitle = "Photography Basics Quiz",
    this.lessonId = "lesson_001",
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressAnimationController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successAnimation;

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _hasAnswered = false;
  int? _selectedAnswerIndex;
  bool _showResults = false;
  bool _showExplanation = false;
  bool _isTransitioning = false;
  List<int?> _userAnswers = [];
  List<bool> _answeredCorrectly = [];

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
  static const Color _errorColor = Color(0xFFFF453A);
  static const Color _warningColor = Color(0xFFFF9F0A);

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: "What does the word 'Photography' literally mean?",
      options: [
        "Taking pictures",
        "Drawing with light",
        "Capturing moments",
        "Making art",
      ],
      correctAnswer: 1,
      explanation:
          "Photography comes from Greek words 'Photo' (light) + 'Graphy' (drawing/writing), literally meaning 'drawing with light'.",
      difficulty: QuizDifficulty.easy,
    ),
    QuizQuestion(
      question: "Who took the world's first photograph in 1826?",
      options: [
        "Lala Deen Dayal",
        "Louis Daguerre",
        "Joseph Niépce",
        "George Eastman",
      ],
      correctAnswer: 2,
      explanation:
          "Joseph Niépce took the first permanent photograph in 1826. It required 8 hours of exposure time!",
      difficulty: QuizDifficulty.medium,
    ),
    QuizQuestion(
      question: "How many essential elements does every photograph have?",
      options: ["2", "3", "4", "5"],
      correctAnswer: 2,
      explanation:
          "Every photo has 4 essential elements: Light (most important), Subject, Framing/Composition, and Timing.",
      difficulty: QuizDifficulty.easy,
    ),
    QuizQuestion(
      question: "What was the Camera Obscura?",
      options: [
        "The first digital camera",
        "A dark box with a small hole that projected images",
        "A type of lens",
        "A photography technique",
      ],
      correctAnswer: 1,
      explanation:
          "Camera Obscura was a dark box with a tiny hole that projected images using light - the precursor to modern cameras.",
      difficulty: QuizDifficulty.medium,
    ),
    QuizQuestion(
      question: "Who was India's first renowned photographer?",
      options: [
        "Raja Ravi Varma",
        "Homai Vyarawalla",
        "Lala Deen Dayal",
        "Raghu Rai",
      ],
      correctAnswer: 2,
      explanation:
          "Lala Deen Dayal (1844–1905) was India's first great photographer, famous for documenting palaces, royals, and daily life.",
      difficulty: QuizDifficulty.medium,
    ),
    QuizQuestion(
      question: "What is the most crucial element for any photograph?",
      options: [
        "Expensive camera",
        "Light",
        "Perfect subject",
        "Professional skills",
      ],
      correctAnswer: 1,
      explanation:
          "Light is absolutely essential - without light, photography is impossible. The saying goes: 'No light, no photo!'",
      difficulty: QuizDifficulty.easy,
    ),
    QuizQuestion(
      question: "How does a camera function similarly to the human eye?",
      options: [
        "It only focuses light",
        "It just captures images",
        "Light enters through a lens and creates an image on a sensor (like our retina)",
        "It processes colors the same way",
      ],
      correctAnswer: 2,
      explanation:
          "Cameras work like eyes: light enters through the lens (pupil), gets focused, and creates an image on the sensor (retina).",
      difficulty: QuizDifficulty.medium,
    ),
    QuizQuestion(
      question: "When did photography first arrive in India?",
      options: ["1820s", "1840s", "1860s", "1880s"],
      correctAnswer: 1,
      explanation:
          "Photography reached India in the 1840s, just a few years after its invention in Europe.",
      difficulty: QuizDifficulty.hard,
    ),
    QuizQuestion(
      question:
          "Which is NOT a benefit of photography mentioned in the lesson?",
      options: [
        "Saving beautiful memories",
        "Creating virtual reality experiences",
        "Expressing thoughts without words",
        "Making people smile",
      ],
      correctAnswer: 1,
      explanation:
          "Virtual reality wasn't mentioned as a photography benefit. Photography helps with memories, expression, emotions, careers, and joy.",
      difficulty: QuizDifficulty.medium,
    ),
    QuizQuestion(
      question: "What's the most important rule when photographing people?",
      options: [
        "Use perfect lighting",
        "Always ask permission first",
        "Get the best angle",
        "Use a professional camera",
      ],
      correctAnswer: 1,
      explanation:
          "Always ask permission before photographing someone - it's respectful, ethical, and often legally required.",
      difficulty: QuizDifficulty.easy,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeQuizData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _pulseController.repeat(reverse: true);
    _animationController.forward();
  }

  void _initializeQuizData() {
    _userAnswers = List.filled(_questions.length, null);
    _answeredCorrectly = List.filled(_questions.length, false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressAnimationController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) async {
    if (_hasAnswered || _isTransitioning) return;

    HapticFeedback.selectionClick();

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
      _userAnswers[_currentQuestionIndex] = index;

      if (index == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
        _answeredCorrectly[_currentQuestionIndex] = true;
        HapticFeedback.mediumImpact();
        _successController.forward().then((_) => _successController.reset());
      } else {
        HapticFeedback.mediumImpact();
      }
    });

    // Show explanation after a brief moment
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _showExplanation = true);
    }
  }

  Future<void> _nextQuestion() async {
    if (_isTransitioning) return;

    setState(() => _isTransitioning = true);
    HapticFeedback.lightImpact();

    if (_currentQuestionIndex < _questions.length - 1) {
      // Animate out current question
      await _animationController.reverse();

      setState(() {
        _currentQuestionIndex++;
        _hasAnswered = false;
        _selectedAnswerIndex = null;
        _showExplanation = false;
        _isTransitioning = false;
      });

      // Animate in new question
      await _animationController.forward();
    } else {
      await _animationController.reverse();
      setState(() {
        _showResults = true;
        _isTransitioning = false;
      });
      await _animationController.forward();
    }
  }

  Future<void> _previousQuestion() async {
    if (_currentQuestionIndex > 0 && !_isTransitioning) {
      setState(() => _isTransitioning = true);
      HapticFeedback.lightImpact();

      await _animationController.reverse();

      setState(() {
        _currentQuestionIndex--;
        _hasAnswered = _userAnswers[_currentQuestionIndex] != null;
        _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
        _showExplanation = _hasAnswered;
        _isTransitioning = false;
      });

      await _animationController.forward();
    }
  }

  void _restartQuiz() async {
    HapticFeedback.mediumImpact();

    await _animationController.reverse();

    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _hasAnswered = false;
      _selectedAnswerIndex = null;
      _showResults = false;
      _showExplanation = false;
      _isTransitioning = false;
      _userAnswers = List.filled(_questions.length, null);
      _answeredCorrectly = List.filled(_questions.length, false);
    });

    await _animationController.forward();
  }

  void _showQuizInstructions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildInstructionsSheet(),
    );
  }

  String _getScoreMessage() {
    final percentage = (_score / _questions.length * 100).round();

    if (percentage >= 90) {
      return "Outstanding! 🏆 You're a photography expert!";
    } else if (percentage >= 80) {
      return "Excellent work! 🌟 You really understand photography!";
    } else if (percentage >= 70) {
      return "Good job! 👍 You're learning well!";
    } else if (percentage >= 60) {
      return "Keep it up! 📚 Review the lesson to improve!";
    } else {
      return "Great start! 💪 Study more and try again!";
    }
  }

  Color _getScoreColor() {
    final percentage = (_score / _questions.length * 100).round();
    if (percentage >= 80) return _successColor;
    if (percentage >= 60) return _secondaryColor;
    return _errorColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Enhanced background pattern
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              child: CustomPaint(
                painter: _QuizPatternPainter(
                  progress: 1.0,
                  primaryColor: _primaryColor,
                ),
              ),
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.4,
                  child: child,
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildEnhancedHeader(),
                _buildEnhancedProgressIndicator(),
                Expanded(
                  child:
                      _showResults
                          ? _buildEnhancedResultsScreen()
                          : _buildEnhancedQuizContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.quizTitle,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (!_showResults) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildDifficultyBadge(
                            _questions[_currentQuestionIndex].difficulty,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              _buildHeaderButton(
                icon: Icons.help_outline_rounded,
                onTap: _showQuizInstructions,
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _showResults ? 1.0 : _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showResults
                                ? Icons.emoji_events_rounded
                                : Icons.star_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_score/${_questions.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: _textPrimary, size: 20),
      ),
    );
  }

  Widget _buildDifficultyBadge(QuizDifficulty difficulty) {
    Color color;
    String text;

    switch (difficulty) {
      case QuizDifficulty.easy:
        color = _successColor;
        text = 'Easy';
        break;
      case QuizDifficulty.medium:
        color = _secondaryColor;
        text = 'Medium';
        break;
      case QuizDifficulty.hard:
        color = _errorColor;
        text = 'Hard';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEnhancedProgressIndicator() {
    final progress =
        _showResults ? 1.0 : (_currentQuestionIndex + 1) / _questions.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showResults ? 'Quiz Complete!' : 'Progress',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    progress >= 1.0
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: progress >= 1.0 ? _successColor : _textTertiary,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: _borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                height: 8,
                width: MediaQuery.of(context).size.width * progress - 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedQuizContent() {
    final question = _questions[_currentQuestionIndex];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEnhancedQuestionCard(question),
                            const SizedBox(height: 32),
                            _buildEnhancedAnswerOptions(question),
                            if (_showExplanation) ...[
                              const SizedBox(height: 24),
                              _buildEnhancedExplanation(question),
                            ],
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                    _buildEnhancedNavigationButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedQuestionCard(QuizQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor.withOpacity(0.08),
            _secondaryColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.quiz_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}',
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose the best answer',
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
          const SizedBox(height: 24),
          Text(
            question.question,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAnswerOptions(QuizQuestion question) {
    return Column(
      children: List.generate(
        question.options.length,
        (index) => _buildEnhancedAnswerOption(question, index),
      ),
    );
  }

  Widget _buildEnhancedAnswerOption(QuizQuestion question, int index) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == question.correctAnswer;
    final shouldShowResult = _hasAnswered;
    final isUserCorrect = isSelected && isCorrect;
    final isUserWrong = isSelected && !isCorrect;

    Color backgroundColor = _surfaceColor;
    Color borderColor = _borderColor;
    Color textColor = _textPrimary;
    Color? shadowColor;
    IconData? resultIcon;

    if (shouldShowResult) {
      if (isUserCorrect) {
        backgroundColor = _successColor.withOpacity(0.12);
        borderColor = _successColor;
        textColor = _successColor;
        shadowColor = _successColor.withOpacity(0.2);
        resultIcon = Icons.check_circle_rounded;
      } else if (isUserWrong) {
        backgroundColor = _errorColor.withOpacity(0.12);
        borderColor = _errorColor;
        textColor = _errorColor;
        shadowColor = _errorColor.withOpacity(0.2);
        resultIcon = Icons.cancel_rounded;
      } else if (isCorrect) {
        backgroundColor = _successColor.withOpacity(0.08);
        borderColor = _successColor.withOpacity(0.6);
        textColor = _successColor;
        resultIcon = Icons.lightbulb_rounded;
      }
    } else if (isSelected) {
      backgroundColor = _primaryColor.withOpacity(0.12);
      borderColor = _primaryColor;
      textColor = _primaryColor;
      shadowColor = _primaryColor.withOpacity(0.2);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.4, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  0.3 + (index * 0.1),
                  0.9 + (index * 0.1),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _hasAnswered ? null : () => _selectAnswer(index),
                  borderRadius: BorderRadius.circular(20),
                  splashColor: _primaryColor.withOpacity(0.1),
                  highlightColor: _primaryColor.withOpacity(0.05),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow:
                          shadowColor != null
                              ? [
                                BoxShadow(
                                  color: shadowColor,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                shouldShowResult && resultIcon != null
                                    ? Colors.transparent
                                    : isSelected && !shouldShowResult
                                    ? _primaryColor
                                    : _cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  shouldShowResult && resultIcon != null
                                      ? Colors.transparent
                                      : isSelected && !shouldShowResult
                                      ? _primaryColor
                                      : _borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child:
                                resultIcon != null
                                    ? AnimatedBuilder(
                                      animation: _successAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale:
                                              isUserCorrect
                                                  ? _successAnimation.value
                                                  : 1.0,
                                          child: Icon(
                                            resultIcon,
                                            color: textColor,
                                            size: 22,
                                          ),
                                        );
                                      },
                                    )
                                    : AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      style: TextStyle(
                                        color:
                                            isSelected && !shouldShowResult
                                                ? Colors.white
                                                : textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                            child: Text(question.options[index]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedExplanation(QuizQuestion question) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _secondaryColor.withOpacity(0.08),
            _primaryColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _secondaryColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_secondaryColor, _warningColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Explanation',
                style: TextStyle(
                  color: _secondaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.explanation,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedNavigationButtons() {
    final hasNext = _currentQuestionIndex < _questions.length - 1;
    final hasPrevious = _currentQuestionIndex > 0;
    final canAdvance = _hasAnswered && _showExplanation;

    return Row(
      children: [
        if (hasPrevious) ...[
          Expanded(
            flex: 2,
            child: _buildNavButton(
              label: 'Previous',
              icon: Icons.arrow_back_rounded,
              onPressed: _previousQuestion,
              isPrimary: false,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 3,
          child: _buildNavButton(
            label: hasNext ? 'Next Question' : 'View Results',
            icon: hasNext ? Icons.arrow_forward_rounded : Icons.flag_rounded,
            onPressed: canAdvance ? _nextQuestion : null,
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    final isEnabled = onPressed != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        gradient:
            isPrimary && isEnabled
                ? LinearGradient(colors: [_primaryColor, _secondaryColor])
                : null,
        color: isPrimary && isEnabled ? null : _surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              isEnabled
                  ? (isPrimary ? Colors.transparent : _borderColor)
                  : _borderColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow:
            isPrimary && isEnabled
                ? [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (label.startsWith('Previous')) ...[
                  Icon(
                    icon,
                    color: isEnabled ? _textPrimary : _textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isPrimary && isEnabled
                            ? Colors.white
                            : (isEnabled ? _textPrimary : _textTertiary),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!label.startsWith('Previous')) ...[
                  const SizedBox(width: 10),
                  Icon(
                    icon,
                    color:
                        isPrimary && isEnabled
                            ? Colors.white
                            : (isEnabled ? _textPrimary : _textTertiary),
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedResultsScreen() {
    final percentage = (_score / _questions.length * 100).round();
    final scoreColor = _getScoreColor();

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildResultsHeader(scoreColor),
                          const SizedBox(height: 32),
                          _buildEnhancedScoreCard(percentage, scoreColor),
                          const SizedBox(height: 32),
                          _buildQuizSummary(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  _buildEnhancedResultsActions(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsHeader(Color scoreColor) {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                scoreColor.withOpacity(0.2),
                scoreColor.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: scoreColor, width: 3),
          ),
          child: Icon(
            _score >= _questions.length * 0.8
                ? Icons.celebration_rounded
                : _score >= _questions.length * 0.6
                ? Icons.thumb_up_rounded
                : Icons.psychology_rounded,
            size: 64,
            color: scoreColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Quiz Complete!',
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getScoreMessage(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textSecondary,
            fontSize: 18,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedScoreCard(int percentage, Color scoreColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scoreColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$_score',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              Text(
                ' / ${_questions.length}',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scoreColor, scoreColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: scoreColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '$percentage% Accuracy',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSummary() {
    final correctAnswers =
        _answeredCorrectly.where((correct) => correct).length;
    final wrongAnswers = _questions.length - correctAnswers;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Summary',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Correct',
                  value: '$correctAnswers',
                  color: _successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.cancel_rounded,
                  label: 'Wrong',
                  value: '$wrongAnswers',
                  color: _errorColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.quiz_rounded,
                  label: 'Total',
                  value: '${_questions.length}',
                  color: _primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedResultsActions() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_primaryColor, _secondaryColor]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _restartQuiz,
              borderRadius: BorderRadius.circular(20),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Take Quiz Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderColor, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      color: _textPrimary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Back to Lesson',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsSheet() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor.withOpacity(0.1), Colors.transparent],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.help_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Quiz Instructions',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInstructionItem(
                  icon: Icons.quiz_rounded,
                  title: 'Answer Questions',
                  description:
                      'Read each question carefully and select the best answer.',
                ),
                _buildInstructionItem(
                  icon: Icons.lightbulb_rounded,
                  title: 'Learn from Explanations',
                  description:
                      'After answering, read the explanation to understand better.',
                ),
                _buildInstructionItem(
                  icon: Icons.navigation_rounded,
                  title: 'Navigate Freely',
                  description:
                      'Use Previous/Next buttons to review your answers.',
                ),
                _buildInstructionItem(
                  icon: Icons.emoji_events_rounded,
                  title: 'View Results',
                  description:
                      'Complete all questions to see your final score and summary.',
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_rounded,
                        color: _primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Take your time and think carefully about each answer!',
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(16),
                      child: const Center(
                        child: Text(
                          'Got it!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum QuizDifficulty { easy, medium, hard }

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final QuizDifficulty difficulty;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
  });
}

class _QuizPatternPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  _QuizPatternPainter({required this.progress, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = primaryColor.withOpacity(0.02)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Draw quiz-themed patterns
    final spacing = 100.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final center = Offset(x, y);

        // Draw concentric circles
        for (int i = 1; i <= 3; i++) {
          canvas.drawCircle(center, i * 15.0 * progress, paint);
        }

        // Draw question mark symbols occasionally
        if ((x / spacing + y / spacing) % 4 == 0) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: '?',
              style: TextStyle(
                color: primaryColor.withOpacity(0.03 * progress),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(x - textPainter.width / 2, y - textPainter.height / 2),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
