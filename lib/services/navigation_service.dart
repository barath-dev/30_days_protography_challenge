import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photography_guide/presentation/difficulty_selection_screen.dart';
import 'package:photography_guide/presentation/home_screen.dart';
import 'package:photography_guide/presentation/lesson_detail_screen.dart';
import 'package:photography_guide/presentation/lesson_timeline_screen.dart';
import 'package:photography_guide/presentation/saved_items_screen.dart';
import '../models/lesson.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;
  static BuildContext? get context => navigatorKey.currentContext;

  // Route names
  static const String home = '/';
  static const String difficultySelection = '/difficulty-selection';
  static const String savedItems = '/saved-items';
  static const String lessonDetail = '/lesson-detail';
  static const String lessonTimeline = '/lesson-timeline';
  static const String onboarding = '/onboarding';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String achievements = '/achievements';
  static const String statistics = '/statistics';

  // Navigation methods
  static Future<T?> push<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    HapticFeedback.lightImpact();
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    HapticFeedback.lightImpact();
    return navigator!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    HapticFeedback.mediumImpact();
    return navigator!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    HapticFeedback.lightImpact();
    navigator!.pop<T>(result);
  }

  static void popUntil(String routeName) {
    navigator!.popUntil(ModalRoute.withName(routeName));
  }

  static bool canPop() {
    return navigator!.canPop();
  }

  // Specific navigation methods
  static Future<void> toHome({bool clearStack = false}) {
    if (clearStack) {
      return pushAndRemoveUntil(home, (route) => false);
    }
    return push(home);
  }

  static Future<void> toDifficultySelection() {
    return push(difficultySelection);
  }

  static Future<void> toSavedItems() {
    return push(savedItems);
  }

  static Future<void> toLessonTimeline() {
    return push(lessonTimeline);
  }

  static Future<void> toLessonDetail({Lesson? lesson, String? lessonId}) {
    return push(
      lessonDetail,
      arguments: {'lesson': lesson, 'lessonId': lessonId},
    );
  }

  static Future<void> toSettings() {
    return push(settings);
  }

  static Future<void> toProfile() {
    return push(profile);
  }

  static Future<void> toAchievements() {
    return push(achievements);
  }

  static Future<void> toStatistics() {
    return push(statistics);
  }

  // Modal navigation methods
  static Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
  }) {
    return showModalBottomSheet<T>(
      context: context!,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => child,
    );
  }

  static Future<T?> showDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showAdaptiveDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (context) => child,
    );
  }

  // Custom page route generators
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildRoute(const HomeScreen(), settings);

      case difficultySelection:
        return _buildRoute(const DifficultySelectionScreen(), settings);

      case savedItems:
        return _buildRoute(const SavedItemsScreen(), settings);

      case lessonTimeline:
        return _buildRoute(const LessonTimelineScreen(), settings);

      case lessonDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          LessonDetailScreen(
            lesson: args?['lesson'],
            lessonId: args?['lessonId'],
          ),
          settings,
        );

      // Add other routes here as they're created
      // case settings:
      //   return _buildRoute(const SettingsScreen(), settings);

      default:
        return _buildRoute(_buildNotFoundScreen(), settings);
    }
  }

  static PageRoute<T> _buildRoute<T>(Widget child, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(animation, child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Widget _buildTransition(Animation<double> animation, Widget child) {
    // Slide transition from right
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(position: animation.drive(tween), child: child);
  }

  static Widget _buildNotFoundScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: const Color(0xFF0D0D0D),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Color(0xFF888888)),
            SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The page you\'re looking for doesn\'t exist.',
              style: TextStyle(color: Color(0xFF888888), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// Navigation observer for tracking route changes
class AppNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('PUSH', route.settings.name);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('POP', route.settings.name);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logNavigation('REPLACE', newRoute?.settings.name);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _logNavigation('REMOVE', route.settings.name);
  }

  void _logNavigation(String action, String? routeName) {
    if (routeName != null) {
      debugPrint('🧭 Navigation: $action -> $routeName');
    }
  }
}

// Custom route animations
class AppRouteAnimations {
  static Route<T> slideFromRight<T extends Object?>(
    Widget child,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  static Route<T> slideFromBottom<T extends Object?>(
    Widget child,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  static Route<T> fadeTransition<T extends Object?>(
    Widget child,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Route<T> scaleTransition<T extends Object?>(
    Widget child,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return ScaleTransition(scale: curvedAnimation, child: child);
      },
    );
  }
}

// Navigation helpers
class NavigationHelpers {
  static Future<bool> showExitConfirmation() async {
    final context = NavigationService.context;
    if (context == null) return false;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Exit App',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to exit the app?',
              style: TextStyle(color: Color(0xFF888888)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF888888)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  static Future<bool> showLessonExitConfirmation() async {
    final context = NavigationService.context;
    if (context == null) return false;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Exit Lesson',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Your progress will be saved. Are you sure you want to exit this lesson?',
              style: TextStyle(color: Color(0xFF888888)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Continue Learning',
                  style: TextStyle(color: Color(0xFF888888)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  static void handleDeepLink(String link) {
    // Parse deep link and navigate accordingly
    final uri = Uri.parse(link);
    final path = uri.path;

    switch (path) {
      case '/lesson':
        final lessonId = uri.queryParameters['id'];
        if (lessonId != null) {
          NavigationService.toLessonDetail(lessonId: lessonId);
        }
        break;

      case '/timeline':
        NavigationService.toLessonTimeline();
        break;

      case '/saved':
        NavigationService.toSavedItems();
        break;

      default:
        NavigationService.toHome();
        break;
    }
  }
}

// Back button handler
class BackButtonHandler extends StatelessWidget {
  final Widget child;
  final Future<bool> Function()? onBackPressed;

  const BackButtonHandler({super.key, required this.child, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:
          onBackPressed ??
          () async {
            return await NavigationHelpers.showExitConfirmation();
          },
      child: child,
    );
  }
}
