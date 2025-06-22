import 'dart:convert';
import '../models/lesson.dart';
import '../models/user_progress.dart';
import '../models/saved_item.dart';
import '../utils/constants.dart';
import 'user_preferences.dart';

class LessonManager {
  static List<Lesson> _lessons = [];
  static List<SavedItem> _tips = [];
  static List<SavedItem> _articles = [];
  static List<SavedItem> _references = [];

  static Future<void> init() async {
    await _loadLessons();
    await _loadSupplementaryContent();
  }

  // Get all lessons
  static List<Lesson> get allLessons => List.unmodifiable(_lessons);

  // Get lessons by difficulty
  static List<Lesson> getLessonsByDifficulty(DifficultyLevel difficulty) {
    return _lessons.where((lesson) => lesson.difficulty == difficulty).toList();
  }

  // Get lesson by ID
  static Lesson? getLessonById(String id) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get lesson by day
  static Lesson? getLessonByDay(int day) {
    try {
      return _lessons.firstWhere((lesson) => lesson.day == day);
    } catch (e) {
      return null;
    }
  }

  // Get current lesson based on user progress and daily restrictions
  static Lesson? getCurrentLesson() {
    final progress = UserPreferences.currentProgress;
    if (progress != null) {
      final maxAvailableDay = progress.getMaxAvailableDay();
      return getLessonByDay(maxAvailableDay);
    }
    return null;
  }

  // Check if a lesson can be accessed today
  static bool canAccessLesson(int lessonDay) {
    final progress = UserPreferences.currentProgress;
    if (progress == null) return false;

    return progress.isDayUnlocked(lessonDay);
  }

  // Check if user has already accessed today's lesson
  static bool hasAccessedTodaysLesson() {
    final progress = UserPreferences.currentProgress;
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
  static Lesson? getNextAvailableLesson() {
    final progress = UserPreferences.currentProgress;
    if (progress == null) return null;

    final maxAvailableDay = progress.getMaxAvailableDay();

    // Check if today's lesson is completed
    final todaysLesson = getLessonByDay(maxAvailableDay);
    if (todaysLesson != null && !progress.isLessonCompleted(todaysLesson.id)) {
      return todaysLesson;
    }

    // If today's lesson is completed, return tomorrow's lesson (if available)
    final nextDay = maxAvailableDay + 1;
    if (nextDay <= AppConstants.totalCourseDays &&
        progress.isDayUnlocked(nextDay)) {
      return getLessonByDay(nextDay);
    }

    return null;
  }

  // Get time until next lesson unlocks
  static String getTimeUntilNextLesson() {
    final progress = UserPreferences.currentProgress;
    if (progress == null) return 'Unknown';

    final maxAvailableDay = progress.getMaxAvailableDay();
    final nextDay = maxAvailableDay + 1;

    if (nextDay > AppConstants.totalCourseDays) {
      return 'Course completed';
    }

    return progress.getTimeUntilUnlock(nextDay);
  }

  // Get next lesson
  static Lesson? getNextLesson(int currentDay) {
    return getLessonByDay(currentDay + 1);
  }

  // Get previous lesson
  static Lesson? getPreviousLesson(int currentDay) {
    if (currentDay > 1) {
      return getLessonByDay(currentDay - 1);
    }
    return null;
  }

  // Get lessons by type
  static List<Lesson> getLessonsByType(LessonType type) {
    return _lessons.where((lesson) => lesson.type == type).toList();
  }

  // Get lessons by category
  static List<Lesson> getLessonsByCategory(String category) {
    return _lessons
        .where((lesson) => lesson.categories.contains(category))
        .toList();
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
  static Future<bool> markLessonCompleted(String lessonId) async {
    final lesson = getLessonById(lessonId);
    if (lesson == null) return false;

    final progress = UserPreferences.currentProgress;
    if (progress == null) return false;

    // Check if this lesson can be completed today
    if (!progress.isDayUnlocked(lesson.day)) {
      return false;
    }

    await UserPreferences.markLessonCompleted(lessonId, lesson.day);
    return true;
  }

  static Future<bool> updateLessonProgress(
    String lessonId,
    double progress,
    int timeSpent,
  ) async {
    final lesson = getLessonById(lessonId);
    if (lesson == null) return false;

    final currentProgress = UserPreferences.currentProgress;
    if (currentProgress == null) return false;

    // Check if this lesson can be accessed today
    if (!currentProgress.isDayUnlocked(lesson.day)) {
      return false;
    }

    final existingProgress = currentProgress.lessonProgress[lessonId];
    final updatedLessonProgress = LessonProgress(
      lessonId: lessonId,
      status:
          progress >= 1.0 ? LessonStatus.completed : LessonStatus.inProgress,
      progressPercentage: progress,
      timeSpent: (existingProgress?.timeSpent ?? 0) + timeSpent,
      lastAccessed: DateTime.now(),
      startedAt: existingProgress?.startedAt ?? DateTime.now(),
      completedAt: progress >= 1.0 ? DateTime.now() : null,
    );

    await UserPreferences.updateLessonProgress(lessonId, updatedLessonProgress);

    // If lesson is completed, handle daily unlock logic
    if (progress >= 1.0) {
      await markLessonCompleted(lessonId);
    }

    return true;
  }

  // Unlock today's lesson (called when user opens the app)
  static Future<void> unlockTodaysLesson() async {
    final progress = UserPreferences.currentProgress;
    if (progress != null) {
      final updatedProgress = progress.unlockTodaysLesson();
      await UserPreferences.saveUserProgress(updatedProgress);
    }
  }

  // Search functionality
  static List<dynamic> searchContent(String query) {
    final lowercaseQuery = query.toLowerCase();
    final results = <dynamic>[];

    // Search lessons
    results.addAll(
      _lessons.where(
        (lesson) =>
            lesson.title.toLowerCase().contains(lowercaseQuery) ||
            lesson.description.toLowerCase().contains(lowercaseQuery) ||
            lesson.categories.any(
              (cat) => cat.toLowerCase().contains(lowercaseQuery),
            ),
      ),
    );

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

  // Get recommended content based on progress
  static List<dynamic> getRecommendedContent() {
    final progress = UserPreferences.currentProgress;
    if (progress == null) return [];

    final recommendations = <dynamic>[];
    final currentDay = progress.currentDay;
    final completedLessons =
        progress.lessonProgress.values
            .where((p) => p.status == LessonStatus.completed)
            .length;

    // Add current lesson
    final currentLesson = getCurrentLesson();
    if (currentLesson != null) {
      recommendations.add(currentLesson);
    }

    // Add relevant tips and articles based on progress
    if (completedLessons < 5) {
      // Beginner content
      recommendations.addAll(
        _tips
            .where(
              (tip) =>
                  tip.category == 'Fundamentals' || tip.category == 'Basics',
            )
            .take(3),
      );
    } else if (completedLessons < 15) {
      // Intermediate content
      recommendations.addAll(
        _articles
            .where(
              (article) =>
                  article.category == 'Composition' ||
                  article.category == 'Lighting',
            )
            .take(2),
      );
    } else {
      // Advanced content
      recommendations.addAll(
        _articles
            .where(
              (article) =>
                  article.category == 'Advanced' ||
                  article.category == 'Professional',
            )
            .take(2),
      );
    }

    return recommendations;
  }

  // Statistics
  static Map<String, dynamic> getLessonStatistics() {
    final progress = UserPreferences.currentProgress;
    if (progress == null) return {};

    final totalLessons = _lessons.length;
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
      'completionRate': completedLessons / totalLessons,
      'totalTimeSpent': totalTimeSpent,
      'averageTimePerLesson': averageTimePerLesson,
      'currentStreak': progress.dailyStreak,
    };
  }

  // Private methods for loading data
  static Future<void> _loadLessons() async {
    // In a real app, this would load from a database or API
    // For now, we'll create the lessons programmatically
    _lessons = _generateLessons();
  }

  static Future<void> _loadSupplementaryContent() async {
    // Generate tips, articles, and references
    _tips = _generateTips();
    _articles = _generateArticles();
    _references = _generateReferences();
  }

  static List<Lesson> _generateLessons() {
    final lessons = <Lesson>[];
    final now = DateTime.now();

    // Create 30 lessons for the course
    final lessonData = [
      {
        'title': 'Camera Basics',
        'subtitle': 'Understanding your camera',
        'type': LessonType.theory,
        'categories': ['Fundamentals'],
        'duration': 15,
      },
      {
        'title': 'Composition Rules',
        'subtitle': 'Rule of thirds & leading lines',
        'type': LessonType.theory,
        'categories': ['Composition'],
        'duration': 20,
      },
      {
        'title': 'Lighting Fundamentals',
        'subtitle': 'Natural vs artificial light',
        'type': LessonType.theory,
        'categories': ['Lighting'],
        'duration': 18,
      },
      {
        'title': 'Portrait Practice',
        'subtitle': 'Take your first portraits',
        'type': LessonType.practice,
        'categories': ['Portraits'],
        'duration': 25,
      },
      {
        'title': 'Focus Techniques',
        'subtitle': 'Manual vs auto focus',
        'type': LessonType.theory,
        'categories': ['Technical'],
        'duration': 22,
      },
      {
        'title': 'Exposure Triangle',
        'subtitle': 'ISO, Aperture, Shutter Speed',
        'type': LessonType.theory,
        'categories': ['Technical'],
        'duration': 30,
      },
      {
        'title': 'Aperture & DOF',
        'subtitle': 'Depth of field control',
        'type': LessonType.theory,
        'categories': ['Technical'],
        'duration': 25,
      },
      {
        'title': 'Shutter Speed',
        'subtitle': 'Motion and time control',
        'type': LessonType.theory,
        'categories': ['Technical'],
        'duration': 20,
      },
      {
        'title': 'ISO Settings',
        'subtitle': 'Managing digital noise',
        'type': LessonType.theory,
        'categories': ['Technical'],
        'duration': 18,
      },
      {
        'title': 'Street Photography',
        'subtitle': 'Candid moments practice',
        'type': LessonType.practice,
        'categories': ['Street'],
        'duration': 35,
      },
      // ... continue for all 30 lessons
    ];

    for (int i = 0; i < 30; i++) {
      final data = lessonData[i % lessonData.length];
      lessons.add(
        Lesson(
          id: 'lesson_${i + 1}',
          day: i + 1,
          title: data['title'] as String,
          subtitle: data['subtitle'] as String,
          description:
              'Learn ${data['title'].toString().toLowerCase()} with practical examples and exercises.',
          content: _generateLessonContent(data['title'] as String),
          estimatedDuration: data['duration'] as int,
          type: data['type'] as LessonType,
          difficulty:
              i < 10
                  ? DifficultyLevel.beginner
                  : i < 20
                  ? DifficultyLevel.intermediate
                  : DifficultyLevel.advanced,
          categories: data['categories'] as List<String>,
          objectives: _generateObjectives(data['title'] as String),
          exercises: _generateExercises(data['title'] as String),
          imageUrls: [],
          technicalDetails: _generateTechnicalDetails(data['title'] as String),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    return lessons;
  }

  static String _generateLessonContent(String title) {
    return '''
# $title

## Introduction
Welcome to this comprehensive lesson on ${title.toLowerCase()}. This lesson will provide you with the knowledge and practical skills needed to master this important photography concept.

## Key Concepts
Understanding ${title.toLowerCase()} is crucial for developing your photography skills. We'll cover the fundamental principles and practical applications.

## Practical Applications
Learn how to apply these concepts in real-world photography scenarios.

## Common Mistakes
Avoid these common pitfalls when working with ${title.toLowerCase()}.

## Summary
By the end of this lesson, you'll have a solid understanding of ${title.toLowerCase()} and how to use it effectively in your photography.
''';
  }

  static List<String> _generateObjectives(String title) {
    return [
      'Understand the core principles of ${title.toLowerCase()}',
      'Learn practical applications and techniques',
      'Practice with hands-on exercises',
      'Avoid common mistakes and pitfalls',
    ];
  }

  static List<PracticeExercise> _generateExercises(String title) {
    return [
      PracticeExercise(
        id: 'exercise_1',
        title: '$title Practice',
        description: 'Apply what you\'ve learned about ${title.toLowerCase()}',
        steps: [
          'Set up your camera with the recommended settings',
          'Find a suitable subject or scene',
          'Apply the techniques from this lesson',
          'Take multiple shots with different variations',
          'Review and analyze your results',
        ],
        requirements: {'camera': 'Any camera', 'time': '30 minutes'},
        estimatedTime: 30,
      ),
    ];
  }

  static Map<String, dynamic> _generateTechnicalDetails(String title) {
    return {
      'difficulty': 'Beginner to Intermediate',
      'prerequisites': ['Basic camera operation'],
      'equipment': ['Camera', 'Optional: tripod'],
      'settings': {
        'recommended_mode': 'Manual or Aperture Priority',
        'focus_mode': 'Single-point AF',
      },
    };
  }

  static List<SavedItem> _generateTips() {
    final tips = <SavedItem>[];
    final now = DateTime.now();

    final tipData = [
      {
        'title': 'Golden Hour Magic',
        'description': 'Best times for natural lighting',
        'category': 'Lighting',
      },
      {
        'title': 'Rule of Thirds',
        'description': 'Composition technique for better photos',
        'category': 'Composition',
      },
      {
        'title': 'Focus Tracking',
        'description': 'Keep moving subjects sharp',
        'category': 'Technical',
      },
      {
        'title': 'Background Blur',
        'description': 'Create professional-looking portraits',
        'category': 'Portraits',
      },
      {
        'title': 'Leading Lines',
        'description': 'Guide the viewer\'s eye through your photo',
        'category': 'Composition',
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
          duration: 5,
          savedDate: now.subtract(Duration(days: i)),
        ),
      );
    }

    return tips;
  }

  static List<SavedItem> _generateArticles() {
    final articles = <SavedItem>[];
    final now = DateTime.now();

    final articleData = [
      {
        'title': 'Understanding Camera Sensors',
        'description': 'Full-frame vs crop sensors explained',
        'category': 'Technical',
        'duration': 15,
      },
      {
        'title': 'Portrait Photography Guide',
        'description': 'Complete guide to taking stunning portraits',
        'category': 'Portraits',
        'duration': 25,
      },
      {
        'title': 'Landscape Photography Tips',
        'description': 'Capture breathtaking natural scenes',
        'category': 'Landscape',
        'duration': 20,
      },
      {
        'title': 'Street Photography Ethics',
        'description': 'Respectful practices for street photography',
        'category': 'Street',
        'duration': 12,
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

  static List<SavedItem> _generateReferences() {
    final references = <SavedItem>[];
    final now = DateTime.now();

    final referenceData = [
      {
        'title': 'Camera Settings Cheat Sheet',
        'description': 'Quick reference for manual settings',
        'category': 'Technical',
      },
      {
        'title': 'Composition Rules Guide',
        'description': 'All composition techniques in one place',
        'category': 'Composition',
      },
      {
        'title': 'Photography Glossary',
        'description': 'Common photography terms defined',
        'category': 'Fundamentals',
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
      'lessons': _lessons.map((l) => l.toJson()).toList(),
      'tips': _tips.map((t) => t.toJson()).toList(),
      'articles': _articles.map((a) => a.toJson()).toList(),
      'references': _references.map((r) => r.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  static void importData(Map<String, dynamic> data) {
    try {
      if (data['lessons'] != null) {
        _lessons =
            (data['lessons'] as List).map((l) => Lesson.fromJson(l)).toList();
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
