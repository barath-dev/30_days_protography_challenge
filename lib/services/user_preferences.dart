import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:photography_guide/models/lesson.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/saved_item.dart';

class UserPreferences {
  static SharedPreferences? _prefs;
  static Map<DifficultyLevel, UserProgress> _allProgress = {};
  static DifficultyLevel? _activeDifficulty;

  // Keys for SharedPreferences
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyAllProgress = 'all_user_progress';
  static const String _keyActiveDifficulty = 'active_difficulty';
  static const String _keySavedItems = 'saved_items';
  static const String _keySettings = 'app_settings';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyLastSyncTime = 'last_sync_time';

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadAllProgress();
    await _loadActiveDifficulty();
  }

  // Force reload - useful when data changes
  static Future<void> forceReload() async {
    await _loadAllProgress();
    await _loadActiveDifficulty();
  }

  // First launch management
  static bool isFirstLaunch() {
    return _prefs?.getBool(_keyFirstLaunch) ?? true;
  }

  static Future<void> setFirstLaunchCompleted() async {
    await _prefs?.setBool(_keyFirstLaunch, false);
  }

  // Active Difficulty Management
  static DifficultyLevel? get activeDifficulty => _activeDifficulty;

  static Future<void> _loadActiveDifficulty() async {
    final difficultyString = _prefs?.getString(_keyActiveDifficulty);
    if (difficultyString != null) {
      try {
        _activeDifficulty = DifficultyLevel.values.firstWhere(
          (e) => e.toString().split('.').last == difficultyString,
        );
      } catch (e) {
        _activeDifficulty = null;
      }
    }
  }

  static Future<void> setActiveDifficulty(DifficultyLevel difficulty) async {
    _activeDifficulty = difficulty;
    await _prefs?.setString(
      _keyActiveDifficulty,
      difficulty.toString().split('.').last,
    );
    await _updateLastSyncTime();
  }

  // Multi-Progress Management
  static Map<DifficultyLevel, UserProgress> get allProgress =>
      Map.unmodifiable(_allProgress);

  static UserProgress? get currentProgress =>
      _activeDifficulty != null ? _allProgress[_activeDifficulty] : null;

  static Future<void> _loadAllProgress() async {
    final progressJson = _prefs?.getString(_keyAllProgress);
    if (progressJson != null) {
      try {
        final progressData = jsonDecode(progressJson) as Map<String, dynamic>;
        _allProgress.clear();

        for (final entry in progressData.entries) {
          final difficulty = DifficultyLevel.values.firstWhere(
            (e) => e.toString().split('.').last == entry.key,
          );
          final progress = UserProgress.fromJson(
            entry.value as Map<String, dynamic>,
          );
          _allProgress[difficulty] = progress;
        }

        print(
          'All progress loaded: ${_allProgress.keys.map((d) => d.toString().split('.').last).join(', ')}',
        );
      } catch (e) {
        print('Error loading all progress: $e');
        _allProgress.clear();
      }
    }
  }

  static Future<void> _saveAllProgress() async {
    try {
      final progressData = <String, dynamic>{};
      for (final entry in _allProgress.entries) {
        progressData[entry.key.toString().split('.').last] =
            entry.value.toJson();
      }

      final progressJson = jsonEncode(progressData);
      await _prefs?.setString(_keyAllProgress, progressJson);
      await _updateLastSyncTime();
      print(
        'All progress saved for difficulties: ${_allProgress.keys.map((d) => d.toString().split('.').last).join(', ')}',
      );
    } catch (e) {
      print('Error saving all progress: $e');
    }
  }

  static Future<void> saveProgressForDifficulty(
    DifficultyLevel difficulty,
    UserProgress progress,
  ) async {
    _allProgress[difficulty] = progress;
    await _saveAllProgress();
    print('Progress saved for difficulty: $difficulty');
  }

  static UserProgress? getProgressForDifficulty(DifficultyLevel difficulty) {
    return _allProgress[difficulty];
  }

  static Future<void> initializeProgressForDifficulty(
    DifficultyLevel difficulty,
  ) async {
    if (!_allProgress.containsKey(difficulty)) {
      final progress = UserProgress.initial(difficulty);
      _allProgress[difficulty] = progress;
      await _saveAllProgress();
      print('Progress initialized for difficulty: $difficulty');
    }

    // Set as active difficulty
    await setActiveDifficulty(difficulty);
    await setFirstLaunchCompleted();
  }

  // Current Progress Helper Methods (work with active difficulty)
  static Future<void> updateCurrentProgress(UserProgress progress) async {
    if (_activeDifficulty != null) {
      await saveProgressForDifficulty(_activeDifficulty!, progress);
    }
  }

  static Future<void> updateLessonProgress(
    String lessonId,
    LessonProgress lessonProgress,
  ) async {
    final current = currentProgress;
    if (current != null && _activeDifficulty != null) {
      final updatedProgress = Map<String, LessonProgress>.from(
        current.lessonProgress,
      );
      updatedProgress[lessonId] = lessonProgress;

      final newUserProgress = current.copyWith(
        lessonProgress: updatedProgress,
        lastActivityDate: DateTime.now(),
      );

      await saveProgressForDifficulty(_activeDifficulty!, newUserProgress);
    }
  }

  static Future<void> markLessonCompleted(
    String lessonId,
    int progressDay,
  ) async {
    final current = currentProgress;
    if (current != null && _activeDifficulty != null) {
      final updatedProgress = current.markLessonCompleted(
        lessonId,
        progressDay,
      );
      await saveProgressForDifficulty(_activeDifficulty!, updatedProgress);
    }
  }

  static Future<void> updateStreak() async {
    final current = currentProgress;
    if (current != null && _activeDifficulty != null) {
      final updatedProgress = current.updateStreak();
      await saveProgressForDifficulty(_activeDifficulty!, updatedProgress);
    }
  }

  static Future<void> updateCurrentDay(int newDay) async {
    final current = currentProgress;
    if (current != null && _activeDifficulty != null) {
      final updatedProgress = current.copyWith(
        currentDay: newDay,
        lastActivityDate: DateTime.now(),
      );
      await saveProgressForDifficulty(_activeDifficulty!, updatedProgress);
    }
  }

  static Future<void> unlockTodaysLessonForCurrent() async {
    final current = currentProgress;
    if (current != null && _activeDifficulty != null) {
      final updatedProgress = current.unlockTodaysLesson();
      await saveProgressForDifficulty(_activeDifficulty!, updatedProgress);
    }
  }

  // Saved Items Management (shared across all difficulties)
  static Future<List<SavedItem>> getSavedItems() async {
    final savedItemsJson = _prefs?.getString(_keySavedItems);
    if (savedItemsJson != null) {
      try {
        final savedItemsList = jsonDecode(savedItemsJson) as List;
        return savedItemsList
            .map((item) => SavedItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error loading saved items: $e');
        return [];
      }
    }
    return [];
  }

  static Future<void> saveSavedItems(List<SavedItem> items) async {
    try {
      final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
      await _prefs?.setString(_keySavedItems, itemsJson);
    } catch (e) {
      print('Error saving saved items: $e');
    }
  }

  static Future<void> addSavedItem(SavedItem item) async {
    final currentItems = await getSavedItems();

    // Check if item already exists
    final existingIndex = currentItems.indexWhere((i) => i.id == item.id);
    if (existingIndex != -1) {
      return; // Item already saved
    }

    currentItems.add(item);
    await saveSavedItems(currentItems);

    // Update current progress if available
    final current = currentProgress;
    if (current != null && _activeDifficulty != null) {
      final updatedProgress = current.toggleSavedItem(item.id);
      await saveProgressForDifficulty(_activeDifficulty!, updatedProgress);
    }
  }

  static Future<void> removeSavedItem(String itemId) async {
    final currentItems = await getSavedItems();
    currentItems.removeWhere((item) => item.id == itemId);
    await saveSavedItems(currentItems);

    // Update current progress if available
    final current = currentProgress;
    if (current != null && _activeDifficulty != null) {
      final updatedProgress = current.toggleSavedItem(itemId);
      await saveProgressForDifficulty(_activeDifficulty!, updatedProgress);
    }
  }

  static Future<bool> isItemSaved(String itemId) async {
    final savedItems = await getSavedItems();
    return savedItems.any((item) => item.id == itemId);
  }

  // App Settings Management
  static Future<AppSettings> getAppSettings() async {
    final settingsJson = _prefs?.getString(_keySettings);
    if (settingsJson != null) {
      try {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        return AppSettings.fromJson(settingsMap);
      } catch (e) {
        print('Error loading app settings: $e');
        return AppSettings.defaultSettings();
      }
    }
    return AppSettings.defaultSettings();
  }

  static Future<void> saveAppSettings(AppSettings settings) async {
    try {
      final settingsJson = jsonEncode(settings.toJson());
      await _prefs?.setString(_keySettings, settingsJson);
    } catch (e) {
      print('Error saving app settings: $e');
    }
  }

  // Onboarding Management
  static bool isOnboardingCompleted() {
    return _prefs?.getBool(_keyOnboardingCompleted) ?? false;
  }

  static Future<void> setOnboardingCompleted() async {
    await _prefs?.setBool(_keyOnboardingCompleted, true);
  }

  // Sync Management
  static DateTime? getLastSyncTime() {
    final timeString = _prefs?.getString(_keyLastSyncTime);
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  static Future<void> _updateLastSyncTime() async {
    await _prefs?.setString(_keyLastSyncTime, DateTime.now().toIso8601String());
  }

  // Utility Methods
  static Future<void> clearAllData() async {
    await _prefs?.clear();
    _allProgress.clear();
    _activeDifficulty = null;
  }

  static Future<void> resetProgressForDifficulty(
    DifficultyLevel difficulty,
  ) async {
    _allProgress.remove(difficulty);
    await _saveAllProgress();

    // Initialize fresh progress for this difficulty
    await initializeProgressForDifficulty(difficulty);
  }

  // Legacy compatibility
  static DifficultyLevel? getCurrentDifficulty() {
    return _activeDifficulty;
  }

  static bool hasDifficultySet() {
    return _activeDifficulty != null;
  }

  static bool hasValidProgress() {
    return currentProgress != null &&
        currentProgress!.selectedDifficulty != null &&
        currentProgress!.userId.isNotEmpty;
  }

  static bool hasProgressForDifficulty(DifficultyLevel difficulty) {
    return _allProgress.containsKey(difficulty);
  }

  static List<DifficultyLevel> getAvailableDifficulties() {
    return _allProgress.keys.toList();
  }

  // Statistics for current difficulty
  static Future<Map<String, dynamic>> getStatistics() async {
    final current = currentProgress;
    if (current == null) return {};

    final savedItems = await getSavedItems();
    final completedLessons =
        current.lessonProgress.values
            .where((p) => p.status == LessonStatus.completed)
            .length;

    final totalTimeSpent = current.lessonProgress.values.fold<int>(
      0,
      (sum, progress) => sum + progress.timeSpent,
    );

    return {
      'completedLessons': completedLessons,
      'currentDay': current.currentDay,
      'dailyStreak': current.dailyStreak,
      'overallProgress': current.overallProgress,
      'savedItemsCount': savedItems.length,
      'totalTimeSpent': totalTimeSpent,
      'startDate': current.startDate.toIso8601String(),
      'daysSinceStart': DateTime.now().difference(current.startDate).inDays,
      'selectedDifficulty': current.selectedDifficulty.toString(),
    };
  }

  // Statistics for all difficulties
  static Future<Map<String, dynamic>> getAllStatistics() async {
    final allStats = <String, dynamic>{};

    for (final entry in _allProgress.entries) {
      final difficulty = entry.key;
      final progress = entry.value;

      final completedLessons =
          progress.lessonProgress.values
              .where((p) => p.status == LessonStatus.completed)
              .length;

      final totalTimeSpent = progress.lessonProgress.values.fold<int>(
        0,
        (sum, p) => sum + p.timeSpent,
      );

      allStats[difficulty.toString().split('.').last] = {
        'completedLessons': completedLessons,
        'currentDay': progress.currentDay,
        'dailyStreak': progress.dailyStreak,
        'overallProgress': progress.overallProgress,
        'totalTimeSpent': totalTimeSpent,
        'startDate': progress.startDate.toIso8601String(),
        'daysSinceStart': DateTime.now().difference(progress.startDate).inDays,
      };
    }

    final savedItems = await getSavedItems();
    allStats['global'] = {
      'totalDifficulties': _allProgress.length,
      'savedItemsCount': savedItems.length,
      'activeDifficulty': _activeDifficulty?.toString().split('.').last,
    };

    return allStats;
  }

  // Debug helper methods
  static Future<void> debugPrintProgress() async {
    print('=== DEBUG: Multi-Difficulty Progress ===');
    print('Active Difficulty: $_activeDifficulty');
    print(
      'Available Difficulties: ${_allProgress.keys.map((d) => d.toString().split('.').last).join(', ')}',
    );

    for (final entry in _allProgress.entries) {
      final difficulty = entry.key;
      final progress = entry.value;
      print('--- ${difficulty.toString().split('.').last} ---');
      print('  User ID: ${progress.userId}');
      print('  Current Day: ${progress.currentDay}');
      print('  Streak: ${progress.dailyStreak}');
      print('  Overall Progress: ${progress.overallProgress}');
      print('  Start Date: ${progress.startDate}');
      print('  Last Activity: ${progress.lastActivityDate}');
    }
    print('=====================================');
  }

  static void debugPrintSharedPrefs() {
    print('=== DEBUG: SharedPreferences ===');
    print('First Launch: ${_prefs?.getBool(_keyFirstLaunch)}');
    print('Has All Progress: ${_prefs?.containsKey(_keyAllProgress)}');
    print('Active Difficulty: ${_prefs?.getString(_keyActiveDifficulty)}');
    print('Has Saved Items: ${_prefs?.containsKey(_keySavedItems)}');
    print('Onboarding Completed: ${_prefs?.getBool(_keyOnboardingCompleted)}');
    print('===============================');
  }
}

// App Settings Model (unchanged)
class AppSettings {
  final bool notificationsEnabled;
  final bool dailyReminders;
  final TimeOfDay reminderTime;
  final bool darkModeEnabled;
  final String language;
  final bool analyticsEnabled;
  final bool autoPlayVideos;
  final double textScale;

  const AppSettings({
    required this.notificationsEnabled,
    required this.dailyReminders,
    required this.reminderTime,
    required this.darkModeEnabled,
    required this.language,
    required this.analyticsEnabled,
    required this.autoPlayVideos,
    required this.textScale,
  });

  factory AppSettings.defaultSettings() {
    return const AppSettings(
      notificationsEnabled: true,
      dailyReminders: true,
      reminderTime: TimeOfDay(hour: 9, minute: 0),
      darkModeEnabled: true,
      language: 'en',
      analyticsEnabled: true,
      autoPlayVideos: false,
      textScale: 1.0,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      dailyReminders: json['dailyReminders'] ?? true,
      reminderTime: TimeOfDay(
        hour: json['reminderHour'] ?? 9,
        minute: json['reminderMinute'] ?? 0,
      ),
      darkModeEnabled: json['darkModeEnabled'] ?? true,
      language: json['language'] ?? 'en',
      analyticsEnabled: json['analyticsEnabled'] ?? true,
      autoPlayVideos: json['autoPlayVideos'] ?? false,
      textScale: (json['textScale'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'dailyReminders': dailyReminders,
      'reminderHour': reminderTime.hour,
      'reminderMinute': reminderTime.minute,
      'darkModeEnabled': darkModeEnabled,
      'language': language,
      'analyticsEnabled': analyticsEnabled,
      'autoPlayVideos': autoPlayVideos,
      'textScale': textScale,
    };
  }

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? dailyReminders,
    TimeOfDay? reminderTime,
    bool? darkModeEnabled,
    String? language,
    bool? analyticsEnabled,
    bool? autoPlayVideos,
    double? textScale,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      reminderTime: reminderTime ?? this.reminderTime,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      autoPlayVideos: autoPlayVideos ?? this.autoPlayVideos,
      textScale: textScale ?? this.textScale,
    );
  }
}
