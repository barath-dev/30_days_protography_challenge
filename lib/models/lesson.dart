class Lesson {
  final String id;
  final int day;
  final String title;
  final String subtitle;
  final String description;
  final String content;
  final int estimatedDuration; // in minutes
  final LessonType type;
  final DifficultyLevel difficulty;
  final List<String> categories;
  final List<String> objectives;
  final List<PracticeExercise> exercises;
  final List<String> imageUrls;
  final Map<String, dynamic> technicalDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lesson({
    required this.id,
    required this.day,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.content,
    required this.estimatedDuration,
    required this.type,
    required this.difficulty,
    required this.categories,
    required this.objectives,
    required this.exercises,
    required this.imageUrls,
    required this.technicalDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      day: json['day'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      estimatedDuration: json['estimatedDuration'] ?? 0,
      type: LessonType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => LessonType.theory,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      categories: List<String>.from(json['categories'] ?? []),
      objectives: List<String>.from(json['objectives'] ?? []),
      exercises:
          (json['exercises'] as List?)
              ?.map((e) => PracticeExercise.fromJson(e))
              .toList() ??
          [],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      technicalDetails: Map<String, dynamic>.from(
        json['technicalDetails'] ?? {},
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'content': content,
      'estimatedDuration': estimatedDuration,
      'type': type.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'categories': categories,
      'objectives': objectives,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'imageUrls': imageUrls,
      'technicalDetails': technicalDetails,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Lesson copyWith({
    String? id,
    int? day,
    String? title,
    String? subtitle,
    String? description,
    String? content,
    int? estimatedDuration,
    LessonType? type,
    DifficultyLevel? difficulty,
    List<String>? categories,
    List<String>? objectives,
    List<PracticeExercise>? exercises,
    List<String>? imageUrls,
    Map<String, dynamic>? technicalDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      day: day ?? this.day,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      content: content ?? this.content,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      categories: categories ?? this.categories,
      objectives: objectives ?? this.objectives,
      exercises: exercises ?? this.exercises,
      imageUrls: imageUrls ?? this.imageUrls,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PracticeExercise {
  final String id;
  final String title;
  final String description;
  final List<String> steps;
  final Map<String, dynamic> requirements;
  final int estimatedTime;

  const PracticeExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.requirements,
    required this.estimatedTime,
  });

  factory PracticeExercise.fromJson(Map<String, dynamic> json) {
    return PracticeExercise(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      steps: List<String>.from(json['steps'] ?? []),
      requirements: Map<String, dynamic>.from(json['requirements'] ?? {}),
      estimatedTime: json['estimatedTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'steps': steps,
      'requirements': requirements,
      'estimatedTime': estimatedTime,
    };
  }
}

enum LessonType { theory, practice, review, planning, project, celebration }

enum DifficultyLevel { beginner, intermediate, advanced }
