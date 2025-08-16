import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/project.dart';

class StorageService {
  static const String _appFolderName = 'F13or';
  static const String _settingsFileName = 'config.json';
  
  Future<Directory> _getAppDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final separator = Platform.isWindows ? '\\' : '/';
    final appDir = Directory('${documentsDir.path}$separator$_appFolderName');
    
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    
    return appDir;
  }
  
  Future<Directory> getSettingsDirectory() async {
    final appDir = await _getAppDirectory();
    final separator = Platform.isWindows ? '\\' : '/';
    final settingsDir = Directory('${appDir.path}${separator}settings');
    
    if (!await settingsDir.exists()) {
      await settingsDir.create(recursive: true);
    }
    
    return settingsDir;
  }
  
  Future<File> _getSettingsFile() async {
    final settingsDir = await getSettingsDirectory();
    final separator = Platform.isWindows ? '\\' : '/';
    return File('${settingsDir.path}$separator$_settingsFileName');
  }
  
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final file = await _getSettingsFile();
      
      if (await file.exists()) {
        final contents = await file.readAsString();
        return json.decode(contents);
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
    
    return _getDefaultSettings();
  }
  
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final file = await _getSettingsFile();
      await file.writeAsString(json.encode(settings));
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
  
  Future<List<Project>> loadRecentProjects() async {
    final settings = await loadSettings();
    final recentProjects = settings['recentProjects'] as List<dynamic>?;
    
    if (recentProjects == null) return [];
    
    return recentProjects
        .map((json) => Project.fromJson(json))
        .toList();
  }
  
  Future<void> saveRecentProjects(List<Project> projects) async {
    final settings = await loadSettings();
    settings['recentProjects'] = projects.map((p) => p.toJson()).toList();
    await saveSettings(settings);
  }
  
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'recentProjects': [],
      'windowWidth': 1600.0,
      'windowHeight': 900.0,
      'theme': 'dark-vscode',
      'restoreLastSession': true,
      'maxRecentProjects': 10,
    };
  }
}