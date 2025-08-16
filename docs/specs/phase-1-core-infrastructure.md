# F13or Phase 1: Core Infrastructure & Basic Setup

## TODO Checklist
- [x] Add required dependencies to pubspec.yaml
- [x] Create project directory structure
- [x] Implement Project model with JSON serialization
- [x] Implement AppState with Provider/Riverpod
- [x] Create three-panel layout with resizable dividers
- [x] Apply dark theme with VS Code colors
- [x] Create storage service for settings
- [x] Configure window settings (size, title, resizing)
- [ ] Test all Phase 1 requirements

## Session Management
- This is a focused, single-phase task  
- Complete only what's specified
- Do not explore adjacent features
- End session after completion criteria met
- **Expected Duration**: 2-3 hours maximum

## Objective
Set up the basic Flutter desktop application with fundamental layout structure and initial project management capabilities.

## Starting Point
You'll begin with a standard Flutter counter app. Transform it into the foundation for F13or.

## Deliverables

### 1. Project Structure Setup
Create the following directory structure in the Flutter project:
```
lib/
├── main.dart
├── app.dart
├── models/
│   ├── project.dart
│   └── app_state.dart
├── screens/
│   └── main_screen.dart
├── widgets/
│   ├── project_tabs.dart
│   ├── left_panel.dart
│   ├── center_panel.dart
│   └── right_panel.dart
└── services/
    └── storage_service.dart
```

### 2. Core Layout Implementation

#### main_screen.dart
Create a three-panel layout with:
- **Top Bar**: Project tabs area (initially just placeholder tabs)
- **Left Panel**: 300px wide, resizable via draggable divider
- **Center Panel**: Flexible width, main content area
- **Right Panel**: 400px wide, resizable via draggable divider
- Dark theme by default

#### Basic UI Requirements:
- Use `split_view` package for resizable panels
- Implement basic dark theme with VS Code-like colors:
  - Background: #1e1e1e
  - Sidebar: #252526
  - Active tab: #2d2d30
  - Text: #cccccc
  - Borders: #464647

### 3. Project Model
```dart
class Project {
  final String id;
  final String name;
  final String path;
  final DateTime createdAt;
  final DateTime lastOpened;
  
  // Basic constructor and JSON serialization
}
```

### 4. App State Management
Use Provider or Riverpod for state management:
```dart
class AppState extends ChangeNotifier {
  Project? activeProject;
  List<Project> openProjects = [];
  
  void openProject(String path) { }
  void closeProject(String id) { }
  void switchProject(String id) { }
}
```

### 5. Storage Service
Create a basic service to:
- Save/load app settings to `~/Documents/F13or/settings/config.json`
- Create the directory structure if it doesn't exist
- Store recently opened projects

### 6. Window Configuration
- Set minimum window size: 1200x800
- Default size: 1600x900
- Window title: "F13or"
- Enable window resizing

## Implementation Notes

### Dependencies to Add:
```yaml
dependencies:
  flutter:
    sdk: flutter
  split_view: ^3.2.1
  provider: ^6.1.2
  path_provider: ^2.1.5
  window_manager: ^0.4.3
```

### Platform Configuration:
- Ensure desktop support is enabled
- Configure for Windows, macOS, and Linux

## Phase Complete When:
✓ App launches with three-panel layout
✓ Panels are resizable with draggable dividers
✓ Dark theme is applied
✓ Settings directory is created at `~/Documents/F13or/`
✓ Basic project model exists
✓ App state management is set up
✓ No console errors
✓ Manual test: Can drag panel dividers to resize

## STOP HERE - Do not continue to next phase

## Future Context (for awareness only):
- Phase 2 will involve: File explorer tree view in left panel
- Phase 3 will involve: Claude chat integration in right panel
- Phase 4 will involve: Multi-project tab management
DO NOT IMPLEMENT PHASES 2-4 IN THIS SESSION

## Recommended Approach:
1. Scout: Explore the counter app structure (10 min max)
2. Forge: Design the architecture (15 min max)
3. Spark: Implement core layout and models (90 min max)
4. Sentinel: Test the implementation (15 min max)
Total session: ~2 hours

## Avoid These Patterns:
- Don't add file editing capabilities yet
- Don't implement Claude integration
- Don't add Git features
- Don't create complex theming system
- Stay focused on the basic layout and structure