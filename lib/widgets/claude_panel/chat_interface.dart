import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';

class ChatInterface extends StatefulWidget {
  const ChatInterface({super.key});

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  // For multi-line input
  int _inputLines = 1;
  final int _maxInputLines = 8;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateInputLines);
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateInputLines);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateInputLines() {
    final text = _messageController.text;
    final lines = '\n'.allMatches(text).length + 1;
    final newLines = lines.clamp(1, _maxInputLines);
    if (newLines != _inputLines) {
      setState(() {
        _inputLines = newLines;
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    
    // TODO: Send message to Claude API
    debugPrint('Sending message: $message');
    
    _messageController.clear();
    setState(() {
      _inputLines = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with conversation tabs
        Container(
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF2D2D30),
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF464647),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Conversation tabs will go here
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Claude Chat',
                    style: TextStyle(
                      color: Color(0xFF969696),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              // New conversation button
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () {
                  // TODO: Create new conversation
                },
                tooltip: 'New Conversation',
              ),
            ],
          ),
        ),
        
        // Messages area
        Expanded(
          child: Container(
            color: const Color(0xFF1E1E1E),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome message
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.chat,
                          size: 48,
                          color: Color(0xFF505050),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Start a conversation with Claude',
                          style: TextStyle(
                            color: Color(0xFF969696),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ctrl+Enter to send • Shift+Enter for new line',
                          style: TextStyle(
                            color: const Color(0xFF969696).withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Input area
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF252526),
            border: Border(
              top: BorderSide(
                color: Color(0xFF464647),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Token counter
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Tokens: ~${(_messageController.text.length / 4).round()}',
                  style: const TextStyle(
                    color: Color(0xFF969696),
                    fontSize: 11,
                  ),
                ),
              ),
              
              // Input field with send button
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (RawKeyEvent event) {
                        if (event is RawKeyDownEvent) {
                          // Ctrl+Enter to send
                          if (event.isControlPressed &&
                              event.logicalKey == LogicalKeyboardKey.enter) {
                            _sendMessage();
                          }
                        }
                      },
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        maxLines: _inputLines,
                        style: const TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ask Claude...',
                          hintStyle: const TextStyle(color: Color(0xFF505050)),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Color(0xFF464647)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Color(0xFF464647)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Color(0xFF007ACC)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  Container(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007ACC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Icon(Icons.send, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Clear button
                  Container(
                    height: 38,
                    child: IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _messageController.clear();
                        setState(() {
                          _inputLines = 1;
                        });
                      },
                      tooltip: 'Clear input',
                      color: const Color(0xFF969696),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}