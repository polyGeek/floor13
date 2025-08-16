import 'package:flutter/material.dart';
import 'dart:io';
import 'project.dart';
import 'editor_tab.dart';
import 'claude_settings.dart';
import 'conversation.dart';
import 'message.dart';
import '../services/storage_service.dart';
import '../services/claude_service.dart';

class AppState extends ChangeNotifier {
  Project? _activeProject;
  final List<Project> _openProjects = [];
  final List<EditorTab> _openTabs = [];
  EditorTab? _activeTab;
  final Map<String, String> _fileContents = {};
  String? _currentProjectPath;
  final StorageService _storageService = StorageService();
  ClaudeSettings _claudeSettings = ClaudeSettings();
  
  // Claude conversation state
  final List<Conversation> _conversations = [];
  Conversation? _activeConversation;
  ClaudeService? _claudeService;

  Project? get activeProject => _activeProject;
  List<Project> get openProjects => List.unmodifiable(_openProjects);
  List<EditorTab> get openTabs => List.unmodifiable(_openTabs);
  EditorTab? get activeTab => _activeTab;
  String? get currentProjectPath => _currentProjectPath;
  ClaudeSettings get claudeSettings => _claudeSettings;
  bool get hasClaudeApiKey => _claudeSettings.apiKey != null && _claudeSettings.apiKey!.isNotEmpty;
  
  // Claude getters
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  Conversation? get activeConversation => _activeConversation;
  
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
      debugPrint('AppState: Loading Claude settings...');
      final settings = await _storageService.loadSettings();
      if (settings['claudeSettings'] != null) {
        _claudeSettings = ClaudeSettings.fromJson(settings['claudeSettings'] as Map<String, dynamic>);
        debugPrint('AppState: Claude settings loaded, API key present: ${_claudeSettings.apiKey != null}');
        if (_claudeSettings.apiKey != null && _claudeSettings.apiKey!.isNotEmpty) {
          debugPrint('AppState: Creating Claude service with API key');
          _claudeService = ClaudeService(settings: _claudeSettings);
          // Create initial conversation if none exists
          if (_conversations.isEmpty) {
            debugPrint('AppState: Creating initial conversation');
            createNewConversation();
          }
        }
        notifyListeners();
      } else {
        debugPrint('AppState: No Claude settings found');
      }
    } catch (e) {
      debugPrint('Error loading Claude settings: $e');
    }
  }

  Future<void> saveClaudeApiKey(String apiKey) async {
    debugPrint('AppState: Saving Claude API key, length: ${apiKey.length}');
    _claudeSettings = _claudeSettings.copyWith(apiKey: apiKey);
    _claudeService = ClaudeService(settings: _claudeSettings);
    debugPrint('AppState: Claude service created');
    
    final settings = await _storageService.loadSettings();
    settings['claudeSettings'] = _claudeSettings.toJson();
    await _storageService.saveSettings(settings);
    debugPrint('AppState: Settings saved');
    
    // Create initial conversation when API key is set
    if (_conversations.isEmpty) {
      debugPrint('AppState: Creating initial conversation after API key save');
      createNewConversation();
    }
    
    notifyListeners();
  }

  Future<void> updateClaudeSettings(ClaudeSettings newSettings) async {
    _claudeSettings = newSettings;
    _claudeService = ClaudeService(settings: _claudeSettings);
    
    final settings = await _storageService.loadSettings();
    settings['claudeSettings'] = _claudeSettings.toJson();
    await _storageService.saveSettings(settings);
    
    notifyListeners();
  }

  // Claude conversation methods
  void createNewConversation() {
    final conversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Chat ${_conversations.length + 1}',
      messages: [],
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
    );
    
    _conversations.add(conversation);
    _activeConversation = conversation;
    notifyListeners();
  }
  
  void switchConversation(String conversationId) {
    _activeConversation = _conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => _conversations.first,
    );
    notifyListeners();
  }
  
  void closeConversation(String conversationId) {
    _conversations.removeWhere((c) => c.id == conversationId);
    
    if (_activeConversation?.id == conversationId) {
      _activeConversation = _conversations.isNotEmpty ? _conversations.last : null;
    }
    
    notifyListeners();
  }
  
  Future<void> sendMessageToClaude(String message) async {
    debugPrint('AppState: sendMessageToClaude called with message: $message');
    debugPrint('AppState: _claudeService is null? ${_claudeService == null}');
    debugPrint('AppState: _activeConversation is null? ${_activeConversation == null}');
    
    if (_claudeService == null || _activeConversation == null) {
      debugPrint('Claude service or conversation not initialized');
      if (_claudeService == null) {
        debugPrint('AppState: Claude service is null - API key may not be set');
      }
      if (_activeConversation == null) {
        debugPrint('AppState: No active conversation');
      }
      return;
    }
    
    // Add user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
      tokenCount: _claudeService!.estimateTokens(message),
    );
    
    final updatedMessages = List<Message>.from(_activeConversation!.messages)
      ..add(userMessage);
    
    _activeConversation = _activeConversation!.copyWith(
      messages: updatedMessages,
      lastMessageAt: DateTime.now(),
    );
    notifyListeners();
    
    try {
      // Send to Claude API
      final response = await _claudeService!.sendMessage(
        userMessage: message,
        conversationHistory: _activeConversation!.messages,
      );
      
      // Add Claude's response
      final allMessages = List<Message>.from(_activeConversation!.messages)
        ..add(response);
      
      _activeConversation = _activeConversation!.copyWith(
        messages: allMessages,
        lastMessageAt: DateTime.now(),
        totalTokens: _activeConversation!.totalTokens + 
          (userMessage.tokenCount ?? 0) + 
          (response.tokenCount ?? 0),
      );
      
      // Update conversation title if it's the first exchange
      if (_activeConversation!.messages.length == 2) {
        final title = message.length > 50 
          ? '${message.substring(0, 50)}...' 
          : message;
        _activeConversation = _activeConversation!.copyWith(title: title);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error sending message to Claude: $e');
      
      // Add error message
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      final allMessages = List<Message>.from(_activeConversation!.messages)
        ..add(errorMessage);
      
      _activeConversation = _activeConversation!.copyWith(
        messages: allMessages,
        lastMessageAt: DateTime.now(),
      );
      
      notifyListeners();
    }
  }
  
  Stream<String> streamMessageToClaude(String message) async* {
    if (_claudeService == null || _activeConversation == null) {
      debugPrint('Claude service or conversation not initialized');
      return;
    }
    
    // Add user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
      tokenCount: _claudeService!.estimateTokens(message),
    );
    
    final updatedMessages = List<Message>.from(_activeConversation!.messages)
      ..add(userMessage);
    
    _activeConversation = _activeConversation!.copyWith(
      messages: updatedMessages,
      lastMessageAt: DateTime.now(),
    );
    notifyListeners();
    
    // Add placeholder for streaming response
    final streamingMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isStreaming: true,
    );
    
    final messagesWithStreaming = List<Message>.from(_activeConversation!.messages)
      ..add(streamingMessage);
    
    _activeConversation = _activeConversation!.copyWith(
      messages: messagesWithStreaming,
      lastMessageAt: DateTime.now(),
    );
    notifyListeners();
    
    try {
      String fullContent = '';
      await for (final chunk in _claudeService!.streamMessage(
        userMessage: message,
        conversationHistory: updatedMessages,
      )) {
        fullContent = chunk;
        
        // Update streaming message
        final lastIndex = _activeConversation!.messages.length - 1;
        final updatedStreamingMessage = streamingMessage.copyWith(
          content: fullContent,
        );
        
        final updatedMessages = List<Message>.from(_activeConversation!.messages);
        updatedMessages[lastIndex] = updatedStreamingMessage;
        
        _activeConversation = _activeConversation!.copyWith(
          messages: updatedMessages,
        );
        notifyListeners();
        
        yield fullContent;
      }
      
      // Finalize the message
      final lastIndex = _activeConversation!.messages.length - 1;
      final finalMessage = streamingMessage.copyWith(
        content: fullContent,
        isStreaming: false,
        tokenCount: _claudeService!.estimateTokens(fullContent),
        codeBlocks: _claudeService!.extractCodeBlocks(fullContent),
      );
      
      final finalMessages = List<Message>.from(_activeConversation!.messages);
      finalMessages[lastIndex] = finalMessage;
      
      _activeConversation = _activeConversation!.copyWith(
        messages: finalMessages,
        lastMessageAt: DateTime.now(),
        totalTokens: _activeConversation!.totalTokens + 
          (userMessage.tokenCount ?? 0) + 
          (finalMessage.tokenCount ?? 0),
      );
      
      // Update conversation title if it's the first exchange
      if (_activeConversation!.messages.length == 2) {
        final title = message.length > 50 
          ? '${message.substring(0, 50)}...' 
          : message;
        _activeConversation = _activeConversation!.copyWith(title: title);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error streaming message from Claude: $e');
      
      // Replace streaming message with error
      final lastIndex = _activeConversation!.messages.length - 1;
      final errorMessage = Message(
        id: streamingMessage.id,
        content: 'Error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
        isStreaming: false,
      );
      
      final errorMessages = List<Message>.from(_activeConversation!.messages);
      errorMessages[lastIndex] = errorMessage;
      
      _activeConversation = _activeConversation!.copyWith(
        messages: errorMessages,
        lastMessageAt: DateTime.now(),
      );
      
      notifyListeners();
    }
  }
}