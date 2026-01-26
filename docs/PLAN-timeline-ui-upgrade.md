# Plan: Lesson Timeline UI Upgrade

## Goal Description
Upgrade the `LessonTimelineScreen` to match the "Dark Prism" aesthetic of the Home Screen, fix the visual overflow bugs, and implementing a professional, connected timeline visualization.

## User Review Required
> [!IMPORTANT]
> **Design Consistency**: We will apply the same "Dark Prism" design language (Dark Gradients `0xFF1E1E1E`, Glassmorphism, Glows) used in the Home Screen to ensure a unified app experience.

> [!WARNING]
> **Overflow Fix**: The screenshot shows a text overflow in the top progress card. This will be fixed by refactoring the layout to be responsive.

## Proposed Changes

### 1. Timeline Visualization (New Widget)
We will replace the disconnected vertical lines with a custom `TimelinePainter` or enhanced `ListView` builder to create a continuous, flowing path.

**Design Concept**: "Neon Path"
-   **Connector**: A gradient line that glows when the path is "unlocked" or "completed".
-   **Nodes**: Numbered nodes (1, 2, 3...) will be replaced/enhanced with status indicators (Locked, Current (Glowing), Completed (Check)).

### 2. Lesson Cards ("Dark Prism" Style)
Refactor the generic lesson cards to match the Home Screen's `_buildContinueLearningWidget`.

**New Card Specs**:
-   **Background**: `LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)])`
-   **Border**: `Border.all(color: Colors.white.withOpacity(0.1))`
-   **Shadow**: `BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)`
-   **Typography**:
    -   Title: `fontSize: 18`, `fontWeight: FontWeight.bold`, `color: Colors.white`
    -   Subtitle: `fontSize: 14`, `color: Colors.white70`
-   **Metadata**: use `_buildGlassChip` (reused/copied from Home) for Duration and Type.

### 3. Header & Progress Section
Refactor the top section (currently overflowing) into a clean, compact header.
-   **Title**: "My Journey" (Large, Bold) + Track Name (Subtitle)
-   **Stats**: Horizontal, scrollable row of Glassmorphic stats (Lessons, Streak, Time) - similar to Home Screen but compact.
-   **Progress Bar**: Slim, glowing line at the bottom of the header.

### 4. Responsiveness
-   **Overflow Fix**: Use `Flexible`/`Expanded` for text containers to prevent overflow (fix for the specific bug in screenshot).
-   **Hit Targets**: Ensure touch targets are 44px+.

## Files to Modify

### [MODIFY] [lesson_timeline_screen.dart](file:///Users/apple/WorkSpace/Programming/Projects/Minor/Photography/photography_guide/lib/presentation/home/lesson_timeline_screen.dart)
-   Refactor `build` method.
-   Replace `ListView.builder` item with new `_buildTimelineItem`.
-   Implement new `_buildTimelineHeader`.
-   Add helper widgets `_buildTimelineCard`, `_buildTimelineConnector`.

## Verification Plan

### Manual Verification
1.  **Visual Check**: Verify "Dark Prism" applies correctly (gradients, shadows).
2.  **Overflow Check**: Verify text does not overflow on small screens (using the "Day 1 of 30" card as a test case).
3.  **Scrolling**: Ensure smooth scrolling with the new list items.
4.  **Dark/Light Mode**: Verify it looks acceptable in Light Mode (though optimized for Dark).
