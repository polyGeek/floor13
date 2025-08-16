# F13or Development - Next Steps

## Current Status (Session End: 2025-08-16)

### Completed Features
✅ **Phase 1: Core Infrastructure**
- Three-panel resizable layout (Explorer, Editor, Claude)
- Dark VS Code theme
- Project and AppState models
- Storage service for settings
- Window configuration

✅ **Phase 2: File Explorer & Editor**
- File tree with expand/collapse functionality
- File type icons
- Tab management for multiple files
- Syntax highlighting for multiple languages
- Line numbers
- Basic file operations (open, save, close)

✅ **Additional Features**
- Project persistence (remembers open projects on restart)
- Open files persistence (remembers which files were open per project)
- Auto-restore last session
- Fixed setState during build errors
- Improved file tree loading with proper error handling

## Small To-Dos (Priority)

### 1. Editor Text Alignment Issue
- **Problem**: Short files display text vertically centered instead of at the top
- **Fix**: Adjust the SingleChildScrollView or container alignment in code_editor.dart

### 2. Project Bar Redesign
- **Move + button**: Relocate the "Open Project" button to far-left of the project bar
- **Layout**: [+] [Project Tab 1] [Project Tab 2] ... [Contextual Tools]

### 3. Add Contextual Tools to Project Bar
- **Save File Icon**: Single-click saves current file, double-click saves all files
- **Undo Icon**: Ctrl+Z functionality
- **Redo Icon**: Ctrl+Y functionality
- **Display**: Use icon buttons with tooltips

### 4. Keyboard Shortcuts
- **Ctrl+S**: Save current file (currently partially implemented)
- **Ctrl+Shift+S**: Save all files (currently partially implemented)
- **Verify**: Ensure these work globally, not just in editor

### 5. Fixed-Width Font Issue (Systematic Fix)
- **Current Problem**: Font still not rendering as fixed-width despite multiple attempts
- **Previous Attempts**:
  - Tried specifying 'Consolas, Menlo, Monaco' - didn't work
  - Changed to 'monospace' - still not working properly
- **Recommended Solution**: 
  - Install and use Google Fonts package
  - Explicitly load a monospace font like 'Roboto Mono' or 'Fira Code'
  - Apply consistently to both editor and line numbers

## Next Major Phases

### Phase 3: Claude Chat Integration (Not Started)
- Implement chat interface in right panel
- Message bubbles with markdown rendering
- Code block extraction and insertion
- Conversation management (multiple tabs)
- API key management

### Phase 4: Enhanced Multi-Project Support (Partially Complete)
- Project switching already works
- Need: Project templates
- Need: Project search/filter
- Need: Recent projects quick access

### Phase 5: Git Integration (Not Started)
- Git status indicators in file tree
- Bottom panel for Git operations
- Commit interface
- Branch switching
- Push/pull functionality

### Phase 6: Theming System (Not Started)
- Per-project themes for visual distinction
- 6-8 built-in themes
- Theme persistence per project
- Custom theme creation

## Technical Debt & Improvements

### Performance
- Optimize file tree for large projects
- Implement virtual scrolling for long files
- Add file content caching

### Error Handling
- Better error messages for file operations
- Recovery from corrupted settings
- Graceful handling of missing projects

### UI/UX
- Add file search (Ctrl+P)
- Global search across project (Ctrl+Shift+F)
- Split editor view
- Minimap for code navigation

## Known Issues
1. Scrolling works but could be smoother
2. No right-click context menus yet
3. No file/folder creation from UI (only opening existing)
4. No rename/delete operations from UI

## Development Environment
- Flutter SDK: Windows installation
- Target Platform: Windows Desktop (primary), macOS/Linux (future)
- State Management: Provider
- Key Packages:
  - split_view: Panel resizing
  - flutter_highlight: Syntax highlighting
  - window_manager: Window control
  - file_picker: File/folder selection

## Session Notes for Next Developer
When starting the next session:
1. Read this file first
2. Check CLAUDE.md for project context
3. Run `flutter pub get` if needed
4. Test current build with `flutter run -d windows`
5. Start with the "Small To-Dos" section above

The codebase is well-structured with clear separation:
- `/lib/models/` - Data models
- `/lib/services/` - Business logic
- `/lib/widgets/` - UI components
- `/lib/screens/` - Main screens
- `/docs/specs/` - Phase specifications

Good luck!