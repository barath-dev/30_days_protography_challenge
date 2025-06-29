import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:photography_guide/models/lesson.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/saved_item.dart';

class UserPreferences {
  static SharedPreferences? _prefs;
  static UserProgress? _currentProgress;

  // Keys for SharedPreferences
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyUserProgress = 'user_progress';
  static const String _keySavedItems = 'saved_items';
  static const String _keySettings = 'app_settings';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyLastSyncTime = 'last_sync_time';

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUserProgress();
  }

  // First launch management
  static bool isFirstLaunch() {
    return _prefs?.getBool(_keyFirstLaunch) ?? true;
  }

  static Future<void> setFirstLaunchCompleted() async {
    await _prefs?.setBool(_keyFirstLaunch, false);
  }

  // User Progress Management
  static UserProgress? get currentProgress => _currentProgress;

  static Future<void> _loadUserProgress() async {
    final progressJson = _prefs?.getString(_keyUserProgress);
    if (progressJson != null) {
      try {
        final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
        _currentProgress = UserProgress.fromJson(progressMap);
      } catch (e) {
        print('Error loading user progress: $e');
        _currentProgress = null;
      }
    }
  }

  static Future<void> saveUserProgress(UserProgress progress) async {
    try {
      _currentProgress = progress;
      final progressJson = jsonEncode(progress.toJson());
      await _prefs?.setString(_keyUserProgress, progressJson);
      await _updateLastSyncTime();
    } catch (e) {
      print('Error saving user progress: $e');
    }
  }

  static Future<void> initializeUserProgress(DifficultyLevel difficulty) async {
    final progress = UserProgress.initial(difficulty);
    await saveUserProgress(progress);
    await setFirstLaunchCompleted();
  }

  // New method to reset progress when difficulty changes
  static Future<void> resetProgressForNewDifficulty(
    DifficultyLevel newDifficulty,
  ) async {
    try {
      // Create fresh progress with the new difficulty
      final freshProgress = UserProgress.initial(newDifficulty);
      await saveUserProgress(freshProgress);

      // Clear saved items as they might be specific to the old difficulty
      await _prefs?.remove(_keySavedItems);

      print('Progress reset for new difficulty: ${newDifficulty.toString()}');
    } catch (e) {
      print('Error resetting progress for new difficulty: $e');
      rethrow;
    }
  }

  static Future<void> updateLessonProgress(
    String lessonId,
    LessonProgress lessonProgress,
  ) async {
    if (_currentProgress != null) {
      final updatedProgress = Map<String, LessonProgress>.from(
        _currentProgress!.lessonProgress,
      );
      updatedProgress[lessonId] = lessonProgress;

      final newUserProgress = _currentProgress!.copyWith(
        lessonProgress: updatedProgress,
        lastActivityDate: DateTime.now(),
      );

      await saveUserProgress(newUserProgress);
    }
  }

  static Future<void> markLessonCompleted(
    String lessonId,
    int progressDay, // Changed from lessonDay to progressDay
  ) async {
    if (_currentProgress != null) {
      final updatedProgress = _currentProgress!.markLessonCompleted(
        lessonId,
        progressDay, // Now uses progress day (1-30) instead of actual lesson day
      );
      await saveUserProgress(updatedProgress);
    }
  }

  static Future<void> updateStreak() async {
    if (_currentProgress != null) {
      final updatedProgress = _currentProgress!.updateStreak();
      await saveUserProgress(updatedProgress);
    }
  }

  static Future<void> updateCurrentDay(int newDay) async {
    if (_currentProgress != null) {
      final updatedProgress = _currentProgress!.copyWith(
        currentDay: newDay,
        lastActivityDate: DateTime.now(),
      );
      await saveUserProgress(updatedProgress);
    }
  }

  // Saved Items Management
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

    // Update user progress if needed
    if (_currentProgress != null) {
      final updatedProgress = _currentProgress!.toggleSavedItem(item.id);
      await saveUserProgress(updatedProgress);
    }
  }

  static Future<void> removeSavedItem(String itemId) async {
    final currentItems = await getSavedItems();
    currentItems.removeWhere((item) => item.id == itemId);
    await saveSavedItems(currentItems);

    // Update user progress if needed
    if (_currentProgress != null) {
      final updatedProgress = _currentProgress!.toggleSavedItem(itemId);
      await saveUserProgress(updatedProgress);
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
    _currentProgress = null;
  }

  static Future<void> resetProgress() async {
    await _prefs?.remove(_keyUserProgress);
    await _prefs?.remove(_keySavedItems);
    await _prefs?.setBool(_keyFirstLaunch, true);
    _currentProgress = null;
  }

  // Get current user's difficulty level
  static DifficultyLevel? getCurrentDifficulty() {
    return _currentProgress?.selectedDifficulty;
  }

  // Check if difficulty has been set
  static bool hasDifficultySet() {
    return _currentProgress?.selectedDifficulty != null;
  }

  // Statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    if (_currentProgress == null) return {};

    final savedItems = await getSavedItems();
    final completedLessons =
        _currentProgress!.lessonProgress.values
            .where((p) => p.status == LessonStatus.completed)
            .length;

    final totalTimeSpent = _currentProgress!.lessonProgress.values.fold<int>(
      0,
      (sum, progress) => sum + progress.timeSpent,
    );

    return {
      'completedLessons': completedLessons,
      'currentDay': _currentProgress!.currentDay,
      'dailyStreak': _currentProgress!.dailyStreak,
      'overallProgress': _currentProgress!.overallProgress,
      'savedItemsCount': savedItems.length,
      'totalTimeSpent': totalTimeSpent,
      'startDate': _currentProgress!.startDate.toIso8601String(),
      'daysSinceStart':
          DateTime.now().difference(_currentProgress!.startDate).inDays,
      'selectedDifficulty': _currentProgress!.selectedDifficulty.toString(),
    };
  }
}

// App Settings Model
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
