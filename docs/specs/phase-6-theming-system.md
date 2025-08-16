# F13or Phase 6: Theming System

## Session Management
- This is a focused, single-phase task
- Complete only what's specified
- Do not explore adjacent features
- End session after completion criteria met
- **Expected Duration**: 2-3 hours maximum
- **Prerequisites**: Phases 1-5 must be complete

## Objective
Implement per-project theming to provide visual distinction between projects and prevent "wrong project" mistakes.

## Starting Point
You have a complete IDE with multi-project support. Now add theming to make each project visually distinct.

## Deliverables

### 1. Theme System Files

#### Create New Files:
```
lib/themes/
├── theme_manager.dart
├── app_theme.dart
├── default_themes.dart
└── theme_builder.dart

lib/widgets/settings/
└── theme_selector.dart
```

### 2. Theme Model

```dart
class AppTheme {
  final String id;
  final String name;
  final bool isDark;
  
  // Colors
  final Color primaryColor;        // Project tab, active selections
  final Color accentColor;         // Buttons, links, highlights
  final Color backgroundColor;     // Main editor background
  final Color sidebarBackground;   // File tree, panels
  final Color surfaceColor;        // Cards, dialogs
  
  // Text colors
  final Color textColor;
  final Color secondaryTextColor;
  final Color codeColor;
  
  // Editor colors
  final Color lineNumberColor;
  final Color selectionColor;
  final Color cursorColor;
  
  // Syntax highlighting theme name
  final String syntaxTheme; // "vs-dark", "monokai", "github", etc.
  
  // Git status colors (optional overrides)
  final Color? gitModifiedColor;
  final Color? gitAddedColor;
  final Color? gitDeletedColor;
  
  Map<String, dynamic> toJson();
  factory AppTheme.fromJson(Map<String, dynamic> json);
}
```

### 3. Default Themes

Create 6-8 built-in themes:

```dart
class DefaultThemes {
  static final darkVSCode = AppTheme(
    id: 'dark-vscode',
    name: 'Dark (VS Code)',
    isDark: true,
    primaryColor: Color(0xFF007ACC),
    backgroundColor: Color(0xFF1E1E1E),
    sidebarBackground: Color(0xFF252526),
    // ... other VS Code colors
  );
  
  static final oceanBlue = AppTheme(
    id: 'ocean-blue',
    name: 'Ocean Blue',
    isDark: true,
    primaryColor: Color(0xFF0891B2),
    backgroundColor: Color(0xFF0F172A),
    // ... ocean theme colors
  );
  
  static final forestGreen = AppTheme(
    id: 'forest-green',
    name: 'Forest Green',
    isDark: true,
    primaryColor: Color(0xFF10B981),
    backgroundColor: Color(0xFF14532D),
    // ... forest theme colors
  );
  
  static final midnightPurple = AppTheme(
    id: 'midnight-purple',
    name: 'Midnight Purple',
    isDark: true,
    primaryColor: Color(0xFF8B5CF6),
    // ... purple theme colors
  );
  
  static final lightTheme = AppTheme(
    id: 'light-default',
    name: 'Light',
    isDark: false,
    primaryColor: Color(0xFF0066CC),
    backgroundColor: Color(0xFFFFFFFF),
    // ... light theme colors
  );
  
  // Add 2-3 more themes
}
```

### 4. Theme Application

#### Areas affected by theme:
1. **Project Tab**: 
   - Use primary color for active tab background
   - Slightly darker/lighter for inactive tabs

2. **Sidebar (File Tree)**:
   - Use sidebarBackground color
   - Primary color for selected file
   - Hover states with opacity

3. **Editor**:
   - Background and text colors
   - Tab bar styling
   - Line numbers and gutter

4. **Claude Panel**:
   - Panel background
   - Message bubbles (user messages use primary color)
   - Input field styling

5. **Git Panel**:
   - Use theme colors for buttons
   - Status indicators can use theme overrides

6. **Window Chrome** (if possible):
   - Title bar color
   - Window border

### 5. Theme Selector Widget

In project settings or toolbar:
- Dropdown or grid showing theme previews
- Color swatches for each theme
- "Customize" option (future feature)
- Apply immediately on selection
- Save theme choice to project file

### 6. Theme Manager Service

```dart
class ThemeManager {
  AppTheme? currentTheme;
  Map<String, AppTheme> availableThemes = {};
  
  void loadDefaultThemes();
  void loadCustomThemes(); // From ~/Documents/F13or/settings/themes/
  void applyTheme(AppTheme theme);
  void setProjectTheme(String projectId, String themeId);
  AppTheme getProjectTheme(String projectId);
  
  // Theme persistence
  void saveCustomTheme(AppTheme theme);
  Future<List<AppTheme>> loadThemesFromDisk();
}
```

### 7. Dynamic Theme Application

```dart
class ThemedApp extends StatelessWidget {
  final AppTheme theme;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: theme.primaryColor,
        scaffoldBackgroundColor: theme.backgroundColor,
        // ... map AppTheme to Flutter ThemeData
      ),
      child: child,
    );
  }
}
```

### 8. Project Theme Persistence

Update project .f13or file:
```json
{
  "project": {
    "theme": "ocean-blue",
    // ... other project data
  }
}
```

### 9. Visual Distinction Features

#### Project-specific visual cues:
1. **Tab Color Strip**: 3px colored line at top of project tab
2. **Sidebar Accent**: Colored left border on file tree
3. **Status Bar**: Bottom status bar uses theme primary color
4. **Window Title**: Include project name with color indicator (if supported)

### 10. Theme Hot-Reload

When theme changes:
- Immediately update all UI components
- No need to restart app
- Smooth transition (optional fade animation)
- Remember theme selection per project

## Implementation Notes

### Performance:
- Cache theme objects
- Use InheritedWidget or Provider for theme access
- Avoid rebuilding entire widget tree

### Accessibility:
- Ensure sufficient contrast ratios
- Test with color blindness simulators
- Provide high contrast theme option

### Syntax Highlighting:
- Map theme to compatible syntax highlighting theme
- Ensure code remains readable with theme colors

## Phase Complete When:
✓ 6+ built-in themes available
✓ Can select theme from dropdown/selector
✓ Theme applies to entire project UI
✓ Each project remembers its theme
✓ Project tabs show distinct colors
✓ Theme persists between sessions
✓ Visual distinction prevents project confusion
✓ No console errors
✓ Manual test: Open 3 projects with different themes, verify distinction

## STOP HERE - Core features complete!

## Future Enhancements (Not in this phase):
- Custom theme creator
- Theme import/export
- Theme marketplace
- Seasonal themes
- Automatic theme based on project type
- Color picker for customization

## Recommended Approach:
1. Scout: Review current UI components (10 min max)
2. Forge: Design theme architecture (20 min max)
3. Spark: Create default themes (30 min max)
4. Spark: Implement theme application system (45 min max)
5. Sentinel: Test theme switching and persistence (15 min max)
Total session: ~2 hours

## Avoid These Patterns:
- Don't build complex theme editor yet
- Don't implement gradient backgrounds
- Don't add animations beyond simple transitions
- Don't create too many themes (6-8 is enough)
- Don't add theme scheduling or auto-switching
- Focus on visual distinction and user preference