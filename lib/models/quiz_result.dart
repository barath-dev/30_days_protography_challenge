import 'package:photography_guide/models/lesson.dart';

class QuizResult {
  final DifficultyLevel quizLevel;
  final int score;
  final int totalQuestions;
  final double percentage;
  final bool passed;
  final DateTime completedAt;
  final List<QuizQuestionResult> questionResults;
  final Duration timeTaken;
  final bool isUnlockQuiz;
  final Map<String, dynamic>? additionalData;

  QuizResult({
    required this.quizLevel,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.passed,
    required this.completedAt,
    required this.questionResults,
    required this.timeTaken,
    this.isUnlockQuiz = false,
    this.additionalData,
  });

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      quizLevel: DifficultyLevel.values.firstWhere(
        (e) => e.name == map['quizLevel'],
        orElse: () => DifficultyLevel.beginner,
      ),
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      percentage: (map['percentage'] ?? 0.0).toDouble(),
      passed: map['passed'] ?? false,
      completedAt: DateTime.parse(
        map['completedAt'] ?? DateTime.now().toIso8601String(),
      ),
      questionResults:
          (map['questionResults'] as List?)
              ?.map(
                (q) => QuizQuestionResult.fromMap(q as Map<String, dynamic>),
              )
              .toList() ??
          [],
      timeTaken: Duration(milliseconds: map['timeTakenMs'] ?? 0),
      isUnlockQuiz: map['isUnlockQuiz'] ?? false,
      additionalData: map['additionalData'] as Map<String, dynamic>?,
    );
  }

  // Legacy support for old fromJson method
  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult.fromMap(json);
  }

  Map<String, dynamic> toMap() {
    return {
      'quizLevel': quizLevel.name,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'passed': passed,
      'completedAt': completedAt.toIso8601String(),
      'questionResults': questionResults.map((q) => q.toMap()).toList(),
      'timeTakenMs': timeTaken.inMilliseconds,
      'isUnlockQuiz': isUnlockQuiz,
      'additionalData': additionalData,
    };
  }

  // Legacy support for old toJson method
  Map<String, dynamic> toJson() => toMap();

  // Convenience getters
  String get scoreText => '$score/$totalQuestions';
  String get percentageText => '${percentage.round()}%';
  String get formattedTime =>
      '${timeTaken.inMinutes}:${(timeTaken.inSeconds % 60).toString().padLeft(2, '0')}';

  bool get isPerfectScore => score == totalQuestions;
  bool get isGoodScore => percentage >= 80;
  bool get isPassingScore => percentage >= 70;

  String get gradeText {
    if (percentage >= 90) return 'Excellent!';
    if (percentage >= 80) return 'Great!';
    if (percentage >= 70) return 'Good!';
    if (percentage >= 60) return 'Fair';
    return 'Needs Improvement';
  }
}

class QuizQuestionResult {
  final int questionIndex;
  final int selectedAnswer;
  final int correctAnswer;
  final bool isCorrect;
  final String question;

  QuizQuestionResult({
    required this.questionIndex,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.question,
  });

  factory QuizQuestionResult.fromMap(Map<String, dynamic> map) {
    return QuizQuestionResult(
      questionIndex: map['questionIndex'] ?? 0,
      selectedAnswer: map['selectedAnswer'] ?? 0,
      correctAnswer: map['correctAnswer'] ?? 0,
      isCorrect: map['isCorrect'] ?? false,
      question: map['question'] ?? '',
    );
  }

  // Legacy support for old fromJson method
  factory QuizQuestionResult.fromJson(Map<String, dynamic> json) {
    return QuizQuestionResult.fromMap(json);
  }

  Map<String, dynamic> toMap() {
    return {
      'questionIndex': questionIndex,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'question': question,
    };
  }

  // Legacy support for old toJson method
  Map<String, dynamic> toJson() => toMap();
}
