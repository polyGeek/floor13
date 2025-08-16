import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/editor_tab.dart';

class CodeEditor extends StatefulWidget {
  final EditorTab tab;

  const CodeEditor({
    super.key,
    required this.tab,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  late ScrollController _lineNumberScrollController;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tab.content);
    _scrollController = ScrollController();
    _lineNumberScrollController = ScrollController();
    
    // Sync line numbers scroll with code scroll
    _scrollController.addListener(() {
      if (_lineNumberScrollController.hasClients && 
          _lineNumberScrollController.offset != _scrollController.offset) {
        _lineNumberScrollController.jumpTo(_scrollController.offset);
      }
    });
    
    _controller.addListener(_onTextChanged);
  }
  
  void _onTextChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Start a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        final appState = context.read<AppState>();
        appState.updateFileContent(widget.tab.filePath, _controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(CodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tab.id != oldWidget.tab.id) {
      _controller.text = widget.tab.content;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    _lineNumberScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _getLanguageFromExtension(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'dart':
        return 'dart';
      case 'js':
        return 'javascript';
      case 'ts':
      case 'tsx':
        return 'typescript';
      case 'json':
        return 'json';
      case 'md':
        return 'markdown';
      case 'yaml':
      case 'yml':
        return 'yaml';
      case 'html':
        return 'html';
      case 'css':
        return 'css';
      case 'py':
        return 'python';
      case 'java':
        return 'java';
      case 'cpp':
      case 'cc':
      case 'cxx':
        return 'cpp';
      case 'c':
        return 'c';
      case 'cs':
        return 'csharp';
      case 'go':
        return 'go';
      case 'rs':
        return 'rust';
      case 'php':
        return 'php';
      case 'rb':
        return 'ruby';
      case 'swift':
        return 'swift';
      case 'kt':
        return 'kotlin';
      case 'sql':
        return 'sql';
      case 'sh':
      case 'bash':
        return 'bash';
      case 'xml':
        return 'xml';
      default:
        return 'plaintext';
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = _getLanguageFromExtension(widget.tab.filePath);
    final lines = _controller.text.split('\n');
    
    // Use monospace font - Flutter will use the system's default monospace font
    const fontFamily = 'monospace';
    const fontSize = 14.0;
    const lineHeight = 1.5;

    return Row(
      children: [
        // Line numbers
        Container(
          width: 50,
          color: const Color(0xFF2D2D30),
          child: SingleChildScrollView(
            controller: _lineNumberScrollController,
            physics: const NeverScrollableScrollPhysics(), // Disable manual scrolling
            child: Container(
              padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(lines.length, (index) {
                  return Container(
                    height: fontSize * lineHeight,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF858585),
                        fontSize: 13,
                        fontFamily: fontFamily,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        // Code editor
        Expanded(
          child: Container(
            color: const Color(0xFF1E1E1E),
            child: language != 'plaintext'
                ? SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Stack(
                        children: [
                        // Syntax highlighted preview
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: HighlightView(
                            _controller.text,
                            language: language,
                            theme: vs2015Theme,
                            textStyle: const TextStyle(
                              fontFamily: fontFamily,
                              fontSize: fontSize,
                              height: lineHeight,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        // Transparent text field for editing
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLines: null,
                          style: const TextStyle(
                            color: Colors.transparent,
                            fontFamily: fontFamily,
                            fontSize: fontSize,
                            height: lineHeight,
                          ),
                          cursorColor: const Color(0xFFFFFFFF),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // Trigger rebuild for syntax highlighting
                            });
                          },
                        ),
                      ],
                    ),
                    ),
                  )
                : SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      style: const TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontFamily: fontFamily,
                        fontSize: fontSize,
                        height: lineHeight,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}