# F13or Phase 5: Git Integration

## Session Management
- This is a focused, single-phase task
- Complete only what's specified
- Do not explore adjacent features
- End session after completion criteria met
- **Expected Duration**: 2-3 hours maximum
- **Prerequisites**: Phases 1-4 must be complete

## Objective
Add Git integration including status indicators in file tree, branch management, and a commit interface in the bottom panel.

## Starting Point
You have a working multi-project IDE. Now add Git awareness and basic Git operations.

## Deliverables

### 1. Bottom Panel Addition

#### Create New Files:
```
lib/widgets/git_panel/
├── git_status_bar.dart
├── git_commit_interface.dart
├── branch_switcher.dart
└── git_diff_viewer.dart

lib/services/
└── git_service.dart

lib/models/
└── git_status.dart
```

### 2. Layout Update

Modify main screen to include collapsible bottom panel:
- Height: 200px default (resizable)
- Can be toggled with button or Ctrl+`
- Contains two tabs: "Git" and "Terminal Output"
- Git tab is primary focus for this phase

### 3. Git Service Implementation

```dart
class GitService {
  // Use Process.run() to execute git commands
  
  // Status operations
  Future<GitStatus> getStatus(String projectPath);
  Future<List<String>> getModifiedFiles(String projectPath);
  Future<String> getCurrentBranch(String projectPath);
  Future<List<String>> getAllBranches(String projectPath);
  
  // Basic operations
  Future<void> stageFile(String projectPath, String filePath);
  Future<void> stageAll(String projectPath);
  Future<void> unstageFile(String projectPath, String filePath);
  Future<void> commit(String projectPath, String message);
  Future<void> push(String projectPath);
  Future<void> pull(String projectPath);
  
  // Branch operations
  Future<void> checkoutBranch(String projectPath, String branchName);
  Future<void> createBranch(String projectPath, String branchName);
  
  // Diff operations
  Future<String> getDiff(String projectPath, String filePath);
  Future<String> getStagedDiff(String projectPath);
}

class GitStatus {
  final String branch;
  final bool hasChanges;
  final List<GitFile> modifiedFiles;
  final List<GitFile> stagedFiles;
  final List<GitFile> untrackedFiles;
  final int ahead;
  final int behind;
}

class GitFile {
  final String path;
  final GitFileStatus status; // modified, added, deleted, renamed
  final bool isStaged;
}
```

### 4. File Tree Git Indicators

Update file tree items to show Git status:
- **Modified** (M): Yellow dot or 'M' badge
- **Added** (A): Green dot or '+' badge  
- **Deleted** (D): Red dot or '-' badge
- **Untracked** (?): Gray dot or '?' badge
- **Ignored**: Dimmed text color

Position indicators to the right of filename.

### 5. Git Status Bar (Bottom Panel)

#### Layout:
```
[Branch: main ↑2 ↓0] [Changes: 5 files] [Stage All] [Commit] [Push] [Pull]
```

#### Components:
- Current branch with dropdown to switch
- Commits ahead/behind remote
- Number of changed files
- Quick action buttons

### 6. Commit Interface

#### Two-column layout in Git tab:
**Left Column - File Changes:**
- List of changed files with checkboxes
- Check to stage, uncheck to unstage
- Show file status (M, A, D, ?)
- "Stage All" / "Unstage All" buttons
- Click file to see diff in right column

**Right Column - Commit Area:**
- Commit message input (multi-line)
- Character count
- Commit button (disabled if no message or no staged files)
- Recent commits list (last 5)
- Suggested commit message from Claude (if detected)

### 7. Branch Switcher

#### Dropdown Features:
- Show current branch
- List all local branches
- Indicate if branch has uncommitted changes
- Create new branch option
- Checkout branch on selection
- Show remote branches separately

### 8. Diff Viewer

Simple diff display:
- Show file changes in familiar diff format
- Green background for additions
- Red background for deletions
- Line numbers
- Syntax highlighting maintained

### 9. Claude Integration

When Claude suggests a commit message:
1. Detect pattern like "commit message:" or "git commit -m"
2. Extract the message
3. Add button in chat: "Use as commit message"
4. Click fills the commit message field in Git panel

### 10. Terminal Output Tab

Basic output display for Git commands:
- Show command being executed
- Display output/errors
- Scrollable history
- Clear button

## Implementation Notes

### Git Command Execution:
```dart
Future<ProcessResult> runGitCommand(String projectPath, List<String> args) async {
  return await Process.run(
    'git',
    args,
    workingDirectory: projectPath,
  );
}
```

### Auto-refresh:
- Poll Git status every 5 seconds when project is active
- Refresh immediately after Git operations
- Update file tree indicators in real-time

### Error Handling:
- Check if directory is a Git repository
- Handle Git command failures gracefully
- Show errors in terminal output tab
- Provide helpful messages for common issues

## Phase Complete When:
✓ Bottom panel shows with Git tab
✓ File tree shows Git status indicators
✓ Can see current branch and switch branches
✓ Can stage/unstage files
✓ Can write commit message and commit
✓ Git operations show in terminal output
✓ Claude commit messages can be used
✓ No console errors
✓ Manual test: Make changes, stage, commit successfully

## STOP HERE - Do not continue to next phase

## Future Context (for awareness only):
- Phase 6 will involve: Per-project theming system
- Future phases: Templates, advanced Git features, settings
DO NOT IMPLEMENT PHASE 6 IN THIS SESSION

## Recommended Approach:
1. Scout: Check Git command availability (10 min max)
2. Forge: Design Git state management (15 min max)
3. Spark: Build Git service and status polling (40 min max)
4. Spark: Implement bottom panel UI (40 min max)
5. Sentinel: Test Git operations flow (15 min max)
Total session: ~2 hours

## Avoid These Patterns:
- Don't implement complex Git operations (merge, rebase, cherry-pick)
- Don't add Git history visualization
- Don't implement conflict resolution UI
- Don't add Git LFS support
- Don't build credential management
- Focus on basic Git workflow: status, stage, commit, push, pull