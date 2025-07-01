import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/saved_item.dart';
import '../../services/user_preferences.dart';
import '../../services/lesson_manager.dart';
import 'lesson_detail_screen.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  String searchQuery = '';
  int selectedTab = 0;
  List<SavedItem> _savedItems = [];
  bool _isLoading = true;
  SortOption _currentSort = SortOption.recentlySaved;

  // Enhanced design constants matching the lesson detail screen
  static const Color _primaryColor = Color(0xFFFF6B35);
  static const Color _secondaryColor = Color(0xFFFFB800);
  static const Color _backgroundColor = Color(0xFF0B0B0B);
  static const Color _surfaceColor = Color(0xFF1C1C1E);
  static const Color _cardColor = Color(0xFF2C2C2E);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFAAAAAA);
  static const Color _textTertiary = Color(0xFF666666);
  static const Color _borderColor = Color(0xFF3C3C3E);
  static const Color _successColor = Color(0xFF30D158);

  final List<String> _tabs = [
    'All',
    'Lessons',
    'Tips',
    'Articles',
    'Reference',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadSavedItems();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedItems() async {
    setState(() => _isLoading = true);

    try {
      final items = await UserPreferences.getSavedItems();
      setState(() {
        _savedItems = items;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('Error loading saved items: $e');
      setState(() => _isLoading = false);
    }
  }

  List<SavedItem> get filteredItems {
    List<SavedItem> items = List.from(_savedItems);

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      items =
          items
              .where(
                (item) =>
                    item.title.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    item.description.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    item.category.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Filter by tab
    if (selectedTab > 0) {
      final type = SavedItemType.values[selectedTab - 1];
      items = items.where((item) => item.type == type).toList();
    }

    // Sort items
    _sortItems(items);
    return items;
  }

  void _sortItems(List<SavedItem> items) {
    switch (_currentSort) {
      case SortOption.recentlySaved:
        items.sort((a, b) => b.savedDate.compareTo(a.savedDate));
        break;
      case SortOption.alphabetical:
        items.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.type:
        items.sort((a, b) => a.type.index.compareTo(b.type.index));
        break;
      case SortOption.category:
        items.sort((a, b) => a.category.compareTo(b.category));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: _textPrimary,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Saved Items',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${_savedItems.length} items saved',
                  style: TextStyle(color: _textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showSortOptions,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor),
              ),
              child: Icon(Icons.sort_rounded, color: _textPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: _textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: TextStyle(color: _textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search saved items...',
                  hintStyle: TextStyle(color: _textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            if (searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    searchQuery = '';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: _textSecondary,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = selectedTab == index;
                final count = _getTabCount(index);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTab = index;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient:
                          isSelected
                              ? LinearGradient(
                                colors: [_primaryColor, _secondaryColor],
                              )
                              : null,
                      color: isSelected ? null : _surfaceColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : _borderColor,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tab,
                          style: TextStyle(
                            color: isSelected ? Colors.white : _textSecondary,
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : _primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  int _getTabCount(int tabIndex) {
    if (tabIndex == 0) return _savedItems.length;
    final type = SavedItemType.values[tabIndex - 1];
    return _savedItems.where((item) => item.type == type).length;
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading saved items...',
              style: TextStyle(color: _textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final items = filteredItems;

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadSavedItems,
      color: _primaryColor,
      backgroundColor: _surfaceColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final delay = index * 0.1;

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final animation = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(delay, (delay + 0.3).clamp(0, 1)),
                ),
              );

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: _buildSavedItemCard(item),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSavedItemCard(SavedItem item) {
    return GestureDetector(
      onTap: () => _openItem(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getTypeColor(item.type),
                        _getTypeColor(item.type).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getTypeIcon(item.type),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(item.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getTypeColor(item.type).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _getTypeName(item.type).toUpperCase(),
                          style: TextStyle(
                            color: _getTypeColor(item.type),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _removeSavedItem(item),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.bookmark_rounded,
                      color: _primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              item.description,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Progress bar for lessons
            if (item.progress != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primaryColor.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: _primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Progress',
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(item.progress! * 100).round()}%',
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: item.progress,
                      backgroundColor: _borderColor,
                      valueColor: AlwaysStoppedAnimation(_primaryColor),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Footer info
            Row(
              children: [
                Icon(Icons.folder_rounded, color: _textTertiary, size: 16),
                const SizedBox(width: 6),
                Text(
                  item.category,
                  style: TextStyle(
                    color: _textTertiary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.duration != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.schedule_rounded, color: _textTertiary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${item.duration} min',
                    style: TextStyle(
                      color: _textTertiary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  _formatDate(item.savedDate),
                  style: TextStyle(
                    color: _textTertiary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryColor.withOpacity(0.1),
                  _secondaryColor.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _primaryColor.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.bookmark_outline_rounded,
              color: _primaryColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            searchQuery.isNotEmpty ? 'No Results Found' : 'No Saved Items',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Start bookmarking lessons and tips\nto see them here',
            style: TextStyle(color: _textSecondary, fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (searchQuery.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  searchQuery = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Clear Search',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(SavedItemType type) {
    switch (type) {
      case SavedItemType.lesson:
        return _primaryColor;
      case SavedItemType.tip:
        return _successColor;
      case SavedItemType.article:
        return const Color(0xFF007AFF);
      case SavedItemType.reference:
        return const Color(0xFFAF52DE);
    }
  }

  IconData _getTypeIcon(SavedItemType type) {
    switch (type) {
      case SavedItemType.lesson:
        return Icons.play_circle_filled_rounded;
      case SavedItemType.tip:
        return Icons.lightbulb_rounded;
      case SavedItemType.article:
        return Icons.article_rounded;
      case SavedItemType.reference:
        return Icons.description_rounded;
    }
  }

  String _getTypeName(SavedItemType type) {
    switch (type) {
      case SavedItemType.lesson:
        return 'Lesson';
      case SavedItemType.tip:
        return 'Tip';
      case SavedItemType.article:
        return 'Article';
      case SavedItemType.reference:
        return 'Reference';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  Future<void> _openItem(SavedItem item) async {
    if (item.type == SavedItemType.lesson) {
      final lesson = LessonManager.getLessonById(item.id);
      if (lesson != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
        );
      }
    } else {
      _showItemDetail(item);
    }
  }

  void _showItemDetail(SavedItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _borderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getTypeColor(item.type),
                                  _getTypeColor(item.type).withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getTypeIcon(item.type),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  item.category,
                                  style: TextStyle(
                                    color: _textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Text(
                            item.description,
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _removeSavedItem(SavedItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Remove Bookmark',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Remove "${item.title}" from your saved items?',
              style: TextStyle(color: _textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: _textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await UserPreferences.removeSavedItem(item.id);
      setState(() {
        _savedItems.removeWhere((i) => i.id == item.id);
      });
      HapticFeedback.lightImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} removed from saved items'),
            backgroundColor: _surfaceColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort by',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                ...SortOption.values.map((option) => _buildSortOption(option)),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  Widget _buildSortOption(SortOption option) {
    final isSelected = _currentSort == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSort = option;
        });
        Navigator.pop(context);
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? _primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? _primaryColor.withOpacity(0.3)
                    : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getSortIcon(option),
              color: isSelected ? _primaryColor : _textSecondary,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              _getSortName(option),
              style: TextStyle(
                color: isSelected ? _primaryColor : _textPrimary,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_rounded, color: _primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.recentlySaved:
        return Icons.access_time_rounded;
      case SortOption.alphabetical:
        return Icons.sort_by_alpha_rounded;
      case SortOption.type:
        return Icons.category_rounded;
      case SortOption.category:
        return Icons.folder_rounded;
    }
  }

  String _getSortName(SortOption option) {
    switch (option) {
      case SortOption.recentlySaved:
        return 'Recently Saved';
      case SortOption.alphabetical:
        return 'Alphabetical';
      case SortOption.type:
        return 'Type';
      case SortOption.category:
        return 'Category';
    }
  }
}

enum SortOption { recentlySaved, alphabetical, type, category }
