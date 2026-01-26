# Plan: Home Screen UI Upgrade

## Context
The user has identified that the "Today's Lesson" and "Progress Overview" components on the Home Screen lack a professional polish. The goal is to redesign these using modern UI principles (Glassmorphism, clean typography, consistent spacing) to achieve a premium feel suitable for a photography app.

## Goals
1.  **Elevate Visual Quality**: Replace basic container styles with professional card designs (gradients, shadows, blur effects).
2.  **Improve Hierarchy**: Ensure the "Call to Action" (Start Lesson) is distinct and primary.
3.  **Modernize Progress Tracking**: Refine the recently implemented scrollable stats to blend seamlessly with the new design language.

## Design Concept: "Dark Prism"
- **Theme**: Deep dark backgrounds (`#0D0D0D`) with vibrant accents (Orange `#FF6B35`) used sparingly for focus.
- **Card Style**:
    - **Surface**: Dark grey with huge corner radius (24px).
    - **Texture**: Subtle linear gradients or "Noise" texture if possible (simulated with colors).
    - **Depth**: Soft, colored shadows (glows) behind active elements.
- **Typography**:
    - **Headings**: White, Bold, Tight tracking.
    - **Subtitles**: Grey (`#AAAAAA`), Medium weight.

## Task Breakdown

### Phase 1: Hero Component (`_buildContinueLearningWidget`)
- **[ ] Redesign Carder Container**
    - Increase border radius to `32.0`.
    - Apply a subtle vertical gradient (e.g., Dark Grey -> Black).
    - Add a "Glow" shadow matching the lesson type color (e.g., Orange for Theory).
- **[ ] Enhance Content Layout**
    - Move "Today's Lesson" label to a "Pill" chip at the top left.
    - Increase Title font size and weight.
    - Use transparent/glass chips for metadata (Duration, Type).
- **[ ] Upgrade Action Button**
    - Full-width "Floating" button at the bottom.
    - "Outer Glow" effect to make it pop.

### Phase 2: Progress Component (`_buildProgressOverview`)
- **[ ] Unify Design Language**
    - Match container style of Hero component (Rounded corners, subtle border).
    - Remove disjointed "Track" vs "Stats" feel; merge into one cohesive dashboard widget.
- **[ ] Polish Stat Chips**
    - Ensure chips have uniform height/padding.
    - Use `BackdropFilter` (Blur) if performance allows, or semi-transparent overlay for "Glass" look.
- **[ ] Layout Refinement**
    - Align "Beginner Track" title with the visual grid.
    - Add a visual progress bar that integrates with the card border or background.

### Phase 3: Final Polish
- **[ ] Spacing Audit**: Ensure consistent 20px/24px gaps between sections.
- **[ ] Animation**: Add subtle `Scale` or `Fade` on press for interactivity.

## Agent Assignments
- **UI/UX Designer**: Define the specific gradient colors and shadow values.
- **Flutter Developer**: Implement the layouts in `home_screen.dart`.

## Verification Checklist
- [ ] Overflow errors are permanently resolved.
- [ ] "Today's Lesson" card looks distinctly clickable and premium.
- [ ] Progress stats are readable and scroll smoothly.
- [ ] Design is consistent across Light/Dark modes (if applicable, though app seems Dark-first).
