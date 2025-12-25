import 'package:photography_guide/data/beginnerlessons.dart';
import 'package:photography_guide/data/intermediateLessons.dart';
import 'package:photography_guide/data/advancedLessons.dart';

import '../models/lesson.dart';
import '../models/user_progress.dart';
import '../models/saved_item.dart';
import '../utils/constants.dart';
import 'user_preferences.dart';

class LessonManager {
  static List<Lesson> _beginnerLessons = [];
  static List<Lesson> _intermediateLessons = [];
  static List<Lesson> _advancedLessons = [];
  static List<SavedItem> _tips = [];
  static List<SavedItem> _articles = [];
  static List<SavedItem> _references = [];

  // Day offset mapping for different difficulties
  static const Map<DifficultyLevel, int> _dayOffsets = {
    DifficultyLevel.beginner: 0, // Days 1-30
    DifficultyLevel.intermediate: 30, // Days 31-60
    DifficultyLevel.advanced: 60, // Days 61-90
  };

  static Future<void> init() async {
    await _loadLessons();
    await _loadSupplementaryContent();
  }

  // Helper method to convert user progress day to actual lesson day
  static int _getActualLessonDay(int progressDay, DifficultyLevel difficulty) {
    final offset = _dayOffsets[difficulty] ?? 0;
    return progressDay + offset;
  }

  // Helper method to convert actual lesson day to progress day
  static int _getProgressDay(int actualDay, DifficultyLevel difficulty) {
    final offset = _dayOffsets[difficulty] ?? 0;
    return actualDay - offset;
  }

  // Get all lessons across all difficulty levels
  static List<Lesson> get allLessons => [
    ..._beginnerLessons,
    ..._intermediateLessons,
    ..._advancedLessons,
  ];

  // Get lessons by difficulty
  static List<Lesson> getLessonsByDifficulty(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return List.unmodifiable(_beginnerLessons);
      case DifficultyLevel.intermediate:
        return List.unmodifiable(_intermediateLessons);
      case DifficultyLevel.advanced:
        return List.unmodifiable(_advancedLessons);
    }
  }

  // Get beginner lessons specifically
  static List<Lesson> get beginnerLessons =>
      List.unmodifiable(_beginnerLessons);
  static List<Lesson> get intermediateLessons =>
      List.unmodifiable(_intermediateLessons);
  static List<Lesson> get advancedLessons =>
      List.unmodifiable(_advancedLessons);

  // Get lesson by ID
  static Lesson? getLessonById(String id) {
    try {
      return allLessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get lesson by actual day number and difficulty
  static Lesson? getLessonByActualDay(
    int actualDay,
    DifficultyLevel difficulty,
  ) {
    try {
      final lessons = getLessonsByDifficulty(difficulty);
      return lessons.firstWhere((lesson) => lesson.day == actualDay);
    } catch (e) {
      return null;
    }
  }

  // Get lesson by progress day (1-30) and difficulty
  static Lesson? getLessonByProgressDay(
    int progressDay,
    DifficultyLevel difficulty,
  ) {
    final actualDay = _getActualLessonDay(progressDay, difficulty);
    return getLessonByActualDay(actualDay, difficulty);
  }

  // Get lesson by day (uses current user's active difficulty and maps to actual day)
  static Lesson? getLessonByDay(int progressDay) {
    final currentDifficulty = UserPreferences.activeDifficulty;
    if (currentDifficulty == null) return null;

    return getLessonByProgressDay(progressDay, currentDifficulty);
  }

  // Updated getCurrentLesson method to use active difficulty
  static Lesson? getCurrentLesson([DifficultyLevel? difficulty]) {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return null;

    final progress = UserPreferences.getProgressForDifficulty(targetDifficulty);
    if (progress != null) {
      final maxAvailableProgressDay = progress.getMaxAvailableDay();
      return getLessonByProgressDay(maxAvailableProgressDay, targetDifficulty);
    }
    return null;
  }

  // Check if a lesson can be accessed today (using progress day)
  static bool canAccessLesson(int progressDay, [DifficultyLevel? difficulty]) {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return false;

    if (AppConstants.isUnrestrictedMode) return true;

    final progress = UserPreferences.getProgressForDifficulty(targetDifficulty);
    if (progress == null) return false;

    return progress.isDayUnlocked(progressDay);
  }

  // Check if user has already accessed today's lesson for active difficulty
  static bool hasAccessedTodaysLesson([DifficultyLevel? difficulty]) {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return false;

    final progress = UserPreferences.getProgressForDifficulty(targetDifficulty);
    if (progress == null) return false;

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final lastActivity = DateTime(
      progress.lastActivityDate.year,
      progress.lastActivityDate.month,
      progress.lastActivityDate.day,
    );

    return startOfToday.isAtSameMomentAs(lastActivity);
  }

  // Get the next available lesson (respecting daily restrictions)
  static Lesson? getNextAvailableLesson([DifficultyLevel? difficulty]) {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return null;

    final progress = UserPreferences.getProgressForDifficulty(targetDifficulty);
    if (progress == null) return null;

    final maxAvailableProgressDay = progress.getMaxAvailableDay();

    // Check if today's lesson is completed
    final todaysLesson = getLessonByProgressDay(
      maxAvailableProgressDay,
      targetDifficulty,
    );
    if (todaysLesson != null && !progress.isLessonCompleted(todaysLesson.id)) {
      return todaysLesson;
    }

    // If today's lesson is completed, return tomorrow's lesson (if available)
    final nextProgressDay = maxAvailableProgressDay + 1;
    if (nextProgressDay <= AppConstants.totalCourseDays &&
        progress.isDayUnlocked(nextProgressDay)) {
      return getLessonByProgressDay(nextProgressDay, targetDifficulty);
    }

    return null;
  }

  // Get time until next lesson unlocks
  static String getTimeUntilNextLesson([DifficultyLevel? difficulty]) {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return 'Unknown';

    final progress = UserPreferences.getProgressForDifficulty(targetDifficulty);
    if (progress == null) return 'Unknown';

    final maxAvailableProgressDay = progress.getMaxAvailableDay();
    final nextProgressDay = maxAvailableProgressDay + 1;

    if (nextProgressDay > AppConstants.totalCourseDays) {
      return 'Course completed';
    }

    return progress.getTimeUntilUnlock(nextProgressDay);
  }

  // Get next lesson for specific difficulty
  static Lesson? getNextLesson(
    int currentProgressDay, [
    DifficultyLevel? difficulty,
  ]) {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return null;

    return getLessonByProgressDay(currentProgressDay + 1, targetDifficulty);
  }

  // Get previous lesson for specific difficulty
  static Lesson? getPreviousLesson(
    int currentProgressDay, [
    DifficultyLevel? difficulty,
  ]) {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return null;

    if (currentProgressDay > 1) {
      return getLessonByProgressDay(currentProgressDay - 1, targetDifficulty);
    }
    return null;
  }

  // Get lessons by type (filtered by specified or active difficulty)
  static List<Lesson> getLessonsByType(
    LessonType type, [
    DifficultyLevel? difficulty,
  ]) {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return [];

    final lessons = getLessonsByDifficulty(targetDifficulty);
    return lessons.where((lesson) => lesson.type == type).toList();
  }

  // Get lessons by category (filtered by specified or active difficulty)
  static List<Lesson> getLessonsByCategory(
    String category, [
    DifficultyLevel? difficulty,
  ]) {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return [];

    final lessons = getLessonsByDifficulty(targetDifficulty);
    return lessons
        .where((lesson) => lesson.categories.contains(category))
        .toList();
  }

  // Get lessons for current user's active difficulty
  static List<Lesson> getCurrentUserLessons() {
    final difficulty = UserPreferences.activeDifficulty;
    if (difficulty == null) return [];

    return getLessonsByDifficulty(difficulty);
  }

  // Get supplementary content
  static List<SavedItem> get allTips => List.unmodifiable(_tips);
  static List<SavedItem> get allArticles => List.unmodifiable(_articles);
  static List<SavedItem> get allReferences => List.unmodifiable(_references);

  // Get content by category
  static List<SavedItem> getContentByCategory(String category) {
    final allContent = [..._tips, ..._articles, ..._references];
    return allContent.where((item) => item.category == category).toList();
  }

  // Progress management with daily restrictions
  static Future<bool> markLessonCompleted(
    String lessonId, [
    DifficultyLevel? difficulty,
  ]) async {
    final lesson = getLessonById(lessonId);
    if (lesson == null) return false;

    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return false;

    final progress = UserPreferences.getProgressForDifficulty(targetDifficulty);
    if (progress == null) return false;

    // Convert actual lesson day to progress day for validation
    final progressDay = _getProgressDay(lesson.day, lesson.difficulty);

    // Check if this lesson can be completed today
    if (!progress.isDayUnlocked(progressDay)) {
      return false;
    }

    // Verify lesson belongs to target difficulty
    if (lesson.difficulty != targetDifficulty) {
      return false;
    }

    await UserPreferences.markLessonCompleted(lessonId, progressDay);
    return true;
  }

  static Future<bool> updateLessonProgress(
    String lessonId,
    double progressPercentage,
    int timeSpent, [
    DifficultyLevel? difficulty,
  ]) async {
    final lesson = getLessonById(lessonId);
    if (lesson == null) return false;

    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return false;

    final currentProgress = UserPreferences.getProgressForDifficulty(
      targetDifficulty,
    );
    if (currentProgress == null) return false;

    // Convert actual lesson day to progress day for validation
    final progressDay = _getProgressDay(lesson.day, lesson.difficulty);

    // Check if this lesson can be accessed today
    if (!currentProgress.isDayUnlocked(progressDay)) {
      return false;
    }

    // Verify lesson belongs to target difficulty
    if (lesson.difficulty != targetDifficulty) {
      return false;
    }

    final existingProgress = currentProgress.lessonProgress[lessonId];
    final updatedLessonProgress = LessonProgress(
      lessonId: lessonId,
      status:
          progressPercentage >= 1.0
              ? LessonStatus.completed
              : LessonStatus.inProgress,
      progressPercentage: progressPercentage,
      timeSpent: (existingProgress?.timeSpent ?? 0) + timeSpent,
      lastAccessed: DateTime.now(),
      startedAt: existingProgress?.startedAt ?? DateTime.now(),
      completedAt: progressPercentage >= 1.0 ? DateTime.now() : null,
    );

    await UserPreferences.updateLessonProgress(lessonId, updatedLessonProgress);

    // If lesson is completed, handle daily unlock logic
    if (progressPercentage >= 1.0) {
      await markLessonCompleted(lessonId, targetDifficulty);
    }

    return true;
  }

  // Unlock today's lesson for active difficulty
  static Future<void> unlockTodaysLesson([DifficultyLevel? difficulty]) async {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty != null) {
      final progress = UserPreferences.getProgressForDifficulty(
        targetDifficulty,
      );
      if (progress != null) {
        final updatedProgress = progress.unlockTodaysLesson();
        await UserPreferences.saveProgressForDifficulty(
          targetDifficulty,
          updatedProgress,
        );
      }
    }
  }

  // Search functionality (respects specified or active difficulty)
  static List<dynamic> searchContent(
    String query, [
    DifficultyLevel? difficulty,
  ]) {
    final lowercaseQuery = query.toLowerCase();
    final results = <dynamic>[];

    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty != null) {
      // Search lessons for target difficulty
      final lessons = getLessonsByDifficulty(targetDifficulty);
      results.addAll(
        lessons.where(
          (lesson) =>
              lesson.title.toLowerCase().contains(lowercaseQuery) ||
              lesson.description.toLowerCase().contains(lowercaseQuery) ||
              lesson.categories.any(
                (cat) => cat.toLowerCase().contains(lowercaseQuery),
              ),
        ),
      );
    }

    // Search tips
    results.addAll(
      _tips.where(
        (tip) =>
            tip.title.toLowerCase().contains(lowercaseQuery) ||
            tip.description.toLowerCase().contains(lowercaseQuery) ||
            tip.category.toLowerCase().contains(lowercaseQuery),
      ),
    );

    // Search articles
    results.addAll(
      _articles.where(
        (article) =>
            article.title.toLowerCase().contains(lowercaseQuery) ||
            article.description.toLowerCase().contains(lowercaseQuery) ||
            article.category.toLowerCase().contains(lowercaseQuery),
      ),
    );

    // Search references
    results.addAll(
      _references.where(
        (ref) =>
            ref.title.toLowerCase().contains(lowercaseQuery) ||
            ref.description.toLowerCase().contains(lowercaseQuery) ||
            ref.category.toLowerCase().contains(lowercaseQuery),
      ),
    );

    return results;
  }

  // Get recommended content based on progress for specified or active difficulty
  static List<dynamic> getRecommendedContent([DifficultyLevel? difficulty]) {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return [];

    final progress = UserPreferences.getProgressForDifficulty(targetDifficulty);
    if (progress == null) return [];

    final recommendations = <dynamic>[];
    final currentDay = progress.currentDay;
    final completedLessons =
        progress.lessonProgress.values
            .where((p) => p.status == LessonStatus.completed)
            .length;

    // Add current lesson
    final currentLesson = getCurrentLesson(targetDifficulty);
    if (currentLesson != null) {
      recommendations.add(currentLesson);
    }

    // Add relevant tips and articles based on progress
    if (completedLessons < 7) {
      // Week 1: Fundamentals
      recommendations.addAll(
        _tips
            .where(
              (tip) =>
                  tip.category.contains('fundamental') ||
                  tip.category.contains('basic'),
            )
            .take(3),
      );
    } else if (completedLessons < 14) {
      // Week 2: Technical
      recommendations.addAll(
        _articles
            .where(
              (article) =>
                  article.category.contains('technical') ||
                  article.category.contains('exposure'),
            )
            .take(2),
      );
    } else if (completedLessons < 21) {
      // Week 3: Composition
      recommendations.addAll(
        _articles
            .where(
              (article) =>
                  article.category.contains('composition') ||
                  article.category.contains('lighting'),
            )
            .take(2),
      );
    } else {
      // Week 4: Enhancement
      recommendations.addAll(
        _articles
            .where(
              (article) =>
                  article.category.contains('editing') ||
                  article.category.contains('post-processing'),
            )
            .take(2),
      );
    }

    return recommendations;
  }

  // Statistics (for specified or active difficulty)
  static Map<String, dynamic> getLessonStatistics([
    DifficultyLevel? difficulty,
  ]) {
    final targetDifficulty = difficulty ?? UserPreferences.activeDifficulty;
    if (targetDifficulty == null) return {};

    final progress = UserPreferences.getProgressForDifficulty(targetDifficulty);
    if (progress == null) return {};

    final lessons = getLessonsByDifficulty(targetDifficulty);
    final totalLessons = lessons.length;
    final completedLessons =
        progress.lessonProgress.values
            .where((p) => p.status == LessonStatus.completed)
            .length;
    final inProgressLessons =
        progress.lessonProgress.values
            .where((p) => p.status == LessonStatus.inProgress)
            .length;

    final totalTimeSpent = progress.lessonProgress.values.fold<int>(
      0,
      (sum, p) => sum + p.timeSpent,
    );

    final averageTimePerLesson =
        completedLessons > 0 ? totalTimeSpent / completedLessons : 0.0;

    return {
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'inProgressLessons': inProgressLessons,
      'completionRate':
          totalLessons > 0 ? completedLessons / totalLessons : 0.0,
      'totalTimeSpent': totalTimeSpent,
      'averageTimePerLesson': averageTimePerLesson,
      'currentStreak': progress.dailyStreak,
      'selectedDifficulty': progress.selectedDifficulty.toString(),
    };
  }

  // Get statistics for all difficulties
  static Map<String, dynamic> getAllStatistics() {
    final allStats = <String, dynamic>{};

    for (final difficulty in DifficultyLevel.values) {
      final stats = getLessonStatistics(difficulty);
      if (stats.isNotEmpty) {
        allStats[difficulty.toString().split('.').last] = stats;
      }
    }

    // Add global statistics
    final activeDifficulty = UserPreferences.activeDifficulty;
    final totalDifficultiesStarted =
        UserPreferences.getAvailableDifficulties().length;

    allStats['global'] = {
      'totalDifficultiesStarted': totalDifficultiesStarted,
      'activeDifficulty': activeDifficulty?.toString().split('.').last,
      'availableDifficulties':
          UserPreferences.getAvailableDifficulties()
              .map((d) => d.toString().split('.').last)
              .toList(),
    };

    return allStats;
  }

  // Private methods for loading data (unchanged)
  static Future<void> _loadLessons() async {
    _beginnerLessons = _createBeginnerLessons();
    _intermediateLessons = _createIntermediateLessons();
    _advancedLessons = _createAdvancedLessons();
  }

  static Future<void> _loadSupplementaryContent() async {
    _tips = _createPhotographyTips();
    _articles = _createPhotographyArticles();
    _references = _createPhotographyReferences();
  }

  static List<Lesson> _createBeginnerLessons() {
    final lessons = <Lesson>[];

    // Use the complete 30-day beginner course data
    for (final data in BeginnerLessonsData.lessons) {
      final exercises =
          (data['exercises'] as List)
              .map(
                (e) => PracticeExercise(
                  id: e['id'],
                  title: e['title'],
                  description: e['description'],
                  steps: List<String>.from(e['steps']),
                  requirements: Map<String, dynamic>.from(e['requirements']),
                  estimatedTime: e['estimatedTime'],
                ),
              )
              .toList();

      lessons.add(
        Lesson(
          id: data['id'] as String,
          day: data['day'] as int,
          title: data['title'] as String,
          subtitle: data['subtitle'] as String,
          description: data['description'] as String,
          content: data['content'] as String,
          estimatedDuration: data['estimatedDuration'] as int,
          type: _parseType(data['type'] as String),
          difficulty: DifficultyLevel.beginner,
          categories: List<String>.from(data['categories']),
          objectives: List<String>.from(data['objectives']),
          exercises: exercises,
          imageUrls: List<String>.from(data['imageUrls']),
          technicalDetails: Map<String, dynamic>.from(data['technicalDetails']),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    return lessons;
  }

  static List<Lesson> _createIntermediateLessons() {
    final lessons = <Lesson>[];
    for (final data in IntermediateLessons.lessons) {
      final exercises =
          (data['exercises'] as List)
              .map(
                (e) => PracticeExercise(
                  id: e['id'],
                  title: e['title'],
                  description: e['description'],
                  steps: List<String>.from(e['steps']),
                  requirements: Map<String, dynamic>.from(e['requirements']),
                  estimatedTime: e['estimatedTime'],
                ),
              )
              .toList();

      lessons.add(
        Lesson(
          id: data['id'] as String,
          day: data['day'] as int,
          title: data['title'] as String,
          subtitle: data['subtitle'] as String,
          description: data['description'] as String,
          content: data['content'] as String,
          estimatedDuration: data['estimatedDuration'] as int,
          type: _parseType(data['type'] as String),
          difficulty: DifficultyLevel.intermediate,
          categories: List<String>.from(data['categories']),
          objectives: List<String>.from(data['objectives']),
          exercises: exercises,
          imageUrls: List<String>.from(data['imageUrls']),
          technicalDetails: Map<String, dynamic>.from(data['technicalDetails']),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    return lessons;
  }

  static List<Lesson> _createAdvancedLessons() {
    final lessons = <Lesson>[];

    // Create advanced lessons from days 61-90
    for (final data in AdvancedLessons.lessons) {
      final exercises =
          (data['exercises'] as List)
              .map(
                (e) => PracticeExercise(
                  id: e['id'],
                  title: e['title'],
                  description: e['description'],
                  steps: List<String>.from(e['steps']),
                  requirements: Map<String, dynamic>.from(e['requirements']),
                  estimatedTime: e['estimatedTime'],
                ),
              )
              .toList();

      lessons.add(
        Lesson(
          id: data['id'] as String,
          day: data['day'] as int,
          title: data['title'] as String,
          subtitle: data['subtitle'] as String,
          description: data['description'] as String,
          content: data['content'] as String,
          estimatedDuration: data['estimatedDuration'] as int,
          type: _parseType(data['type'] as String),
          difficulty: DifficultyLevel.advanced,
          categories: List<String>.from(data['categories']),
          objectives: List<String>.from(data['objectives']),
          exercises: exercises,
          imageUrls: List<String>.from(data['imageUrls']),
          technicalDetails: Map<String, dynamic>.from(data['technicalDetails']),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    return lessons;
  }

  static LessonType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'theory':
        return LessonType.theory;
      case 'practice':
        return LessonType.practice;
      case 'review':
        return LessonType.review;
      case 'planning':
        return LessonType.planning;
      case 'project':
        return LessonType.project;
      case 'celebration':
        return LessonType.celebration;
      case 'workflow':
        return LessonType.practice; // Map workflow to practice
      case 'technical':
        return LessonType.theory; // Map technical to theory
      case 'business':
        return LessonType.theory; // Map business to theory
      case 'legal':
        return LessonType.theory; // Map legal to theory
      case 'creative':
        return LessonType.practice; // Map creative to practice
      case 'advanced':
        return LessonType.theory; // Map advanced to theory
      default:
        return LessonType.theory;
    }
  }

  // Supplementary content creation methods (unchanged)
  static List<SavedItem> _createPhotographyTips() {
    final tips = <SavedItem>[];
    final now = DateTime.now();

    final tipData = [
      {
        'title': 'Golden Hour Magic',
        'description':
            'Shoot one hour after sunrise or before sunset for warm, soft light',
        'category': 'lighting',
      },
      {
        'title': 'Rule of Thirds',
        'description':
            'Place important elements along grid lines for better composition',
        'category': 'composition',
      },
      {
        'title': 'Focus on Eyes',
        'description': 'In portraits, always ensure the eyes are tack sharp',
        'category': 'portraits',
      },
      {
        'title': 'Leading Lines',
        'description':
            'Use lines in your scene to guide the viewer\'s eye to your subject',
        'category': 'composition',
      },
      {
        'title': 'Shoot in RAW',
        'description':
            'RAW files give you much more flexibility in post-processing',
        'category': 'technical',
      },
      {
        'title': 'Manual Focus in Low Light',
        'description':
            'Switch to manual focus when autofocus struggles in dark conditions',
        'category': 'technical',
      },
      {
        'title': 'Back Button Focus',
        'description':
            'Separate focus from shutter for better control in challenging situations',
        'category': 'technical',
      },
      {
        'title': 'Histogram Reading',
        'description':
            'Use histogram to avoid blown highlights and crushed shadows',
        'category': 'exposure',
      },
    ];

    for (int i = 0; i < tipData.length; i++) {
      final tip = tipData[i];
      tips.add(
        SavedItem(
          id: 'tip_${i + 1}',
          title: tip['title']!,
          description: tip['description']!,
          type: SavedItemType.tip,
          category: tip['category']!,
          duration: 3,
          savedDate: now.subtract(Duration(days: i)),
        ),
      );
    }

    return tips;
  }

  static List<SavedItem> _createPhotographyArticles() {
    final articles = <SavedItem>[];
    final now = DateTime.now();

    final articleData = [
      {
        'title': 'Understanding Exposure Triangle',
        'description': 'Complete guide to ISO, aperture, and shutter speed',
        'category': 'technical',
        'duration': 15,
      },
      {
        'title': 'Portrait Lighting Techniques',
        'description': 'Master natural and artificial lighting for portraits',
        'category': 'lighting',
        'duration': 20,
      },
      {
        'title': 'Composition Fundamentals',
        'description':
            'Essential composition rules every photographer should know',
        'category': 'composition',
        'duration': 18,
      },
      {
        'title': 'Getting Started with Photo Editing',
        'description': 'Basic editing techniques using mobile and desktop apps',
        'category': 'editing',
        'duration': 25,
      },
      {
        'title': 'Fashion Photography Basics',
        'description': 'Introduction to fashion and portrait photography',
        'category': 'fashion',
        'duration': 22,
      },
      {
        'title': 'Working with Models',
        'description':
            'Communication and direction techniques for model photography',
        'category': 'fashion',
        'duration': 18,
      },
    ];

    for (int i = 0; i < articleData.length; i++) {
      final article = articleData[i];
      articles.add(
        SavedItem(
          id: 'article_${i + 1}',
          title: article['title']!.toString(),
          description: article['description']!.toString(),
          type: SavedItemType.article,
          category: article['category']!.toString(),
          duration: article['duration'] as int,
          savedDate: now.subtract(Duration(days: i * 2)),
        ),
      );
    }

    return articles;
  }

  static List<SavedItem> _createPhotographyReferences() {
    final references = <SavedItem>[];
    final now = DateTime.now();

    final referenceData = [
      {
        'title': 'Camera Settings Quick Reference',
        'description': 'Cheat sheet for common shooting situations',
        'category': 'technical',
      },
      {
        'title': 'Composition Rules Checklist',
        'description': 'Visual guide to composition techniques',
        'category': 'composition',
      },
      {
        'title': 'Photography Glossary',
        'description': 'Common photography terms and definitions',
        'category': 'fundamentals',
      },
      {
        'title': 'Light Quality Guide',
        'description':
            'Understanding different types of natural and artificial light',
        'category': 'lighting',
      },
      {
        'title': 'Fashion Photography Equipment Guide',
        'description': 'Essential gear for fashion and portrait photography',
        'category': 'equipment',
      },
      {
        'title': 'Post-Processing Workflow',
        'description': 'Step-by-step guide to professional photo editing',
        'category': 'editing',
      },
    ];

    for (int i = 0; i < referenceData.length; i++) {
      final ref = referenceData[i];
      references.add(
        SavedItem(
          id: 'ref_${i + 1}',
          title: ref['title']!,
          description: ref['description']!,
          type: SavedItemType.reference,
          category: ref['category']!,
          savedDate: now.subtract(Duration(days: i * 3)),
        ),
      );
    }

    return references;
  }

  // Export/Import functionality for backup
  static Map<String, dynamic> exportData() {
    return {
      'beginnerLessons': _beginnerLessons.map((l) => l.toJson()).toList(),
      'intermediateLessons':
          _intermediateLessons.map((l) => l.toJson()).toList(),
      'advancedLessons': _advancedLessons.map((l) => l.toJson()).toList(),
      'tips': _tips.map((t) => t.toJson()).toList(),
      'articles': _articles.map((a) => a.toJson()).toList(),
      'references': _references.map((r) => r.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  static void importData(Map<String, dynamic> data) {
    try {
      if (data['beginnerLessons'] != null) {
        _beginnerLessons =
            (data['beginnerLessons'] as List)
                .map((l) => Lesson.fromJson(l))
                .toList();
      }
      if (data['intermediateLessons'] != null) {
        _intermediateLessons =
            (data['intermediateLessons'] as List)
                .map((l) => Lesson.fromJson(l))
                .toList();
      }
      if (data['advancedLessons'] != null) {
        _advancedLessons =
            (data['advancedLessons'] as List)
                .map((l) => Lesson.fromJson(l))
                .toList();
      }
      if (data['tips'] != null) {
        _tips =
            (data['tips'] as List).map((t) => SavedItem.fromJson(t)).toList();
      }
      if (data['articles'] != null) {
        _articles =
            (data['articles'] as List)
                .map((a) => SavedItem.fromJson(a))
                .toList();
      }
      if (data['references'] != null) {
        _references =
            (data['references'] as List)
                .map((r) => SavedItem.fromJson(r))
                .toList();
      }
    } catch (e) {
      print('Error importing data: $e');
    }
  }
}
