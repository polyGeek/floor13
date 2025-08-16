# F13or Phase 4: Multi-Project Support

## Session Management
- This is a focused, single-phase task
- Complete only what's specified
- Do not explore adjacent features
- End session after completion criteria met
- **Expected Duration**: 2-3 hours maximum
- **Prerequisites**: Phases 1-3 must be complete

## Objective
Implement multi-project management with project tabs, quick switching, and per-project state persistence.

## Starting Point
You have a working single-project IDE with file explorer, editor, and Claude chat. Now add support for multiple projects.

## Deliverables

### 1. Project Tab Bar (Top of Window)

#### Create New Files:
```
lib/widgets/project_management/
├── project_tab_bar.dart
├── project_tab.dart
├── project_switcher.dart
└── new_project_dialog.dart

lib/services/
└── project_manager.dart
```

### 2. Enhanced Project Model

```dart
class Project {
  final String id;
  final String name;
  final String path;
  final DateTime createdAt;
  final DateTime lastOpened;
  
  // Project-specific state
  final List<String> openFiles;
  final String? activeFile;
  final List<Conversation> conversations;
  final String? activeConversationId;
  final String gitBranch;
  final String themeName;
  final List<String> recentFiles;
  
  // Methods
  Map<String, dynamic> toJson();
  factory Project.fromJson(Map<String, dynamic> json);
  void saveState();
}
```

### 3. Project Tab Features

#### Visual Design:
- Tabs across the top of the window (below title bar)
- Tab shows project name with close button (×)
- Active tab highlighted with accent color
- Hover state shows full project path in tooltip
- "+" button at end for new project
- Draggable to reorder tabs

#### Tab Behavior:
- Click to switch project
- Middle-click or ×button to close
- Keyboard shortcuts:
  - Ctrl+1, Ctrl+2, etc. to switch to specific project
  - Ctrl+Tab to cycle through projects
  - Ctrl+Shift+Tab to cycle backwards

### 4. Project Manager Service

```dart
class ProjectManager {
  List<Project> openProjects = [];
  Project? activeProject;
  
  // Project operations
  Future<Project> openProject(String path);
  Future<Project> createNewProject(String name, String path);
  void closeProject(String projectId);
  void switchToProject(String projectId);
  
  // State management
  void saveProjectState(Project project);
  void saveAllProjectStates();
  Future<void> restoreLastSession();
  
  // Project file operations (.f13or files)
  Future<void> saveProjectFile(Project project);
  Future<Project?> loadProjectFile(String path);
}
```

### 5. New Project Dialog

#### Fields:
- Project Name (required)
- Project Path (with folder picker button)
- Template Selection (optional):
  - Empty Project
  - Flutter App
  - Web Project
  - From existing folder
- Theme Selection (use default initially)

#### Validation:
- Check if project name already exists
- Verify path is valid and accessible
- Create .f13or file in ~/Documents/F13or/projects/

### 6. Project Switching Logic

When switching projects:
1. Save current project state:
   - Open files and active file
   - Claude conversations
   - Scroll positions
   - Unsaved changes (prompt to save)

2. Load new project state:
   - Restore file tree to project path
   - Open previously opened files
   - Restore active file and cursor position
   - Load Claude conversation history
   - Update window title

3. Update UI:
   - Change active tab highlight
   - Refresh all panels
   - Apply project theme (if different)

### 7. Project File Format (.f13or)

```json
{
  "version": "1.0.0",
  "project": {
    "id": "uuid",
    "name": "My Project",
    "path": "/path/to/project",
    "createdAt": "2025-01-15T10:00:00Z",
    "lastOpened": "2025-01-15T14:30:00Z"
  },
  "state": {
    "openFiles": [
      "/path/to/project/lib/main.dart",
      "/path/to/project/README.md"
    ],
    "activeFile": "/path/to/project/lib/main.dart",
    "gitBranch": "main",
    "theme": "dark"
  },
  "editor": {
    "cursorPositions": {
      "/path/to/project/lib/main.dart": {"line": 45, "column": 12}
    },
    "scrollPositions": {
      "/path/to/project/lib/main.dart": 120
    }
  },
  "claude": {
    "conversations": [],
    "activeConversationId": "conv_123"
  },
  "recent": {
    "files": [],
    "searchTerms": []
  }
}
```

### 8. Settings Update

Global settings should track:
```json
{
  "recentProjects": [
    {"name": "Pera", "path": "/path/to/pera", "lastOpened": "..."},
    {"name": "Atlas", "path": "/path/to/atlas", "lastOpened": "..."}
  ],
  "restoreLastSession": true,
  "maxRecentProjects": 10
}
```

## Implementation Notes

### State Management:
- Each project maintains independent state
- Auto-save project state every 30 seconds
- Save on project switch or app close

### Performance:
- Lazy load project contents (don't load files until switched to)
- Cache project states in memory
- Limit conversation history to prevent memory issues

### Error Handling:
- Handle missing project directories gracefully
- Validate .f13or files on load
- Provide option to remove invalid projects

## Phase Complete When:
✓ Multiple project tabs display at top
✓ Can open new project via dialog
✓ Can switch between projects with tabs
✓ Ctrl+1, Ctrl+2 shortcuts work
✓ Each project maintains separate state
✓ Project states persist between sessions
✓ .f13or files are created and updated
✓ No console errors
✓ Manual test: Open 3 projects, switch between them, restart app, states restored

## STOP HERE - Do not continue to next phase

## Future Context (for awareness only):
- Phase 5 will involve: Git integration and status indicators
- Phase 6 will involve: Per-project theming system
DO NOT IMPLEMENT PHASES 5-6 IN THIS SESSION

## Recommended Approach:
1. Scout: Review current state management (10 min max)
2. Forge: Design project state architecture (20 min max)
3. Spark: Implement project tabs UI (40 min max)
4. Spark: Build project manager service (40 min max)
5. Sentinel: Test multi-project switching (10 min max)
Total session: ~2 hours

## Avoid These Patterns:
- Don't implement project templates yet
- Don't add project search functionality
- Don't build import/export features
- Don't implement workspace concepts
- Don't add project grouping or categories
- Focus on core multi-project support