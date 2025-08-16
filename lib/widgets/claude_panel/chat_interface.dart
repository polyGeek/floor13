import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/message.dart';
import 'message_bubble.dart';

class ChatInterface extends StatefulWidget {
  const ChatInterface({super.key});

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();
  
  // For multi-line input
  int _inputLines = 1;
  final int _maxInputLines = 8;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateInputLines);
    
    // Create initial conversation if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      if (appState.conversations.isEmpty) {
        appState.createNewConversation();
      }
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateInputLines);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
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

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;
    
    debugPrint('ChatInterface: Sending message: $message');
    
    setState(() {
      _isSending = true;
    });
    
    _messageController.clear();
    setState(() {
      _inputLines = 1;
    });
    
    final appState = context.read<AppState>();
    
    try {
      debugPrint('ChatInterface: Calling sendMessageToClaude');
      await appState.sendMessageToClaude(message);
      debugPrint('ChatInterface: Message sent successfully');
      
      // Scroll to bottom after message is added
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint('ChatInterface: Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final conversation = appState.activeConversation;
        final messages = conversation?.messages ?? [];
        
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
                  // Conversation tabs
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: appState.conversations.length,
                      itemBuilder: (context, index) {
                        final conv = appState.conversations[index];
                        final isActive = conv.id == conversation?.id;
                        
                        return GestureDetector(
                          onTap: () => appState.switchConversation(conv.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFF2D2D30),
                              border: Border(
                                right: const BorderSide(
                                  color: Color(0xFF464647),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: isActive
                                      ? const Color(0xFF007ACC)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Text(
                                    conv.title.length > 20 
                                      ? '${conv.title.substring(0, 20)}...'
                                      : conv.title,
                                    style: TextStyle(
                                      color: isActive
                                          ? const Color(0xFFCCCCCC)
                                          : const Color(0xFF969696),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (appState.conversations.length > 1) ...[
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => appState.closeConversation(conv.id),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Color(0xFF969696),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // New conversation button
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () {
                      appState.createNewConversation();
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
                child: messages.isEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                color: const Color(0xFF969696).withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return MessageBubble(
                          message: messages[index],
                        );
                      },
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
                    child: Row(
                      children: [
                        Text(
                          'Tokens: ~${(_messageController.text.length / 4).round()}',
                          style: const TextStyle(
                            color: Color(0xFF969696),
                            fontSize: 11,
                          ),
                        ),
                        if (conversation != null && conversation.totalTokens > 0) ...[
                          const SizedBox(width: 16),
                          Text(
                            'Session: ${conversation.totalTokens}',
                            style: const TextStyle(
                              color: Color(0xFF969696),
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (_isSending) ...[
                          const SizedBox(width: 16),
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007ACC)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Input field with send button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: KeyboardListener(
                          focusNode: _keyboardFocusNode,
                          onKeyEvent: (KeyEvent event) {
                            if (event is KeyDownEvent) {
                              // Ctrl+Enter to send
                              if (HardwareKeyboard.instance.isControlPressed &&
                                  event.logicalKey == LogicalKeyboardKey.enter) {
                                _sendMessage();
                              }
                            }
                          },
                          child: TextField(
                            controller: _messageController,
                            focusNode: _focusNode,
                            maxLines: _inputLines,
                            enabled: !_isSending,
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
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(color: Color(0xFF464647)),
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
                      SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _sendMessage,
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
                      SizedBox(
                        height: 38,
                        child: IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: _isSending ? null : () {
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
      },
    );
  }
}