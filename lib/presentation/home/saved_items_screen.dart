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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  String searchQuery = '';
  int selectedTab = 0;
  List<SavedItem> _savedItems = [];
  bool _isLoading = true;
  SortOption _currentSort = SortOption.recentlySaved;

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

    if (selectedTab > 0) {
      final type = SavedItemType.values[selectedTab - 1];
      items = items.where((item) => item.type == type).toList();
    }

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearchField(),
            const SizedBox(height: 20),
            _buildFilterTabs(),
            const SizedBox(height: 20),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Column(
            children: [
              const Text(
                'Saved Items',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${filteredItems.length} items',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _showSortOptions,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.sort_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
            hintText: 'Search saved items...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            border: InputBorder.none,
            suffixIcon:
                searchQuery.isNotEmpty
                    ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      onPressed: () => setState(() => searchQuery = ''),
                    )
                    : null,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = selectedTab == index;
          return GestureDetector(
            onTap: () {
              setState(() => selectedTab = index);
              HapticFeedback.lightImpact();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.8),
                          ],
                        )
                        : null,
                color: isSelected ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.1),
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    final items = filteredItems;

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        final delay = index * 0.05; // Stagger duration

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final animation = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  delay.clamp(0.0, 0.8),
                  (delay + 0.4).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
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
    );
  }

  Widget _buildSavedItemCard(SavedItem item) {
    // final colorScheme = Theme.of(context).colorScheme; // Unused

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFCF6679).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFCF6679).withOpacity(0.3)),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFCF6679),
          size: 28,
        ),
      ),
      onDismissed: (_) => _removeSavedItem(item),
      child: GestureDetector(
        onTap: () => _openItem(item),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
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
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getTypeName(item.type).toUpperCase(),
                            style: TextStyle(
                              color: _getTypeColor(item.type),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (item.category.isNotEmpty)
                          Text(
                            item.category,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saved ${_formatTime(item.savedDate)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearch = searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: (isSearch
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearch
                  ? Icons.search_off_rounded
                  : Icons.bookmark_border_rounded,
              size: 48,
              color:
                  isSearch
                      ? Colors.red.withOpacity(0.8)
                      : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearch ? 'No Results Found' : 'No Saved Items',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch
                ? 'Try searching for something else'
                : 'Items you bookmark will appear here',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
  Color _getTypeColor(SavedItemType type) {
    switch (type) {
      case SavedItemType.lesson:
        return const Color(0xFFFF6B35);
      case SavedItemType.tip:
        return const Color(0xFF30D158);
      case SavedItemType.article:
        return const Color(0xFF007AFF);
      case SavedItemType.reference:
        return const Color(0xFFAF52DE);
    }
  }

  IconData _getTypeIcon(SavedItemType type) {
    switch (type) {
      case SavedItemType.lesson:
        return Icons.play_lesson_rounded;
      case SavedItemType.tip:
        return Icons.lightbulb_rounded;
      case SavedItemType.article:
        return Icons.article_rounded;
      case SavedItemType.reference:
        return Icons.book_rounded;
    }
  }

  String _getTypeName(SavedItemType type) => type.toString().split('.').last;

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  SortOption.values.map((option) {
                    final isSelected = _currentSort == option;
                    return ListTile(
                      title: Text(
                        option.toString().split('.').last,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              )
                              : null,
                      onTap: () {
                        setState(() => _currentSort = option);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  Future<void> _openItem(SavedItem item) async {
    print(
      '🔍 Opening item: ${item.title} (ID: ${item.id}, Type: ${item.type})',
    );

    if (item.type == SavedItemType.lesson) {
      final lesson = LessonManager.getLessonById(item.id);
      print('📖 Lesson found: ${lesson?.title ?? "NULL"}');

      if (lesson != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Content not found for "${item.title}"'),
              backgroundColor: Colors.red.withOpacity(0.8),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'REMOVE',
                textColor: Colors.white,
                onPressed: () => _removeSavedItem(item),
              ),
            ),
          );
        }
      }
    } else {
      // Show detail bottom sheet for other types
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E1E),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder:
            (context) => DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (_, controller) => _buildDetailSheet(item, controller),
            ),
      );
    }
  }

  Widget _buildDetailSheet(SavedItem item, ScrollController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: controller,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(item.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getTypeColor(item.type).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getTypeName(item.type).toUpperCase(),
                  style: TextStyle(
                    color: _getTypeColor(item.type),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.white),
                onPressed: () {
                  _removeSavedItem(item);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          // Add more content here based on item type if needed
        ],
      ),
    );
  }

  Future<void> _removeSavedItem(SavedItem item) async {
    // Optimistic update
    final index = _savedItems.indexOf(item);
    setState(() {
      _savedItems.remove(item);
    });

    try {
      await UserPreferences.removeSavedItem(item.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} removed from saved items'),
            backgroundColor: const Color(0xFF323232),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Theme.of(context).colorScheme.primary,
              onPressed: () async {
                // Restore item
                setState(() {
                  _savedItems.insert(index, item);
                });
                await UserPreferences.addSavedItem(item);
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Revert if failed
      if (mounted) {
        setState(() {
          _savedItems.insert(index, item);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to remove item')));
      }
    }
  }
}

enum SortOption { recentlySaved, alphabetical, type, category }
