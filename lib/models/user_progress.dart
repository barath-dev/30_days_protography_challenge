import 'package:photography_guide/models/lesson.dart';

class UserProgress {
  static bool debugUnlockAllLessons = false; // Set to true for testing

  final String userId;
  final DifficultyLevel selectedDifficulty;
  final int currentDay;
  final int dailyStreak;
  final DateTime lastActivityDate;
  final DateTime courseStartDate;
  final Map<String, LessonProgress> lessonProgress;
  final Map<int, DateTime> dailyUnlockDates; // Track when each day was unlocked
  final List<String> savedItemIds;
  final Map<String, DateTime> achievements;
  final double overallProgress;
  final DateTime startDate;
  final DateTime? completionDate;

  const UserProgress({
    required this.userId,
    required this.selectedDifficulty,
    required this.currentDay,
    required this.dailyStreak,
    required this.lastActivityDate,
    required this.courseStartDate,
    required this.lessonProgress,
    required this.dailyUnlockDates,
    required this.savedItemIds,
    required this.achievements,
    required this.overallProgress,
    required this.startDate,
    this.completionDate,
  });

  factory UserProgress.initial(DifficultyLevel difficulty) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    return UserProgress(
      userId: DateTime.now().millisecondsSinceEpoch.toString(),
      selectedDifficulty: difficulty,
      currentDay: 1,
      dailyStreak: 1,
      lastActivityDate: now,
      courseStartDate: startOfToday,
      lessonProgress: {},
      dailyUnlockDates: {1: startOfToday}, // First day is immediately unlocked
      savedItemIds: [],
      achievements: {},
      overallProgress: 0.0,
      startDate: now,
    );
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] ?? '',
      selectedDifficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['selectedDifficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      currentDay: json['currentDay'] ?? 1,
      dailyStreak: json['dailyStreak'] ?? 1,
      lastActivityDate: DateTime.parse(
        json['lastActivityDate'] ?? DateTime.now().toIso8601String(),
      ),
      courseStartDate: DateTime.parse(
        json['courseStartDate'] ?? DateTime.now().toIso8601String(),
      ),
      lessonProgress:
          (json['lessonProgress'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, LessonProgress.fromJson(v)),
          ) ??
          {},
      dailyUnlockDates:
          (json['dailyUnlockDates'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), DateTime.parse(v)),
          ) ??
          {},
      savedItemIds: List<String>.from(json['savedItemIds'] ?? []),
      achievements:
          (json['achievements'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, DateTime.parse(v)),
          ) ??
          {},
      overallProgress: (json['overallProgress'] ?? 0.0).toDouble(),
      startDate: DateTime.parse(
        json['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      completionDate:
          json['completionDate'] != null
              ? DateTime.parse(json['completionDate'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'selectedDifficulty': selectedDifficulty.toString().split('.').last,
      'currentDay': currentDay,
      'dailyStreak': dailyStreak,
      'lastActivityDate': lastActivityDate.toIso8601String(),
      'courseStartDate': courseStartDate.toIso8601String(),
      'lessonProgress': lessonProgress.map((k, v) => MapEntry(k, v.toJson())),
      'dailyUnlockDates': dailyUnlockDates.map(
        (k, v) => MapEntry(k.toString(), v.toIso8601String()),
      ),
      'savedItemIds': savedItemIds,
      'achievements': achievements.map(
        (k, v) => MapEntry(k, v.toIso8601String()),
      ),
      'overallProgress': overallProgress,
      'startDate': startDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
    };
  }

  UserProgress copyWith({
    String? userId,
    DifficultyLevel? selectedDifficulty,
    int? currentDay,
    int? dailyStreak,
    DateTime? lastActivityDate,
    DateTime? courseStartDate,
    Map<String, LessonProgress>? lessonProgress,
    Map<int, DateTime>? dailyUnlockDates,
    List<String>? savedItemIds,
    Map<String, DateTime>? achievements,
    double? overallProgress,
    DateTime? startDate,
    DateTime? completionDate,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      currentDay: currentDay ?? this.currentDay,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      courseStartDate: courseStartDate ?? this.courseStartDate,
      lessonProgress: lessonProgress ?? this.lessonProgress,
      dailyUnlockDates: dailyUnlockDates ?? this.dailyUnlockDates,
      savedItemIds: savedItemIds ?? this.savedItemIds,
      achievements: achievements ?? this.achievements,
      overallProgress: overallProgress ?? this.overallProgress,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
    );
  }

  // Helper methods
  bool isLessonCompleted(String lessonId) {
    return lessonProgress[lessonId]?.status == LessonStatus.completed;
  }

  bool isLessonCurrent(String lessonId) {
    return lessonProgress[lessonId]?.status == LessonStatus.current;
  }

  // Updated to work with progress days (1-30) instead of actual lesson days
  bool isLessonLocked(String lessonId, int progressDay) {
    return !isDayUnlocked(progressDay);
  }

  // Daily unlock system methods (works with progress days 1-30)
  bool isDayUnlocked(int progressDay) {
    if (debugUnlockAllLessons) return true;
    if (progressDay == 1) return true;

    // Check if this day has been explicitly unlocked
    if (dailyUnlockDates.containsKey(progressDay)) return true;

    // Check if enough days have passed since course start
    final today = DateTime.now();
    final daysSinceCourseStart = today.difference(courseStartDate).inDays;

    // Unlock one day at a time, respecting the daily restriction
    return progressDay <= daysSinceCourseStart + 1;
  }

  DateTime? getDayUnlockDate(int progressDay) {
    if (progressDay == 1) return courseStartDate;

    // If already unlocked, return the unlock date
    if (dailyUnlockDates.containsKey(progressDay)) {
      return dailyUnlockDates[progressDay];
    }

    // Calculate when this day will be unlocked
    final expectedUnlockDate = courseStartDate.add(
      Duration(days: progressDay - 1),
    );
    return expectedUnlockDate;
  }

  String getTimeUntilUnlock(int progressDay) {
    final unlockDate = getDayUnlockDate(progressDay);
    if (unlockDate == null) return 'Unknown';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final unlockDay = DateTime(
      unlockDate.year,
      unlockDate.month,
      unlockDate.day,
    );

    if (unlockDay.isBefore(today) || unlockDay.isAtSameMomentAs(today)) {
      return 'Available now';
    }

    final difference = unlockDay.difference(today).inDays;
    if (difference == 1) {
      return 'Tomorrow';
    } else {
      return 'In $difference days';
    }
  }

  bool canAccessToday() {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final lastActivity = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );

    // Can access if it's a new day or first time today
    return startOfToday.isAfter(lastActivity) ||
        startOfToday.isAtSameMomentAs(lastActivity);
  }

  int getMaxAvailableDay() {
    final today = DateTime.now();
    final daysSinceCourseStart = today.difference(courseStartDate).inDays;
    return (daysSinceCourseStart + 1).clamp(1, 30);
  }

  // Updated to work with progress days instead of actual lesson days
  LessonStatus getLessonStatus(String lessonId, int progressDay) {
    // Check daily unlock first (using progress day)
    if (!isDayUnlocked(progressDay)) return LessonStatus.locked;

    if (isLessonCompleted(lessonId)) return LessonStatus.completed;

    // Current day logic - only one lesson can be current at a time
    final maxAvailableDay = getMaxAvailableDay();
    if (progressDay == maxAvailableDay) {
      final progress = lessonProgress[lessonId];
      if (progress != null && progress.progressPercentage > 0) {
        return LessonStatus.inProgress;
      }
      return LessonStatus.current;
    }

    if (progressDay < maxAvailableDay) return LessonStatus.available;

    return LessonStatus.locked;
  }

  double getLessonProgress(String lessonId) {
    return lessonProgress[lessonId]?.progressPercentage ?? 0.0;
  }

  bool isItemSaved(String itemId) {
    return savedItemIds.contains(itemId);
  }

  // Updated to work with progress days
  UserProgress markLessonCompleted(String lessonId, int progressDay) {
    final updatedProgress = Map<String, LessonProgress>.from(lessonProgress);
    updatedProgress[lessonId] = LessonProgress(
      lessonId: lessonId,
      status: LessonStatus.completed,
      progressPercentage: 1.0,
      timeSpent: updatedProgress[lessonId]?.timeSpent ?? 0,
      lastAccessed: DateTime.now(),
      completedAt: DateTime.now(),
    );

    // Calculate overall progress
    final totalLessons = 30; // Assuming 30-day course
    final completedLessons =
        updatedProgress.values
            .where((p) => p.status == LessonStatus.completed)
            .length;
    final newOverallProgress = completedLessons / totalLessons;

    // Update daily unlock dates - unlock next day when current lesson is completed
    final updatedUnlockDates = Map<int, DateTime>.from(dailyUnlockDates);
    final nextProgressDay = progressDay + 1;
    if (nextProgressDay <= 30 &&
        !updatedUnlockDates.containsKey(nextProgressDay)) {
      // Unlock the next day, but only if it's not in the future
      final today = DateTime.now();
      final nextDayUnlockDate = courseStartDate.add(
        Duration(days: nextProgressDay - 1),
      );
      final startOfToday = DateTime(today.year, today.month, today.day);
      final startOfNextDayUnlock = DateTime(
        nextDayUnlockDate.year,
        nextDayUnlockDate.month,
        nextDayUnlockDate.day,
      );

      // Only unlock if the scheduled unlock date has arrived
      if (startOfNextDayUnlock.isBefore(startOfToday) ||
          startOfNextDayUnlock.isAtSameMomentAs(startOfToday)) {
        updatedUnlockDates[nextProgressDay] = nextDayUnlockDate;
      }
    }

    return copyWith(
      lessonProgress: updatedProgress,
      dailyUnlockDates: updatedUnlockDates,
      overallProgress: newOverallProgress,
      currentDay: progressDay == currentDay ? currentDay + 1 : currentDay,
      lastActivityDate: DateTime.now(),
    );
  }

  UserProgress unlockTodaysLesson() {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final maxAvailableDay = getMaxAvailableDay();

    // Update daily unlock dates for today if not already unlocked
    final updatedUnlockDates = Map<int, DateTime>.from(dailyUnlockDates);
    if (!updatedUnlockDates.containsKey(maxAvailableDay)) {
      updatedUnlockDates[maxAvailableDay] = startOfToday;
    }

    return copyWith(
      dailyUnlockDates: updatedUnlockDates,
      lastActivityDate: today,
    );
  }

  UserProgress updateStreak() {
    final today = DateTime.now();
    final lastDate = lastActivityDate;
    final daysDifference = today.difference(lastDate).inDays;

    int newStreak;
    if (daysDifference == 0) {
      // Same day, keep current streak
      newStreak = dailyStreak;
    } else if (daysDifference == 1) {
      // Consecutive day, increment streak
      newStreak = dailyStreak + 1;
    } else {
      // Streak broken, reset to 1
      newStreak = 1;
    }

    return copyWith(dailyStreak: newStreak, lastActivityDate: today);
  }

  UserProgress toggleSavedItem(String itemId) {
    final updatedSavedItems = List<String>.from(savedItemIds);
    if (updatedSavedItems.contains(itemId)) {
      updatedSavedItems.remove(itemId);
    } else {
      updatedSavedItems.add(itemId);
    }
    return copyWith(savedItemIds: updatedSavedItems);
  }
}

class LessonProgress {
  final String lessonId;
  final LessonStatus status;
  final double progressPercentage;
  final int timeSpent; // in minutes
  final DateTime lastAccessed;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const LessonProgress({
    required this.lessonId,
    required this.status,
    required this.progressPercentage,
    required this.timeSpent,
    required this.lastAccessed,
    this.startedAt,
    this.completedAt,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lessonId'] ?? '',
      status: LessonStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => LessonStatus.locked,
      ),
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
      timeSpent: json['timeSpent'] ?? 0,
      lastAccessed: DateTime.parse(
        json['lastAccessed'] ?? DateTime.now().toIso8601String(),
      ),
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'status': status.toString().split('.').last,
      'progressPercentage': progressPercentage,
      'timeSpent': timeSpent,
      'lastAccessed': lastAccessed.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

enum LessonStatus {
  locked, // Not yet unlocked (future days)
  lockedToday, // Today's lesson already accessed
  available, // Available to access
  current, // Current lesson for today
  inProgress, // Started but not completed
  completed, // Fully completed
}
