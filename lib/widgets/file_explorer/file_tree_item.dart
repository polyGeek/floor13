import 'dart:io';
import 'package:flutter/material.dart';

class FileTreeItem extends StatefulWidget {
  final FileSystemEntity entity;
  final int indentLevel;
  final Function(String) onFileSelected;
  final Function(String) onFileDoubleClick;

  const FileTreeItem({
    super.key,
    required this.entity,
    required this.indentLevel,
    required this.onFileSelected,
    required this.onFileDoubleClick,
  });

  @override
  State<FileTreeItem> createState() => _FileTreeItemState();
}

class _FileTreeItemState extends State<FileTreeItem> {
  bool _isExpanded = false;
  bool _isHovered = false;
  bool _isSelected = false;
  List<FileSystemEntity> _children = [];

  String get _name {
    final separator = Platform.isWindows ? '\\' : '/';
    final pathParts = widget.entity.path.split(separator);
    return pathParts.isNotEmpty ? pathParts.last : 'Unknown';
  }

  bool get _isDirectory => widget.entity is Directory;

  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'dart':
        return Icons.code;
      case 'md':
        return Icons.description;
      case 'json':
        return Icons.data_object;
      case 'yaml':
      case 'yml':
        return Icons.settings;
      case 'txt':
        return Icons.text_snippet;
      case 'html':
      case 'css':
      case 'js':
      case 'ts':
        return Icons.web;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot != -1 && lastDot != path.length - 1) {
      return path.substring(lastDot + 1).toLowerCase();
    }
    return '';
  }

  Future<void> _loadChildren() async {
    if (_isDirectory) {
      try {
        final directory = Directory(widget.entity.path);
        final contents = await directory.list().toList();
        contents.sort((a, b) {
          if (a is Directory && b is File) return -1;
          if (a is File && b is Directory) return 1;
          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });
        setState(() {
          _children = contents;
        });
      } catch (e) {
        debugPrint('Error loading children: $e');
      }
    }
  }

  void _toggleExpanded() {
    if (_isDirectory) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
      if (_isExpanded && _children.isEmpty) {
        _loadChildren();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (_isDirectory) {
              _toggleExpanded();
            } else {
              widget.onFileSelected(widget.entity.path);
            }
            setState(() {
              _isSelected = true;
            });
          },
          onDoubleTap: () {
            if (!_isDirectory) {
              widget.onFileDoubleClick(widget.entity.path);
            }
          },
          onHover: (hovering) {
            setState(() {
              _isHovered = hovering;
            });
          },
          child: Container(
            height: 28,
            color: _isSelected
                ? const Color(0xFF094771)
                : _isHovered
                    ? const Color(0xFF2A2D2E)
                    : Colors.transparent,
            padding: EdgeInsets.only(left: widget.indentLevel * 20.0 + 8),
            child: Row(
              children: [
                if (_isDirectory) ...[
                  Icon(
                    _isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                    color: const Color(0xFF969696),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.folder_open : Icons.folder,
                    size: 16,
                    color: const Color(0xFFDCB67A),
                  ),
                ] else ...[
                  const SizedBox(width: 20),
                  Icon(
                    _getFileIcon(_getFileExtension(widget.entity.path)),
                    size: 16,
                    color: const Color(0xFF969696),
                  ),
                ],
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _name,
                    style: const TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded && _children.isNotEmpty)
          ...(_children.map((child) => FileTreeItem(
                entity: child,
                indentLevel: widget.indentLevel + 1,
                onFileSelected: widget.onFileSelected,
                onFileDoubleClick: widget.onFileDoubleClick,
              ))),
      ],
    );
  }
}