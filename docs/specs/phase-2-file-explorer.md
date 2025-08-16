# F13or Phase 2: File Explorer & Basic Editor

## TODO Checklist
- [x] Create file tree components
- [x] Implement expand/collapse folders functionality
- [x] Add file type icons
- [x] Implement file selection and opening
- [ ] Add right-click context menu (deferred for future)
- [x] Create tab management for editor
- [x] Implement syntax highlighting
- [x] Add line numbers to editor
- [x] Create file operations service
- [x] Add save functionality (Ctrl+S)
- [x] Test all Phase 2 requirements

## Session Management
- This is a focused, single-phase task
- Complete only what's specified
- Do not explore adjacent features
- End session after completion criteria met
- **Expected Duration**: 2-3 hours maximum
- **Prerequisites**: Phase 1 must be complete

## Objective
Implement a functional file explorer in the left panel and a basic code viewer/editor in the center panel with syntax highlighting.

## Starting Point
You have a working three-panel layout from Phase 1. Now add file browsing and viewing capabilities.

## Deliverables

### 1. File Explorer (Left Panel)

#### Create New Files:
```
lib/widgets/
├── file_explorer/
│   ├── file_tree.dart
│   ├── file_tree_item.dart
│   └── file_operations.dart
```

#### File Tree Features:
- Display folder/file hierarchy using TreeView pattern
- Expand/collapse folders with arrow icons
- File type icons (use simple Unicode or basic icons)
- Single-click to select and open file in center panel
- Double-click to open in permanent tab
- Right-click context menu with options:
  - New File
  - New Folder
  - Rename
  - Delete
- Show Git status indicators (for now, just placeholders):
  - M (modified) - yellow dot
  - A (added) - green dot
  - D (deleted) - red dot

#### Visual Design:
- VS Code-like styling:
  - Folder icon: 📁 (closed) 📂 (open)
  - File icons based on extension (.dart, .md, .json, etc.)
  - Hover state: background #2a2d2e
  - Selected state: background #094771
  - Indentation: 20px per level

### 2. Center Panel - Code Viewer/Editor

#### Tab Management:
```dart
class EditorTab {
  final String id;
  final String filePath;
  final String fileName;
  final bool isPermanent;
  final bool isModified;
}
```

#### Features:
- Tabbed interface for multiple files
- Show file name in tab with close button (×)
- Indicate unsaved changes with dot (•) before filename
- Implement basic text editing using TextField or TextFormField
- Add syntax highlighting using `flutter_highlight` package
- Support these file types initially:
  - .dart (Dart syntax)
  - .js/.ts (JavaScript/TypeScript)
  - .json (JSON)
  - .md (Markdown)
  - .yaml/.yml (YAML)
  - Plain text for others

#### Editor Features:
- Line numbers on the left
- Basic find (Ctrl+F) within current file
- Save file (Ctrl+S)
- Save all files (Ctrl+Shift+S)
- Font: Use monospace font (Consolas, Monaco, or Courier)
- Font size: 14px default

### 3. File Operations Service

```dart
class FileService {
  Future<List<FileSystemEntity>> getDirectoryContents(String path);
  Future<String> readFile(String path);
  Future<void> writeFile(String path, String content);
  Future<void> createFile(String path);
  Future<void> createFolder(String path);
  Future<void> deleteFile(String path);
  Future<void> renameFile(String oldPath, String newPath);
}
```

### 4. State Management Updates

Update AppState to include:
```dart
class AppState extends ChangeNotifier {
  // ... existing properties
  
  String? currentProjectPath;
  List<EditorTab> openTabs = [];
  EditorTab? activeTab;
  Map<String, String> fileContents = {}; // Cache
  
  void openFile(String path);
  void closeTab(String tabId);
  void saveFile(String path, String content);
  void saveAllFiles();
}
```

## Implementation Notes

### Additional Dependencies:
```yaml
dependencies:
  flutter_highlight: ^0.7.0
  highlight: ^0.7.0
  file_picker: ^8.1.4
```

### Keyboard Shortcuts to Implement:
- Ctrl+S: Save current file
- Ctrl+Shift+S: Save all files
- Ctrl+F: Find in current file
- Ctrl+W: Close current tab

### Performance Considerations:
- Lazy load file tree (don't expand all folders at once)
- Cache file contents in memory
- Limit syntax highlighting to files under 1MB

## Phase Complete When:
✓ File tree displays project directory structure
✓ Can expand/collapse folders
✓ Single-click opens file in editor
✓ Files display with syntax highlighting
✓ Can edit and save files
✓ Tab management works (open, close, switch)
✓ Ctrl+S saves current file
✓ No console errors
✓ Manual test: Open a .dart file, edit it, save it

## STOP HERE - Do not continue to next phase

## Future Context (for awareness only):
- Phase 3 will involve: Claude chat integration in right panel
- Phase 4 will involve: Multi-project tab management
- Phase 5 will involve: Git integration
DO NOT IMPLEMENT PHASES 3-5 IN THIS SESSION

## Recommended Approach:
1. Scout: Review Phase 1 implementation (10 min max)
2. Spark: Build file explorer tree (45 min max)
3. Spark: Implement editor with tabs (45 min max)
4. Sentinel: Test file operations and editing (20 min max)
Total session: ~2 hours

## Avoid These Patterns:
- Don't implement global search yet
- Don't add Claude integration
- Don't implement Git operations (just show placeholders)
- Don't add complex keyboard shortcuts beyond the basics
- Don't implement split pane editing
- Focus only on basic file browsing and editing