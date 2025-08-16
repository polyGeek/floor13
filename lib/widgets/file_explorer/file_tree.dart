import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import 'file_tree_item.dart';

class FileTree extends StatefulWidget {
  final Function(String) onFileSelected;
  final Function(String) onFileDoubleClick;

  const FileTree({
    super.key,
    required this.onFileSelected,
    required this.onFileDoubleClick,
  });

  @override
  State<FileTree> createState() => _FileTreeState();
}

class _FileTreeState extends State<FileTree> {
  List<FileSystemEntity> _rootItems = [];
  String? _currentProjectPath;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadProject();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndLoadProject();
  }
  
  void _checkAndLoadProject() {
    final appState = context.read<AppState>();
    // Reload if project changed
    if (appState.activeProject?.path != _currentProjectPath) {
      _currentProjectPath = appState.activeProject?.path;
      if (_currentProjectPath != null) {
        _loadRootItems();
      } else {
        setState(() {
          _rootItems = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRootItems() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _rootItems = [];
    });
    
    final appState = context.read<AppState>();
    if (appState.activeProject != null) {
      debugPrint('Loading files from: ${appState.activeProject!.path}');
      try {
        final directory = Directory(appState.activeProject!.path);
        if (await directory.exists()) {
          final contents = await directory.list().toList();
          debugPrint('Found ${contents.length} items');
          
          // If the directory is empty, that's valid - just show empty
          if (contents.isEmpty) {
            if (mounted) {
              setState(() {
                _rootItems = [];
                _isLoading = false;
              });
            }
            return;
          }
          
          contents.sort((a, b) {
            if (a is Directory && b is File) return -1;
            if (a is File && b is Directory) return 1;
            return a.path.toLowerCase().compareTo(b.path.toLowerCase());
          });
          
          if (mounted) {
            setState(() {
              _rootItems = contents;
              _isLoading = false;
            });
          }
        } else {
          debugPrint('Directory does not exist: ${appState.activeProject!.path}');
          if (mounted) {
            setState(() {
              _errorMessage = 'Directory not found';
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        debugPrint('Error loading root items: $e');
        if (mounted) {
          setState(() {
            _errorMessage = 'Error: $e';
            _isLoading = false;
          });
        }
      }
    } else {
      debugPrint('No active project');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        // Check if we need to reload
        if (appState.activeProject?.path != _currentProjectPath && appState.activeProject != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndLoadProject();
          });
        }
        
        if (appState.activeProject == null) {
          return Center(
            child: Text(
              'No folder opened',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          );
        }
        
        if (_errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[400],
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadRootItems,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007ACC)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading project...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }
        
        if (_rootItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  color: Colors.grey[600],
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Empty folder',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: _rootItems.length,
          itemBuilder: (context, index) {
            return FileTreeItem(
              entity: _rootItems[index],
              indentLevel: 0,
              onFileSelected: widget.onFileSelected,
              onFileDoubleClick: widget.onFileDoubleClick,
            );
          },
        );
      },
    );
  }
}