import 'dart:io';
import 'package:flutter/foundation.dart';

class FileService {
  Future<List<FileSystemEntity>> getDirectoryContents(String path) async {
    try {
      final directory = Directory(path);
      if (await directory.exists()) {
        final contents = await directory.list().toList();
        contents.sort((a, b) {
          // Directories first, then files
          if (a is Directory && b is File) return -1;
          if (a is File && b is Directory) return 1;
          // Then alphabetically
          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });
        return contents;
      }
    } catch (e) {
      debugPrint('Error reading directory: $e');
    }
    return [];
  }

  Future<String> readFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      debugPrint('Error reading file: $e');
    }
    return '';
  }

  Future<void> writeFile(String path, String content) async {
    try {
      final file = File(path);
      await file.writeAsString(content);
    } catch (e) {
      debugPrint('Error writing file: $e');
      rethrow;
    }
  }

  Future<void> createFile(String path) async {
    try {
      final file = File(path);
      await file.create(recursive: true);
    } catch (e) {
      debugPrint('Error creating file: $e');
      rethrow;
    }
  }

  Future<void> createFolder(String path) async {
    try {
      final directory = Directory(path);
      await directory.create(recursive: true);
    } catch (e) {
      debugPrint('Error creating folder: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  Future<void> deleteFolder(String path) async {
    try {
      final directory = Directory(path);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error deleting folder: $e');
      rethrow;
    }
  }

  Future<void> renameFile(String oldPath, String newPath) async {
    try {
      final file = File(oldPath);
      if (await file.exists()) {
        await file.rename(newPath);
      }
    } catch (e) {
      debugPrint('Error renaming file: $e');
      rethrow;
    }
  }

  String getFileName(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  String getFileExtension(String path) {
    final fileName = getFileName(path);
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot != -1 && lastDot != fileName.length - 1) {
      return fileName.substring(lastDot + 1).toLowerCase();
    }
    return '';
  }
}