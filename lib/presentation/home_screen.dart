import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/lesson.dart';
import '../models/user_progress.dart';
import '../services/user_preferences.dart';
import '../services/lesson_manager.dart';
import '../main.dart';
import 'saved_items_screen.dart';
import 'lesson_timeline_screen.dart';
import 'lesson_detail_screen.dart';
import 'difficulty_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedLevel = 'Beginner';
  int selectedCategoryIndex = 1;
  late ScrollController _categoryController;
  UserProgress? _userProgress;
  Lesson? _currentLesson;
  bool _isLoading = true;

  // Constants for better maintainability
  static const Color _primaryColor = Color(0xFFFF6B35);
  static const Color _backgroundColor = Color(0xFF0D0D0D);
  static const Color _cardColor = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF888888);
  static const Color _borderColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _categoryController = ScrollController(
      initialScrollOffset: selectedCategoryIndex * 80.0,
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Update streak when opening the app
      await UserPreferences.updateStreak();

      // Unlock today's lesson if available
      await LessonManager.unlockTodaysLesson();

      // Load user progress
      _userProgress = UserPreferences.currentProgress;

      // Get current lesson (today's available lesson)
      _currentLesson = LessonManager.getCurrentLesson();

      // Update selected level based on user progress
      if (_userProgress != null) {
        selectedLevel = _getDifficultyDisplayName(
          _userProgress!.selectedDifficulty,
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getDifficultyDisplayName(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          color: _primaryColor,
          backgroundColor: _cardColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildWelcomeSection(),
                const SizedBox(height: 30),
                _buildEducationalArticlesSection(),
                const SizedBox(height: 30),
                _buildProgressCard(),
                const SizedBox(height: 30),
                _buildSkillLevelSelector(),
                const SizedBox(height: 30),
                _buildTodaysLesson(),
                const SizedBox(height: 30),
                _buildQuickActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeaderButton(Icons.menu, () {
          // TODO: Open drawer/menu
        }),
        _buildHeaderButton(Icons.notifications_outlined, () {
          // TODO: Open notifications
        }),
      ],
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final greeting = _getGreeting();
    final streakDays = _userProgress?.dailyStreak ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            color: _textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ready for today\'s\nphotography lesson?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        _buildStreakCard(streakDays),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  Widget _buildStreakCard(int streakDays) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Streak',
                  style: TextStyle(color: _textSecondary, fontSize: 14),
                ),
                Text(
                  '$streakDays Days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.local_fire_department, color: _primaryColor, size: 28),
        ],
      ),
    );
  }

  Widget _buildEducationalArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '★★★',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Free selection of\neducational articles.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Most complicated topics simplified with our guides...',
          style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 24),
        _buildCategorySelector(),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'icon': Icons.article_outlined, 'label': 'Photojournalism'},
      {'icon': Icons.camera_alt, 'label': 'Vintage'},
      {'icon': Icons.add, 'label': 'Still Life'},
      {'icon': Icons.pets, 'label': 'Wildlife'},
      {'icon': Icons.face, 'label': 'Fashion'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification) {
                  _snapToNearestCategory();
                }
                return false;
              },
              child: ListView.builder(
                controller: _categoryController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length + 4,
                itemBuilder: (context, index) {
                  if (index < 2 || index >= categories.length + 2) {
                    return const SizedBox(width: 70);
                  }

                  final categoryIndex = index - 2;
                  final category = categories[categoryIndex];
                  final isSelected = categoryIndex == selectedCategoryIndex;

                  return GestureDetector(
                    onTap: () => _scrollToCategory(categoryIndex),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Center(
                        child: AnimatedScale(
                          scale: isSelected ? 1.2 : 0.8,
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedOpacity(
                            opacity: isSelected ? 1.0 : 0.4,
                            duration: const Duration(milliseconds: 200),
                            child: _buildCategoryIcon(
                              category['icon'] as IconData,
                              isSelected,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(categories.length, (index) {
              final isSelected = index == selectedCategoryIndex;
              return GestureDetector(
                onTap: () => _scrollToCategory(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 20 : 6,
                  height: 2,
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : _borderColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              categories[selectedCategoryIndex]['label'] as String,
              key: ValueKey(selectedCategoryIndex),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? _borderColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _borderColor : Colors.transparent,
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : _textSecondary,
        size: 20,
      ),
    );
  }

  void _scrollToCategory(int index) {
    final targetOffset = index * 80.0;
    _categoryController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => selectedCategoryIndex = index);
    HapticFeedback.lightImpact();
  }

  void _snapToNearestCategory() {
    const itemWidth = 80.0;
    final currentOffset = _categoryController.offset;
    final nearestIndex = (currentOffset / itemWidth).round().clamp(0, 4);

    if (nearestIndex != selectedCategoryIndex) {
      _scrollToCategory(nearestIndex);
    }
  }

  Widget _buildProgressCard() {
    final currentDay = _userProgress?.currentDay ?? 1;
    final progressPercentage = _userProgress?.overallProgress ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '30-Day Challenge',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Day $currentDay/30',
                style: TextStyle(color: _textSecondary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: _borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(
            '${(progressPercentage * 100).round()}% Complete',
            style: TextStyle(color: _textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillLevelSelector() {
    const levels = ['Beginner', 'Intermediate', 'Advanced'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Learning Track',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DifficultySelectionScreen(),
                  ),
                );
              },
              child: Icon(Icons.edit, color: _primaryColor, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children:
              levels
                  .map((level) => Expanded(child: _buildLevelButton(level)))
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildLevelButton(String level) {
    final isSelected = level == selectedLevel;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isSelected ? _primaryColor : _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _primaryColor : _borderColor,
          width: 1,
        ),
      ),
      child: Text(
        level,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : _textSecondary,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTodaysLesson() {
    if (_currentLesson == null) {
      return _buildNoLessonCard();
    }

    final progress =
        _userProgress?.getLessonProgress(_currentLesson!.id) ?? 0.0;
    final canAccess =
        _userProgress?.isDayUnlocked(_currentLesson!.day) ?? false;
    final timeUntilUnlock = LessonManager.getTimeUntilNextLesson();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Lesson',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap:
              canAccess
                  ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => LessonDetailScreen(lesson: _currentLesson),
                      ),
                    );
                  }
                  : null,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration().copyWith(
              border: Border.all(
                color:
                    canAccess ? _primaryColor.withOpacity(0.5) : _borderColor,
                width: canAccess ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLessonHeader(),
                const SizedBox(height: 12),
                Text(
                  _currentLesson!.title,
                  style: TextStyle(
                    color: canAccess ? Colors.white : _textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentLesson!.description,
                  style: TextStyle(
                    color:
                        canAccess
                            ? _textSecondary
                            : _textSecondary.withOpacity(0.6),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Show different content based on access
                if (!canAccess) ...[
                  _buildLockIndicator(timeUntilUnlock),
                ] else if (progress > 0) ...[
                  _buildLessonProgress(progress),
                  const SizedBox(height: 16),
                ],

                _buildLessonMetadata(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockIndicator(String timeUntilUnlock) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _borderColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: _textSecondary, size: 16),
          const SizedBox(width: 8),
          Text(
            'Available: $timeUntilUnlock',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLessonCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(Icons.celebration, color: _primaryColor, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Congratulations!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ve completed the 30-day photography course!',
            style: TextStyle(color: _textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.play_circle_filled, color: _primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          'Day ${_currentLesson!.day}',
          style: TextStyle(
            color: _primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLessonProgress(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(color: _textSecondary, fontSize: 12),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: _borderColor,
          valueColor: AlwaysStoppedAnimation(_primaryColor),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget _buildLessonMetadata() {
    return Row(
      children: [
        _buildMetadataItem(
          Icons.access_time,
          '${_currentLesson!.estimatedDuration} min',
        ),
        const SizedBox(width: 16),
        _buildMetadataItem(Icons.assignment, 'Practice included'),
      ],
    );
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: _textSecondary, size: 16),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: _textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.timeline,
                title: 'Lesson Timeline',
                subtitle: 'View all lessons',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LessonTimelineScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.bookmark_outline,
                title: 'Saved Items',
                subtitle: 'Your bookmarks',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedItemsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _primaryColor, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: _textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _borderColor, width: 1),
    );
  }
}
