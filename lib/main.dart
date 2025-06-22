import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photography_guide/presentation/difficulty_selection_screen.dart';
import 'package:photography_guide/presentation/home_screen.dart';
import 'services/user_preferences.dart';
import 'services/lesson_manager.dart';
import 'services/navigation_service.dart';
import 'utils/app_theme.dart';
import 'utils/error_handler.dart';
import 'widgets/common_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup global error handling
  setupGlobalErrorHandling();

  // Set system UI overlay style
  AppTheme.setSystemUIOverlayStyle();
  AppTheme.setPreferredOrientations();

  // Initialize services
  await _initializeServices();

  runApp(const PhotographyLearningApp());
}

Future<void> _initializeServices() async {
  try {
    await UserPreferences.init();
    await LessonManager.init();
  } catch (e, stackTrace) {
    ErrorHandler.handleError(e, stackTrace: stackTrace, showSnackbar: false);
  }
}

class PhotographyLearningApp extends StatelessWidget {
  const PhotographyLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photography Learning',
      theme: AppTheme.darkTheme,
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: NavigationService.generateRoute,
      navigatorObservers: [AppNavigationObserver()],
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ErrorBoundary(child: child ?? const SizedBox.shrink());
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
  bool _isFirstLaunch = true;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check if this is the first launch
      final isFirstLaunch = UserPreferences.isFirstLaunch();

      setState(() {
        _isFirstLaunch = isFirstLaunch;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace: stackTrace, showSnackbar: false);

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize app. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoadingScreen();
    }

    if (_errorMessage != null) {
      return AppErrorScreen(message: _errorMessage!, onRetry: _initializeApp);
    }

    if (_isFirstLaunch) {
      return const DifficultySelectionScreen();
    }

    return BackButtonHandler(child: const HomeScreen());
  }
}

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF6B35), width: 2),
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF6B35).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 48,
                color: Color(0xFFFF6B35),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Photography Learning',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Master photography in 30 days',
              style: TextStyle(color: Color(0xFF888888), fontSize: 16),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading...',
              style: TextStyle(color: Color(0xFF888888), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class AppErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AppErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFF44336),
              ),
              const SizedBox(height: 24),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: Color(0xFF888888), fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Try Again',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
