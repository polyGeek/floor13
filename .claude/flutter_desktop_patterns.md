# Flutter Desktop Development Patterns for F13or

## Window Management Patterns

### Window Lifecycle Management
```dart
class F13orWindow extends StatefulWidget {
  @override
  _F13orWindowState createState() => _F13orWindowState();
}

class _F13orWindowState extends State<F13orWindow> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWindowState();
  }
  
  @override
  void dispose() {
    _saveWindowState();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _saveApplicationState();
        break;
      case AppLifecycleState.resumed:
        _refreshApplicationState();
        break;
      default:
        break;
    }
  }
}
```

### Multi-Window Support Pattern
```dart
class WindowManager {
  static final Map<String, Window> _windows = {};
  
  static Future<Window> createWindow({
    required String id,
    required Widget child,
    Size? initialSize,
    Offset? initialPosition,
  }) async {
    if (_windows.containsKey(id)) {
      return _windows[id]!;
    }
    
    final window = Window(
      id: id,
      child: child,
      initialSize: initialSize,
      initialPosition: initialPosition,
    );
    
    _windows[id] = window;
    await window.show();
    return window;
  }
  
  static void closeWindow(String id) {
    _windows[id]?.close();
    _windows.remove(id);
  }
}
```

## File System Integration Patterns

### Secure File Operations
```dart
class FileService {
  static const List<String> allowedExtensions = [
    '.dart', '.md', '.json', '.yaml', '.txt'
  ];
  
  Future<String> readFile(String path) async {
    try {
      _validatePath(path);
      final file = File(path);
      
      if (!await file.exists()) {
        throw FileNotFoundException('File not found: $path');
      }
      
      return await file.readAsString();
    } on FileSystemException catch (e) {
      throw FileOperationException('Failed to read file: ${e.message}');
    }
  }
  
  Future<void> writeFile(String path, String content) async {
    try {
      _validatePath(path);
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
    } on FileSystemException catch (e) {
      throw FileOperationException('Failed to write file: ${e.message}');
    }
  }
  
  void _validatePath(String path) {
    final file = File(path);
    final extension = p.extension(path).toLowerCase();
    
    if (!allowedExtensions.contains(extension)) {
      throw UnsupportedFileException('Unsupported file type: $extension');
    }
    
    // Prevent directory traversal attacks
    final canonicalPath = file.absolute.path;
    if (canonicalPath.contains('..')) {
      throw SecurityException('Invalid path: directory traversal detected');
    }
  }
}
```

### File Watching Pattern
```dart
class FileWatcher {
  StreamController<FileEvent>? _eventController;
  StreamSubscription? _watcherSubscription;
  
  Stream<FileEvent> watchDirectory(String path) {
    _eventController = StreamController<FileEvent>();
    
    final watcher = DirectoryWatcher(path);
    _watcherSubscription = watcher.events.listen(
      (WatchEvent event) {
        _eventController!.add(FileEvent(
          type: _convertEventType(event.type),
          path: event.path,
          timestamp: DateTime.now(),
        ));
      },
      onError: (error) {
        _eventController!.addError(error);
      },
    );
    
    return _eventController!.stream;
  }
  
  void dispose() {
    _watcherSubscription?.cancel();
    _eventController?.close();
  }
}
```

## Desktop UI Layout Patterns

### Resizable Panel Layout
```dart
class ResizablePanelLayout extends StatefulWidget {
  final Widget leftPanel;
  final Widget centerPanel;
  final Widget rightPanel;
  final double initialLeftWidth;
  final double initialRightWidth;
  
  @override
  _ResizablePanelLayoutState createState() => _ResizablePanelLayoutState();
}

class _ResizablePanelLayoutState extends State<ResizablePanelLayout> {
  late double leftWidth;
  late double rightWidth;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerWidth = constraints.maxWidth - leftWidth - rightWidth;
        
        return Row(
          children: [
            SizedBox(
              width: leftWidth,
              child: widget.leftPanel,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    leftWidth = (leftWidth + details.delta.dx)
                        .clamp(200.0, constraints.maxWidth * 0.5);
                  });
                },
                child: Container(
                  width: 4,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            Expanded(
              child: widget.centerPanel,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    rightWidth = (rightWidth - details.delta.dx)
                        .clamp(200.0, constraints.maxWidth * 0.5);
                  });
                },
                child: Container(
                  width: 4,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            SizedBox(
              width: rightWidth,
              child: widget.rightPanel,
            ),
          ],
        );
      },
    );
  }
}
```

### Tabbed Interface Pattern
```dart
class F13orTabController extends ChangeNotifier {
  final List<F13orTab> _tabs = [];
  int _activeIndex = 0;
  
  List<F13orTab> get tabs => List.unmodifiable(_tabs);
  int get activeIndex => _activeIndex;
  F13orTab? get activeTab => _tabs.isEmpty ? null : _tabs[_activeIndex];
  
  void addTab(F13orTab tab) {
    _tabs.add(tab);
    _activeIndex = _tabs.length - 1;
    notifyListeners();
  }
  
  void closeTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    
    _tabs.removeAt(index);
    if (_activeIndex >= _tabs.length) {
      _activeIndex = _tabs.length - 1;
    }
    if (_activeIndex < 0) _activeIndex = 0;
    
    notifyListeners();
  }
  
  void setActiveTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _activeIndex = index;
      notifyListeners();
    }
  }
}

class F13orTabBar extends StatelessWidget {
  final F13orTabController controller;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<F13orTabController>(
      builder: (context, controller, child) {
        return Container(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.tabs.length,
            itemBuilder: (context, index) {
              final tab = controller.tabs[index];
              final isActive = index == controller.activeIndex;
              
              return GestureDetector(
                onTap: () => controller.setActiveTab(index),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? Theme.of(context).primaryColor 
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tab.icon, size: 16),
                      SizedBox(width: 8),
                      Text(tab.title),
                      if (tab.isClosable) ...[
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => controller.closeTab(index),
                          child: Icon(Icons.close, size: 16),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
```

## Keyboard Shortcut Patterns

### Platform-Aware Shortcuts
```dart
class ShortcutManager {
  static Map<LogicalKeySet, Intent> get shortcuts {
    final isApple = Platform.isMacOS;
    final modifier = isApple ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;
    
    return {
      LogicalKeySet(modifier, LogicalKeyboardKey.keyN): NewFileIntent(),
      LogicalKeySet(modifier, LogicalKeyboardKey.keyO): OpenFileIntent(),
      LogicalKeySet(modifier, LogicalKeyboardKey.keyS): SaveFileIntent(),
      LogicalKeySet(modifier, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyS): SaveAllIntent(),
      LogicalKeySet(modifier, LogicalKeyboardKey.keyW): CloseTabIntent(),
      LogicalKeySet(modifier, LogicalKeyboardKey.keyT): NewTabIntent(),
      LogicalKeySet(LogicalKeyboardKey.f5): RefreshIntent(),
      
      // Project switching
      LogicalKeySet(modifier, LogicalKeyboardKey.digit1): SwitchProjectIntent(0),
      LogicalKeySet(modifier, LogicalKeyboardKey.digit2): SwitchProjectIntent(1),
      LogicalKeySet(modifier, LogicalKeyboardKey.digit3): SwitchProjectIntent(2),
      
      // Navigation
      LogicalKeySet(modifier, LogicalKeyboardKey.keyE): ToggleExplorerIntent(),
      LogicalKeySet(modifier, LogicalKeyboardKey.keyJ): FocusChatIntent(),
    };
  }
}

class F13orShortcuts extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: ShortcutManager.shortcuts,
      child: Actions(
        actions: {
          NewFileIntent: NewFileAction(),
          OpenFileIntent: OpenFileAction(),
          SaveFileIntent: SaveFileAction(),
          // ... more actions
        },
        child: child,
      ),
    );
  }
}
```

## Context Menu Pattern

### Right-Click Context Menus
```dart
class ContextMenuRegion extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItem> items;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      child: child,
    );
  }
  
  void _showContextMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: items.map((item) => PopupMenuItem(
        value: item.action,
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 16),
              SizedBox(width: 8),
            ],
            Text(item.label),
            if (item.shortcut != null) ...[
              Spacer(),
              Text(
                item.shortcut!,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      )).toList(),
    ).then((action) {
      if (action != null) {
        action();
      }
    });
  }
}
```

## Performance Optimization Patterns

### Virtual List for Large Datasets
```dart
class VirtualListView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double itemHeight;
  
  @override
  _VirtualListViewState createState() => _VirtualListViewState();
}

class _VirtualListViewState extends State<VirtualListView> {
  final ScrollController _scrollController = ScrollController();
  late int _firstVisibleIndex;
  late int _lastVisibleIndex;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleHeight = constraints.maxHeight;
        final visibleCount = (visibleHeight / widget.itemHeight).ceil() + 2;
        
        return ListView.builder(
          controller: _scrollController,
          itemCount: widget.itemCount,
          itemExtent: widget.itemHeight,
          itemBuilder: (context, index) {
            if (index < _firstVisibleIndex || index > _lastVisibleIndex) {
              return SizedBox(height: widget.itemHeight);
            }
            return widget.itemBuilder(context, index);
          },
        );
      },
    );
  }
}
```

### Efficient State Management for Large Apps
```dart
// Using Riverpod for efficient state management
final projectsProvider = StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  return ProjectsNotifier();
});

final activeProjectProvider = Provider<Project?>((ref) {
  final projects = ref.watch(projectsProvider);
  final activeIndex = ref.watch(activeProjectIndexProvider);
  return activeIndex < projects.length ? projects[activeIndex] : null;
});

final fileTreeProvider = FutureProvider.family<List<FileNode>, String>((ref, projectPath) async {
  // Efficiently load file tree only when needed
  return FileTreeService().loadFileTree(projectPath);
});

// Debounced file watching
final fileWatcherProvider = StreamProvider.family<FileEvent, String>((ref, path) {
  return FileWatcherService().watchDirectory(path)
      .debounceTime(Duration(milliseconds: 100));
});
```

## Platform Integration Patterns

### Native File Dialog Integration
```dart
class NativeFileService {
  static Future<String?> openFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
      );
      
      return result?.files.single.path;
    } catch (e) {
      Logger.error('File picker error: $e');
      return null;
    }
  }
  
  static Future<String?> saveFile({
    String? fileName,
    List<String>? allowedExtensions,
  }) async {
    try {
      return await FilePicker.platform.saveFile(
        fileName: fileName,
        allowedExtensions: allowedExtensions,
      );
    } catch (e) {
      Logger.error('Save file error: $e');
      return null;
    }
  }
}
```

### Drag and Drop Support
```dart
class DragDropRegion extends StatefulWidget {
  final Widget child;
  final Function(List<String>) onFilesDropped;
  
  @override
  _DragDropRegionState createState() => _DragDropRegionState();
}

class _DragDropRegionState extends State<DragDropRegion> {
  bool _isDragging = false;
  
  @override
  Widget build(BuildContext context) {
    return DragTarget<List<String>>(
      onWillAccept: (data) {
        setState(() => _isDragging = true);
        return data != null;
      },
      onLeave: (_) {
        setState(() => _isDragging = false);
      },
      onAccept: (files) {
        setState(() => _isDragging = false);
        widget.onFilesDropped(files);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: _isDragging
              ? BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                )
              : null,
          child: widget.child,
        );
      },
    );
  }
}
```

## Error Handling and Recovery Patterns

### Graceful Error Recovery
```dart
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? fallbackBuilder;
  
  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;
  
  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      setState(() {
        _errorDetails = details;
      });
      Logger.error('Widget error: ${details.exception}');
    };
  }
  
  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return widget.fallbackBuilder?.call(_errorDetails!) ??
          ErrorWidget(_errorDetails!.exception);
    }
    
    return widget.child;
  }
  
  void reset() {
    setState(() {
      _errorDetails = null;
    });
  }
}
```

### Auto-Save and Recovery
```dart
class AutoSaveManager {
  static const Duration _saveInterval = Duration(seconds: 30);
  Timer? _autoSaveTimer;
  final Map<String, String> _pendingChanges = {};
  
  void startAutoSave() {
    _autoSaveTimer = Timer.periodic(_saveInterval, (_) {
      _performAutoSave();
    });
  }
  
  void trackChange(String filePath, String content) {
    _pendingChanges[filePath] = content;
  }
  
  Future<void> _performAutoSave() async {
    for (final entry in _pendingChanges.entries) {
      try {
        await _saveToTempFile(entry.key, entry.value);
      } catch (e) {
        Logger.warning('Auto-save failed for ${entry.key}: $e');
      }
    }
    _pendingChanges.clear();
  }
  
  Future<void> _saveToTempFile(String originalPath, String content) async {
    final tempPath = '$originalPath.autosave';
    await File(tempPath).writeAsString(content);
  }
  
  void dispose() {
    _autoSaveTimer?.cancel();
  }
}
```

## Testing Patterns

### Widget Testing for Desktop
```dart
testWidgets('File explorer handles keyboard navigation', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: FileExplorerWidget(),
  ));
  
  // Test keyboard navigation
  await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
  await tester.pump();
  
  expect(find.byType(FileNodeWidget), findsAtLeastNWidgets(1));
  
  // Test context menu
  await tester.tap(find.byType(FileNodeWidget).first, 
                   buttons: kSecondaryButton);
  await tester.pumpAndSettle();
  
  expect(find.byType(PopupMenuButton), findsOneWidget);
});
```

### Integration Testing
```dart
void main() {
  group('F13or Integration Tests', () {
    testWidgets('Complete project workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Test project creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'Test Project');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      
      // Test file operations
      await tester.tap(find.byIcon(Icons.create_new_folder));
      await tester.pumpAndSettle();
      
      // Verify project state
      expect(find.text('Test Project'), findsOneWidget);
    });
  });
}
```

These patterns provide a solid foundation for building F13or with proper desktop-native behavior, performance optimization, and maintainable architecture.