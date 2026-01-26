import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Photography Learning';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Master photography in 30 days';

  // Course Configuration
  static const int totalCourseDays = 30;
  static const int minDailyLessonTime = 15; // minutes
  static const int maxDailyLessonTime = 45; // minutes
  static const double minReadingProgressForCompletion = 0.8; // 80%
  // Flag to toggle unrestricted access to all lessons (bypass daily unlock)
  static const bool isUnrestrictedMode = true;
  static const bool allowAdvanceAccess = true; // Can't skip ahead
  static const int maxLessonsPerDay =
      1; // Maximum lessons that can be accessed per day
  static const Duration dailyLessonUnlockTime = Duration(hours: 0); // Midnight
  static const int maxSavedItems = 100;
  static const int maxRecentActivity = 10;

  // Design Constants
  static const Color primaryColor = Color(0xFFFF6B35);
  static const Color backgroundColor = Color(0xFF0D0D0D);
  static const Color cardColor = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF888888);
  static const Color borderColor = Color(0xFF333333);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  static const Color lightBackgroundColor = Color(0xFFF2F2F7);
  static const Color lightBorderColor = Color(0xFFE5E5EA);
  static const Color lightTextSecondary = Color(0xFF8E8E93);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFFF6B35),
    Color(0xFFFF8A50),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF2D2D2D),
    Color(0xFF1A1A1A),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFF1A1A1A),
    Color(0xFF0D0D0D),
  ];

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 400);

  // Layout Constants
  static const double defaultPadding = 20.0;
  static const double mediumPadding = 16.0;
  static const double contentPadding = 12.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 32.0;
  static const double defaultBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 24.0;
  static const double cardBorderRadius = 16.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeDefault = 24.0;
  static const double iconSizeLarge = 28.0;

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: Colors.white,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    color: textSecondary,
    fontWeight: FontWeight.w600,
  );

  // SharedPreferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyUserProgress = 'user_progress';
  static const String keySavedItems = 'saved_items';
  static const String keyAppSettings = 'app_settings';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyNotificationSettings = 'notification_settings';

  // Lesson Categories
  static const List<String> lessonCategories = [
    'Fundamentals',
    'Composition',
    'Lighting',
    'Technical',
    'Portraits',
    'Landscape',
    'Street',
    'Wildlife',
    'Macro',
    'Night',
    'Editing',
    'Business',
  ];

  // Photography Tips Categories
  static const Map<String, String> tipCategories = {
    'basics': 'Camera Basics',
    'composition': 'Composition',
    'lighting': 'Lighting',
    'editing': 'Photo Editing',
    'gear': 'Equipment',
    'techniques': 'Techniques',
    'inspiration': 'Inspiration',
  };

  // Achievement Types
  static const Map<String, String> achievementTypes = {
    'first_lesson': 'First Lesson Complete',
    'week_complete': 'Week Complete',
    'streak_7': '7-Day Streak',
    'streak_14': '14-Day Streak',
    'streak_30': '30-Day Streak',
    'all_theory': 'Theory Master',
    'all_practice': 'Practice Pro',
    'course_complete': 'Course Graduate',
    'first_save': 'First Bookmark',
    'curator': 'Content Curator',
    'speed_reader': 'Speed Learner',
  };

  // Default Settings
  static const Map<String, dynamic> defaultSettings = {
    'notifications_enabled': true,
    'daily_reminders': true,
    'reminder_hour': 9,
    'reminder_minute': 0,
    'dark_mode': true,
    'language': 'en',
    'analytics_enabled': true,
    'auto_play_videos': false,
    'text_scale': 1.0,
    'offline_mode': false,
  };

  // API Configuration (for future use)
  static const String baseUrl = 'https://api.photographylearning.com';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableOfflineMode = true;
  static const bool enableSocialSharing = false;
  static const bool enableInAppPurchases = false;
  static const bool enablePushNotifications = true;

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxBioLength = 200;
  static const int maxCommentLength = 500;

  // Image Constraints
  static const int maxImageSizeMB = 10;
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Notification Channels
  static const String reminderChannelId = 'daily_reminders';
  static const String progressChannelId = 'progress_updates';
  static const String achievementChannelId = 'achievements';

  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Please check your internet connection',
    'server_error': 'Server is temporarily unavailable',
    'validation_error': 'Please check your input',
    'permission_denied': 'Permission denied',
    'file_not_found': 'File not found',
    'storage_full': 'Not enough storage space',
    'unknown_error': 'An unexpected error occurred',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'lesson_completed': 'Lesson completed successfully!',
    'progress_saved': 'Progress saved',
    'item_bookmarked': 'Added to bookmarks',
    'item_removed': 'Removed from bookmarks',
    'settings_updated': 'Settings updated',
    'data_synced': 'Data synchronized',
  };

  // Helper Methods
  static BoxDecoration get cardDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: cardGradient,
    ),
    borderRadius: BorderRadius.circular(cardBorderRadius),
    border: Border.all(color: borderColor, width: 1),
  );

  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(defaultBorderRadius),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get secondaryButtonDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(defaultBorderRadius),
    border: Border.all(color: borderColor, width: 1),
  );

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Device Types
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  // Safe Area Padding
  static EdgeInsets screenPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      left: defaultPadding,
      right: defaultPadding,
      top: mediaQuery.padding.top + defaultPadding,
      bottom: mediaQuery.padding.bottom + defaultPadding,
    );
  }
}

// Extension for easy access to theme colors
extension AppColorsExtension on BuildContext {
  Color get primaryColor => AppConstants.primaryColor;
  Color get backgroundColor => AppConstants.backgroundColor;
  Color get cardColor => AppConstants.cardColor;
  Color get textSecondary => AppConstants.textSecondary;
  Color get borderColor => AppConstants.borderColor;
  Color get successColor => AppConstants.successColor;
  Color get warningColor => AppConstants.warningColor;
  Color get errorColor => AppConstants.errorColor;
}

// Extension for easy access to text styles
extension AppTextStylesExtension on BuildContext {
  TextStyle get headingLarge => AppConstants.headingLarge;
  TextStyle get headingMedium => AppConstants.headingMedium;
  TextStyle get headingSmall => AppConstants.headingSmall;
  TextStyle get bodyLarge => AppConstants.bodyLarge;
  TextStyle get bodyMedium => AppConstants.bodyMedium;
  TextStyle get bodySmall => AppConstants.bodySmall;
  TextStyle get caption => AppConstants.caption;
}

// App Configuration Class
class AppConfig {
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static const bool isProduction = environment == 'production';
  static const bool isDevelopment = environment == 'development';
  static const bool isStaging = environment == 'staging';

  // Debug Settings
  static const bool enableLogging = !isProduction;
  static const bool enableDebugMode = isDevelopment;
  static const bool enablePerformanceOverlay = false;

  // Feature Toggles
  static const bool enableNewFeatures = isDevelopment || isStaging;
  static const bool enableBetaFeatures = isDevelopment;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;
}
