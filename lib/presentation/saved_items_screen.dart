import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/saved_item.dart';
import '../services/user_preferences.dart';
import '../services/lesson_manager.dart';
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

  // Design constants
  static const Color _primary = Color(0xFFFF6B35);
  static const Color _background = Color(0xFF0D0D0D);
  static const Color _card = Color(0xFF1A1A1A);
  static const Color _text = Color(0xFF888888);
  static const Color _border = Color(0xFF333333);
  static const Color _success = Color(0xFF4CAF50);

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
      backgroundColor: _background,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Column(
            children: [
              const Text(
                'Saved Items',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_savedItems.length} items saved',
                style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
              ),
            ],
          ),
          GestureDetector(
            onTap: _showSortOptions,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sort, color: Colors.white),
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
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: _text, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search saved items...',
                  hintStyle: TextStyle(color: _text),
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
                child: Icon(Icons.close, color: _text, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? _primary : _card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? _primary : _border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tab,
                          style: TextStyle(
                            color: isSelected ? Colors.white : _text,
                            fontSize: 14,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : _border,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : _text,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
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
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primary),
        ),
      );
    }

    final items = filteredItems;

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadSavedItems,
      color: _primary,
      backgroundColor: _card,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getTypeColor(item.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getTypeColor(item.type).withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  _getTypeIcon(item.type),
                  color: _getTypeColor(item.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(item.type).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getTypeName(item.type),
                            style: TextStyle(
                              color: _getTypeColor(item.type),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _removeSavedItem(item),
                          child: Icon(
                            Icons.bookmark,
                            color: _primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _openItem(item),
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(color: _text, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar for lessons
          if (item.progress != null) ...[
            Row(
              children: [
                Text('Progress', style: TextStyle(color: _text, fontSize: 12)),
                const Spacer(),
                Text(
                  '${(item.progress! * 100).round()}%',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: item.progress,
              backgroundColor: _border,
              valueColor: AlwaysStoppedAnimation(_primary),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 12),
          ],

          // Footer info
          Row(
            children: [
              Icon(Icons.folder_outlined, color: _text, size: 14),
              const SizedBox(width: 4),
              Text(item.category, style: TextStyle(color: _text, fontSize: 12)),
              if (item.duration != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.schedule, color: _text, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${item.duration} min',
                  style: TextStyle(color: _text, fontSize: 12),
                ),
              ],
              const Spacer(),
              Text(
                _formatDate(item.savedDate),
                style: TextStyle(color: _text, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: _card, shape: BoxShape.circle),
            child: Icon(Icons.bookmark_outline, color: _text, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Saved Items',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'No items match your search'
                : 'Start bookmarking lessons and tips\nto see them here',
            style: TextStyle(color: _text, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (searchQuery.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  searchQuery = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Search'),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(SavedItemType type) {
    switch (type) {
      case SavedItemType.lesson:
        return _primary;
      case SavedItemType.tip:
        return _success;
      case SavedItemType.article:
        return const Color(0xFF2196F3);
      case SavedItemType.reference:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getTypeIcon(SavedItemType type) {
    switch (type) {
      case SavedItemType.lesson:
        return Icons.play_circle_outline;
      case SavedItemType.tip:
        return Icons.lightbulb_outline;
      case SavedItemType.article:
        return Icons.article_outlined;
      case SavedItemType.reference:
        return Icons.description_outlined;
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

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  Future<void> _openItem(SavedItem item) async {
    if (item.type == SavedItemType.lesson) {
      // Get the lesson and navigate to lesson detail
      final lesson = LessonManager.getLessonById(item.id);
      if (lesson != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
        );
      }
    } else {
      // For other types, show a simple detail view or open content
      _showItemDetail(item);
    }
  }

  void _showItemDetail(SavedItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getTypeColor(item.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getTypeIcon(item.type),
                              color: _getTypeColor(item.type),
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item.category,
                                  style: TextStyle(color: _text, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Text(
                            item.description,
                            style: TextStyle(
                              color: _text,
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
            backgroundColor: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Remove Bookmark',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to remove "${item.title}" from your saved items?',
              style: TextStyle(color: _text),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: _text)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
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
            backgroundColor: _card,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort by',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...SortOption.values.map((option) => _buildSortOption(option)),
              ],
            ),
          ),
    );
  }

  Widget _buildSortOption(SortOption option) {
    final isSelected = _currentSort == option;

    return ListTile(
      leading: Icon(_getSortIcon(option), color: isSelected ? _primary : _text),
      title: Text(
        _getSortName(option),
        style: TextStyle(
          color: isSelected ? _primary : Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing:
          isSelected ? Icon(Icons.check, color: _primary, size: 20) : null,
      onTap: () {
        setState(() {
          _currentSort = option;
        });
        Navigator.pop(context);
      },
    );
  }

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.recentlySaved:
        return Icons.access_time;
      case SortOption.alphabetical:
        return Icons.sort_by_alpha;
      case SortOption.type:
        return Icons.category;
      case SortOption.category:
        return Icons.folder_outlined;
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
