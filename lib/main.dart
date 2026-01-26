import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photography_guide/services/user_preferences.dart';
import 'package:photography_guide/services/lesson_manager.dart';
import 'package:photography_guide/services/navigation_service.dart';
import 'package:photography_guide/utils/app_theme.dart';
import 'package:photography_guide/utils/constants.dart';
import 'package:photography_guide/presentation/home/home_screen.dart';
import 'package:photography_guide/presentation/onboarding/difficulty_selection_screen.dart';
import 'package:photography_guide/presentation/common/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await _initializeApp();

  runApp(const PhotographyGuideApp());
}

Future<void> _initializeApp() async {
  try {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppConstants.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize core services
    print('🔧 Initializing UserPreferences...');
    await UserPreferences.init();

    print('🔧 Initializing LessonManager...');
    await LessonManager.init();

    // Debug print current state
    await UserPreferences.debugPrintProgress();

    print('✅ App initialization completed successfully');
  } catch (e) {
    print('❌ Error during app initialization: $e');
    // Continue with app launch even if initialization fails
  }
}

class PhotographyGuideApp extends StatelessWidget {
  const PhotographyGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: UserPreferences.settingsNotifier,
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Learn photography in 30days',
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          navigatorObservers: [AppNavigationObserver()],
          onGenerateRoute: NavigationService.generateRoute,
          themeMode:
              settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(settings.textScale)),
              child: child!,
            );
          },
          home: const AppInitializer(),
        );
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    try {
      // Ensure all services are initialized
      await UserPreferences.forceReload();

      // Small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      // Determine which screen to show
      Widget initialScreen;

      if (UserPreferences.isFirstLaunch()) {
        // First time user - go to difficulty selection
        initialScreen = const DifficultySelectionScreen();
      } else if (!UserPreferences.hasDifficultySet()) {
        // User has launched before but no difficulty set - go to difficulty selection
        initialScreen = const DifficultySelectionScreen();
      } else {
        // Existing user with difficulty set - go to home
        initialScreen = const HomeScreen();
      }

      // Navigate to determined screen
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => initialScreen));
    } catch (e) {
      print('Error determining initial route: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorScreen();
    }

    return _buildLoadingScreen();
  }

  Widget _buildLoadingScreen() {
    return const LoadingScreen();
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),

              const SizedBox(height: 24),

              const Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'We encountered an error while starting the app. Please try again.',
                style: const TextStyle(
                  color: AppConstants.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppConstants.borderColor),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isLoading = true;
                  });
                  _determineInitialRoute();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class for app lifecycle management
class AppLifecycleManager extends WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.inactive:
        // App is inactive, no action needed
        break;
      case AppLifecycleState.hidden:
        // App is hidden, no action needed
        break;
    }
  }

  void _onAppResumed() {
    print('📱 App resumed');
    // Unlock today's lesson for active difficulty when app resumes
    _unlockTodaysLessonIfNeeded();
  }

  void _onAppPaused() {
    print('📱 App paused');
    // Save any pending changes
    // This is handled automatically by SharedPreferences
  }

  void _onAppDetached() {
    print('📱 App detached');
  }

  Future<void> _unlockTodaysLessonIfNeeded() async {
    try {
      final activeDifficulty = UserPreferences.activeDifficulty;
      if (activeDifficulty != null) {
        // Update streak and unlock today's lesson
        await UserPreferences.updateStreak();
        await LessonManager.unlockTodaysLesson(activeDifficulty);
      }
    } catch (e) {
      print('Error unlocking today\'s lesson: $e');
    }
  }
}

// Global error handler
void setupGlobalErrorHandler() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (AppConfig.enableDebugMode) {
      FlutterError.presentError(details);
    }

    // Log error for analytics/crash reporting
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };
}

// Performance monitoring
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};

  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  static void stopTimer(String name) {
    final timer = _timers[name];
    if (timer != null) {
      timer.stop();
      print('⏱️ $name took ${timer.elapsedMilliseconds}ms');
      _timers.remove(name);
    }
  }

  static void logMemoryUsage() {
    // In a real app, you'd use proper memory monitoring tools
    print('📊 Memory monitoring would be implemented here');
  }
}
