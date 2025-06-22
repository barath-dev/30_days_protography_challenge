import 'package:photography_guide/models/lesson.dart';

class SavedItem {
  final String id;
  final String title;
  final String description;
  final SavedItemType type;
  final String category;
  final int? duration;
  final DateTime savedDate;
  final String? imageUrl;
  final String? contentUrl;
  final double? progress;
  final Map<String, dynamic> metadata;

  const SavedItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.duration,
    required this.savedDate,
    this.imageUrl,
    this.contentUrl,
    this.progress,
    this.metadata = const {},
  });

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: SavedItemType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => SavedItemType.article,
      ),
      category: json['category'] ?? '',
      duration: json['duration'],
      savedDate: DateTime.parse(
        json['savedDate'] ?? DateTime.now().toIso8601String(),
      ),
      imageUrl: json['imageUrl'],
      contentUrl: json['contentUrl'],
      progress: json['progress']?.toDouble(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'category': category,
      'duration': duration,
      'savedDate': savedDate.toIso8601String(),
      'imageUrl': imageUrl,
      'contentUrl': contentUrl,
      'progress': progress,
      'metadata': metadata,
    };
  }

  SavedItem copyWith({
    String? id,
    String? title,
    String? description,
    SavedItemType? type,
    String? category,
    int? duration,
    DateTime? savedDate,
    String? imageUrl,
    String? contentUrl,
    double? progress,
    Map<String, dynamic>? metadata,
  }) {
    return SavedItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      savedDate: savedDate ?? this.savedDate,
      imageUrl: imageUrl ?? this.imageUrl,
      contentUrl: contentUrl ?? this.contentUrl,
      progress: progress ?? this.progress,
      metadata: metadata ?? this.metadata,
    );
  }

  // Factory methods for creating different types of saved items
  factory SavedItem.fromLesson(Lesson lesson, DateTime savedDate) {
    return SavedItem(
      id: lesson.id,
      title: lesson.title,
      description: lesson.description,
      type: SavedItemType.lesson,
      category:
          lesson.categories.isNotEmpty ? lesson.categories.first : 'General',
      duration: lesson.estimatedDuration,
      savedDate: savedDate,
      metadata: {
        'day': lesson.day,
        'difficulty': lesson.difficulty.toString().split('.').last,
        'objectives': lesson.objectives,
      },
    );
  }

  factory SavedItem.fromTip(
    String id,
    String title,
    String description,
    String category,
    DateTime savedDate,
  ) {
    return SavedItem(
      id: id,
      title: title,
      description: description,
      type: SavedItemType.tip,
      category: category,
      duration: 5, // Tips are usually short
      savedDate: savedDate,
    );
  }

  factory SavedItem.fromArticle(
    String id,
    String title,
    String description,
    String category,
    int duration,
    DateTime savedDate,
  ) {
    return SavedItem(
      id: id,
      title: title,
      description: description,
      type: SavedItemType.article,
      category: category,
      duration: duration,
      savedDate: savedDate,
    );
  }

  factory SavedItem.fromReference(
    String id,
    String title,
    String description,
    String category,
    DateTime savedDate,
  ) {
    return SavedItem(
      id: id,
      title: title,
      description: description,
      type: SavedItemType.reference,
      category: category,
      savedDate: savedDate,
    );
  }
}

enum SavedItemType { lesson, tip, article, reference }

// Extension methods for better type handling
extension SavedItemTypeExtension on SavedItemType {
  String get displayName {
    switch (this) {
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

  String get description {
    switch (this) {
      case SavedItemType.lesson:
        return 'Interactive learning content with exercises';
      case SavedItemType.tip:
        return 'Quick photography tips and tricks';
      case SavedItemType.article:
        return 'In-depth articles and guides';
      case SavedItemType.reference:
        return 'Reference materials and cheat sheets';
    }
  }
}

// Category management
class SavedItemCategory {
  static const String fundamentals = 'Fundamentals';
  static const String composition = 'Composition';
  static const String lighting = 'Lighting';
  static const String technical = 'Technical';
  static const String genres = 'Genres';
  static const String editing = 'Editing';
  static const String equipment = 'Equipment';
  static const String inspiration = 'Inspiration';

  static List<String> get allCategories => [
    fundamentals,
    composition,
    lighting,
    technical,
    genres,
    editing,
    equipment,
    inspiration,
  ];

  static String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fundamentals':
        return '📚';
      case 'composition':
        return '🎨';
      case 'lighting':
        return '💡';
      case 'technical':
        return '⚙️';
      case 'genres':
        return '📷';
      case 'editing':
        return '✨';
      case 'equipment':
        return '🔧';
      case 'inspiration':
        return '💫';
      default:
        return '📄';
    }
  }
}
