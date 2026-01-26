# Plan: Saved Items UI Upgrade

## Goal Description
Upgrade the `SavedItemsScreen` to match the premium "Dark Prism" aesthetic of the Home and Timeline screens. The current UI feels generic and disjointed. We will implement high-quality glassmorphism, refined typography, and consistent "Dark Prism" card styling.

## User Review Required
> [!IMPORTANT]
> **Design Consistency**: We will strictly follow the "Dark Prism" design language (Dark Gradients `0xFF1E1E1E`, Glassmorphism, Glows) established in previous tasks.

## Proposed Changes

### 1. Header & Search Area
-   **AppBar**: Minimalist dark header (Color `0xFF121212`).
-   **Search Bar**: Replace the standard gray input with a **Glassmorphic Search Field**.
    -   Background: `Colors.white.withOpacity(0.05)`
    -   Border: `Colors.white.withOpacity(0.1)`
    -   Icon: Glowing primary color search icon.

### 2. Filter System (Chips)
-   **Current Issue**: The orange "All" chip is too aggressive/distracting.
-   **New Design**: **Neon Glass Chips**.
    -   **Selected**: Deep Primary Gradient background + White text + Subtle Glow.
    -   **Unselected**: Glass background (`Colors.white.withOpacity(0.05)`) + White/Grey text.
    -   **Counts**: Small, circular status indicators integrated into the chip.

### 3. Saved Item Cards ("Dark Prism")
Refactor the generic list items into premium "Dark Prism" cards.

**Card Specs**:
-   **Background**: `LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)])`
-   **Border**: `Border.all(color: Colors.white.withOpacity(0.1))`
-   **Leading Icon**: Large, colorful container (Green/Blue/Orange based on category) with specific icon (Bulb for Tips, Book for Lessons).
-   **Typography**:
    -   Title: `fontSize: 16`, `fontWeight: FontWeight.bold`, `color: Colors.white`
    -   Metadata: `fontSize: 12`, `color: Colors.white54`.
-   **Action**: "Remove Bookmark" button should be subtle but accessible (slide-to-delete or discreet icon button).

### 4. Empty State
-   Add a high-quality empty state with a large icon (e.g., `Icons.bookmark_border` in a glowing circle) and encouraging text ("Start saving your favorite lessons!").

### 5. Animations
-   **Staggered List Load**: Apply `_FadeInSlide` (0-50ms stagger) to list items for a cascading entry effect.

## Files to Modify

### [MODIFY] [saved_items_screen.dart](file:///Users/apple/WorkSpace/Programming/Projects/Minor/Photography/photography_guide/lib/presentation/home/saved_items_screen.dart)
-   Refactor `build` method.
-   Replace layout with `Column` containing Header, Filters, and List.
-   Implement `_buildSearchField`, `_buildFilterChips`, `_buildSavedItemCard`.
-   Reuse `_buildGlassChip` pattern (or similar) from Home Screen.

## Verification Plan

### Manual Verification
1.  **Visual Check**: Verify "Dark Prism" applies correctly (gradients, shadows).
2.  **Filter Logic**: Ensure clicking filters updates the list correctly with the new UI state.
3.  **Search**: Verify search input looks and works correctly.
4.  **Dark Mode**: Confirm deep dark background (`#121212`) is consistent with other screens.
