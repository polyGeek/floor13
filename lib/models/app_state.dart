import 'package:flutter/material.dart';
import 'dart:io';
import 'project.dart';
import 'editor_tab.dart';
import 'claude_settings.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  Project? _activeProject;
  final List<Project> _openProjects = [];
  final List<EditorTab> _openTabs = [];
  EditorTab? _activeTab;
  final Map<String, String> _fileContents = {};
  String? _currentProjectPath;
  final StorageService _storageService = StorageService();
  ClaudeSettings _claudeSettings = ClaudeSettings();

  Project? get activeProject => _activeProject;
  List<Project> get openProjects => List.unmodifiable(_openProjects);
  List<EditorTab> get openTabs => List.unmodifiable(_openTabs);
  EditorTab? get activeTab => _activeTab;
  String? get currentProjectPath => _currentProjectPath;
  ClaudeSettings get claudeSettings => _claudeSettings;
  bool get hasClaudeApiKey => _claudeSettings.apiKey != null && _claudeSettings.apiKey!.isNotEmpty;
  
  AppState() {
    _loadLastSession();
    _loadClaudeSettings();
  }
  
  Future<void> _loadLastSession() async {
    try {
      final settings = await _storageService.loadSettings();
      final restoreLastSession = settings['restoreLastSession'] as bool? ?? true;
      
      if (restoreLastSession) {
        final recentProjects = await _storageService.loadRecentProjects();
        for (final project in recentProjects) {
          // Verify the project directory still exists
          final dir = Directory(project.path);
          if (await dir.exists()) {
            _openProjects.add(project);
            if (_activeProject == null) {
              _activeProject = project;
              _currentProjectPath = project.path;
              
              // Restore open files for the active project
              _restoreOpenFiles(project);
            }
          }
        }
        
        if (_openProjects.isNotEmpty) {
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading last session: $e');
    }
  }
  
  Future<void> _restoreOpenFiles(Project project) async {
    try {
      for (final filePath in project.openFiles) {
        final file = File(filePath);
        if (await file.exists()) {
          openFile(filePath);
        }
      }
      
      // Set the active tab
      if (project.activeFile != null) {
        final activeTab = _openTabs.firstWhere(
          (tab) => tab.filePath == project.activeFile,
          orElse: () => _openTabs.isNotEmpty ? _openTabs.first : _openTabs.first,
        );
        if (_openTabs.contains(activeTab)) {
          _activeTab = activeTab;
        }
      }
    } catch (e) {
      debugPrint('Error restoring open files: $e');
    }
  }
  
  Future<void> saveSession() async {
    try {
      // Update projects with their open files before saving
      final updatedProjects = _openProjects.map((project) {
        if (project.id == _activeProject?.id) {
          return project.copyWith(
            openFiles: _openTabs.map((tab) => tab.filePath).toList(),
            activeFile: _activeTab?.filePath,
          );
        }
        return project;
      }).toList();
      
      await _storageService.saveRecentProjects(updatedProjects);
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  void openProject(String path) {
    // Get project name from path
    final separator = Platform.isWindows ? '\\' : '/';
    final pathParts = path.split(separator);
    final projectName = pathParts.isNotEmpty ? pathParts.last : 'Unknown';
    
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: projectName,
      path: path,
      createdAt: DateTime.now(),
      lastOpened: DateTime.now(),
    );
    
    if (!_openProjects.any((p) => p.path == path)) {
      _openProjects.add(project);
      _activeProject = project;
      _currentProjectPath = path;
      saveSession();  // Save session when opening a new project
      notifyListeners();
    } else {
      switchProject(_openProjects.firstWhere((p) => p.path == path).id);
    }
  }

  void closeProject(String id) {
    _openProjects.removeWhere((p) => p.id == id);
    
    if (_activeProject?.id == id) {
      _activeProject = _openProjects.isNotEmpty ? _openProjects.last : null;
      _currentProjectPath = _activeProject?.path;
      // Close all tabs when closing project
      _openTabs.clear();
      _activeTab = null;
    }
    
    saveSession();  // Save session when closing a project
    notifyListeners();
  }

  void switchProject(String id) {
    // First save current project's state
    if (_activeProject != null) {
      final index = _openProjects.indexWhere((p) => p.id == _activeProject!.id);
      if (index != -1) {
        _openProjects[index] = _activeProject!.copyWith(
          openFiles: _openTabs.map((tab) => tab.filePath).toList(),
          activeFile: _activeTab?.filePath,
        );
      }
    }
    
    final project = _openProjects.firstWhere(
      (p) => p.id == id,
      orElse: () => _openProjects.first,
    );
    
    if (project != _activeProject) {
      _activeProject = project;
      _currentProjectPath = project.path;
      // Clear tabs when switching projects
      _openTabs.clear();
      _activeTab = null;
      
      // Restore the new project's open files
      _restoreOpenFiles(project);
      
      saveSession();
      notifyListeners();
    }
  }

  void openFile(String path) {
    // Get file name from path
    final separator = Platform.isWindows ? '\\' : '/';
    final pathParts = path.split(separator);
    final fileName = pathParts.isNotEmpty ? pathParts.last : 'Unknown';
    
    // Check if file is already open
    final existingTab = _openTabs.firstWhere(
      (tab) => tab.filePath == path,
      orElse: () => EditorTab(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: path,
        fileName: fileName,
        isPermanent: false,
      ),
    );

    if (!_openTabs.contains(existingTab)) {
      // Read file content
      final file = File(path);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final newTab = existingTab.copyWith(content: content);
        _openTabs.add(newTab);
        _activeTab = newTab;
        _fileContents[path] = content;
      }
    } else {
      _activeTab = existingTab;
    }
    
    // Save session when opening a file
    saveSession();
    notifyListeners();
  }

  void closeTab(String tabId) {
    _openTabs.removeWhere((tab) => tab.id == tabId);
    
    if (_activeTab?.id == tabId) {
      _activeTab = _openTabs.isNotEmpty ? _openTabs.last : null;
    }
    
    // Save session when closing a tab
    saveSession();
    notifyListeners();
  }

  void saveFile(String path, String content) {
    final file = File(path);
    file.writeAsStringSync(content);
    
    // Update tab to mark as not modified
    final tabIndex = _openTabs.indexWhere((tab) => tab.filePath == path);
    if (tabIndex != -1) {
      _openTabs[tabIndex] = _openTabs[tabIndex].copyWith(
        isModified: false,
        content: content,
      );
    }
    
    _fileContents[path] = content;
    notifyListeners();
  }

  void updateFileContent(String path, String content) {
    final tabIndex = _openTabs.indexWhere((tab) => tab.filePath == path);
    if (tabIndex != -1) {
      final originalContent = _fileContents[path] ?? '';
      _openTabs[tabIndex] = _openTabs[tabIndex].copyWith(
        isModified: content != originalContent,
        content: content,
      );
      notifyListeners();
    }
  }

  void saveCurrentFile() {
    if (_activeTab != null && _activeTab!.isModified) {
      saveFile(_activeTab!.filePath, _activeTab!.content);
    }
  }

  void saveAllFiles() {
    for (final tab in _openTabs) {
      if (tab.isModified) {
        saveFile(tab.filePath, tab.content);
      }
    }
  }

  void setActiveTab(String tabId) {
    _activeTab = _openTabs.firstWhere(
      (tab) => tab.id == tabId,
      orElse: () => _openTabs.first,
    );
    notifyListeners();
  }

  Future<void> _loadClaudeSettings() async {
    try {
      final settings = await _storageService.loadSettings();
      if (settings['claudeSettings'] != null) {
        _claudeSettings = ClaudeSettings.fromJson(settings['claudeSettings'] as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading Claude settings: $e');
    }
  }

  Future<void> saveClaudeApiKey(String apiKey) async {
    _claudeSettings = _claudeSettings.copyWith(apiKey: apiKey);
    
    final settings = await _storageService.loadSettings();
    settings['claudeSettings'] = _claudeSettings.toJson();
    await _storageService.saveSettings(settings);
    
    notifyListeners();
  }

  Future<void> updateClaudeSettings(ClaudeSettings newSettings) async {
    _claudeSettings = newSettings;
    
    final settings = await _storageService.loadSettings();
    settings['claudeSettings'] = _claudeSettings.toJson();
    await _storageService.saveSettings(settings);
    
    notifyListeners();
  }
}