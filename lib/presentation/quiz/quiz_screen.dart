import 'package:flutter/material.dart';
import '../../models/quiz_result.dart';
import '../../models/lesson.dart';

class QuizScreen extends StatefulWidget {
  final String quizTitle;
  final String lessonId;
  final DifficultyLevel quizLevel;
  final bool isUnlockQuiz;

  const QuizScreen({
    super.key,
    required this.quizTitle,
    required this.lessonId,
    required this.quizLevel,
    this.isUnlockQuiz = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.quizTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Quiz Coming Soon',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Level: ${widget.quizLevel.name.toUpperCase()}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Simulate passing the quiz for now
                Navigator.pop(
                  context,
                  QuizResult(
                    quizLevel: widget.quizLevel,
                    score: 10,
                    totalQuestions: 10,
                    percentage: 100.0,
                    passed: true,
                    completedAt: DateTime.now(),
                    questionResults: [],
                    timeTaken: const Duration(minutes: 2),
                    isUnlockQuiz: widget.isUnlockQuiz,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Complete Quiz (Simulated)'),
            ),
          ],
        ),
      ),
    );
  }
}
