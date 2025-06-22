# Photography Guide 📸

A comprehensive Flutter mobile application designed to teach photography through structured daily lessons, interactive exercises, and progressive skill building.

## 🌟 Features

### 📚 **Structured Learning Path**

- **30-Day Course**: Complete photography course with daily lessons
- **Progressive Difficulty**: Beginner → Intermediate → Advanced
- **Daily Restrictions**: One lesson per day to encourage consistent learning
- **Multiple Lesson Types**: Theory lessons and hands-on practice exercises

### 📊 **Progress Tracking**

- **Daily Streak Counter**: Track consecutive learning days
- **Lesson Progress**: Detailed progress for each lesson with completion status
- **Time Tracking**: Monitor time spent on each lesson
- **Statistics Dashboard**: View learning analytics and achievements

### 🎯 **Personalized Experience**

- **Difficulty Selection**: Choose your starting skill level
- **User Preferences**: Customizable app settings and notifications
- **Saved Content**: Bookmark tips, articles, and references
- **Onboarding Flow**: Guided setup for new users

### 🔍 **Content Library**

- **Interactive Lessons**: Rich content with objectives and exercises
- **Photography Tips**: Quick tips for immediate improvement
- **In-Depth Articles**: Comprehensive guides on specific topics
- **Reference Materials**: Cheat sheets and quick reference guides

### ⚙️ **App Features**

- **Dark/Light Mode**: Adaptive UI themes
- **Offline Support**: Learn without internet connection
- **Search Functionality**: Find content across all materials
- **Daily Reminders**: Customizable notification system
- **Multi-language Support**: Localization ready

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.0.0 or higher
- **Dart SDK**: Version 2.17.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/photography-guide.git
   cd photography-guide
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android APK:**

```bash
flutter build apk --release
```

**iOS (requires macOS):**

```bash
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── models/                 # Data models
│   ├── lesson.dart        # Lesson and exercise models
│   ├── user_progress.dart # Progress tracking models
│   └── saved_item.dart    # Saved content models
├── services/              # Business logic and data management
│   ├── lesson_manager.dart     # Lesson content management
│   └── user_preferences.dart   # User data persistence
├── screens/               # UI screens
│   ├── home/              # Home and dashboard screens
│   ├── lessons/           # Lesson viewing and interaction
│   ├── progress/          # Progress tracking and stats
│   └── settings/          # App settings and preferences
├── widgets/               # Reusable UI components
│   ├── common/            # Generic widgets
│   ├── lesson/            # Lesson-specific widgets
│   └── progress/          # Progress-related widgets
├── utils/                 # Utilities and constants
│   ├── constants.dart     # App constants and configurations
│   ├── themes.dart        # App theming
│   └── helpers.dart       # Helper functions
└── main.dart             # App entry point
```

## 🎨 Key Architecture Features

### **Data Persistence**

- **SharedPreferences**: Local storage for user data and preferences
- **JSON Serialization**: Efficient data serialization/deserialization
- **Progress Sync**: Automatic progress saving and loading

### **Daily Restriction System**

- **Time-based Unlocking**: Lessons unlock based on real-time progression
- **Streak Tracking**: Encourages daily engagement
- **Flexible Progress**: Accommodates different learning paces

### **Content Management**

- **Modular Lessons**: Easy to add/modify lesson content
- **Category System**: Organized content by photography topics
- **Search Integration**: Full-text search across all content types

## 🔧 Configuration

### **App Constants** (`lib/utils/constants.dart`)

```dart
class AppConstants {
  static const int totalCourseDays = 30;
  static const int defaultLessonDuration = 20; // minutes
  static const String appVersion = '1.0.0';
}
```

### **Lesson Content**

Lessons are programmatically generated but can be easily modified in `LessonManager._generateLessons()` to load from:

- JSON files
- Remote API
- Local database

## 📱 Usage Guide

### **First Time Setup**

1. **Welcome Screen**: Introduction to the app
2. **Skill Level Selection**: Choose beginner, intermediate, or advanced
3. **Preferences Setup**: Configure notifications and settings
4. **Onboarding Tour**: Learn how to navigate the app

### **Daily Learning Flow**

1. **Open App**: Check today's available lesson
2. **Complete Lesson**: Read theory and complete exercises
3. **Track Progress**: View completion and time spent
4. **Explore Content**: Browse tips, articles, and references

### **Progress Management**

- **Statistics Screen**: View learning analytics
- **Streak Counter**: Track daily learning consistency
- **Lesson History**: Review completed lessons and progress

## 🛠️ Development

### **Adding New Lessons**

1. Update `_generateLessons()` in `LessonManager`
2. Add lesson content, objectives, and exercises
3. Update `totalCourseDays` if needed

### **Customizing Themes**

1. Modify `lib/utils/themes.dart`
2. Update color schemes and text styles
3. Test in both light and dark modes

### **Adding Languages**

1. Create new `.arb` files in `lib/l10n/`
2. Update `pubspec.yaml` with new locales
3. Regenerate localization files

## 🧪 Testing

### **Run Tests**

```bash
flutter test
```

### **Widget Tests**

Test individual UI components:

```bash
flutter test test/widgets/
```

### **Integration Tests**

Test complete user flows:

```bash
flutter test integration_test/
```

## 📦 Dependencies

### **Core Dependencies**

- `flutter`: UI framework
- `shared_preferences`: Local data persistence
- `provider`: State management (if used)

### **Development Dependencies**

- `flutter_test`: Testing framework
- `flutter_lints`: Code linting rules

## 🚀 Deployment

### **Android Play Store**

1. Update version in `pubspec.yaml`
2. Build release APK: `flutter build apk --release`
3. Sign and upload to Play Console

### **iOS App Store**

1. Update version in `pubspec.yaml` and `ios/Runner/Info.plist`
2. Build for iOS: `flutter build ios --release`
3. Archive and submit via Xcode

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** and write tests
4. **Commit your changes**: `git commit -m 'Add amazing feature'`
5. **Push to branch**: `git push origin feature/amazing-feature`
6. **Open a Pull Request**

### **Code Style Guidelines**

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation for public APIs
- Write tests for new features

### **Commit Message Format**

```
type(scope): description

[optional body]

[optional footer]
```

Examples:

- `feat(lessons): add video lesson support`
- `fix(progress): resolve streak calculation bug`
- `docs(readme): update installation instructions`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/photography-guide/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/photography-guide/discussions)
- **Email**: support@photographyguide.app

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **Photography Community**: For inspiration and feedback
- **Contributors**: Everyone who helped improve this app

---

**Made with ❤️ for photography enthusiasts**

_Happy Learning! 📸_
