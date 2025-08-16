import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/message.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final VoidCallback? onCodeInsert;

  const MessageBubble({
    super.key,
    required this.message,
    this.onCodeInsert,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isHovered = false;

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildCodeBlock(String code, String language) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF464647)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with language and copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D30),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Text(
                  language.isEmpty ? 'code' : language,
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    color: const Color(0xFF969696),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _copyToClipboard(code),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.copy,
                      size: 14,
                      color: Color(0xFF969696),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code content
          Container(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HighlightView(
                code,
                language: language.isEmpty ? 'plaintext' : language,
                theme: vs2015Theme,
                textStyle: GoogleFonts.robotoMono(
                  fontSize: 13,
                  height: 1.5,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: _isHovered 
          ? const Color(0xFF2A2A2A).withOpacity(0.3) 
          : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              // Claude avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF007ACC),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            // Message content
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser 
                    ? const Color(0xFF0084FF).withOpacity(0.9)
                    : const Color(0xFF2D2D30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message text with markdown
                    if (isUser)
                      Text(
                        widget.message.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      )
                    else
                      MarkdownBody(
                        data: widget.message.content,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 14,
                            height: 1.5,
                          ),
                          code: GoogleFonts.robotoMono(
                            color: const Color(0xFFCCCCCC),
                            backgroundColor: const Color(0xFF1E1E1E),
                            fontSize: 13,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          h1: const TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          h2: const TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          h3: const TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          listBullet: const TextStyle(color: Color(0xFFCCCCCC)),
                          a: const TextStyle(color: Color(0xFF007ACC)),
                        ),
                        builders: {
                          'code': CodeBlockBuilder(),
                        },
                      ),
                    
                    // Timestamp on hover
                    if (_isHovered)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _formatTimestamp(widget.message.timestamp),
                          style: TextStyle(
                            color: isUser 
                              ? Colors.white.withOpacity(0.7)
                              : const Color(0xFF969696),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    
                    // Token count if available
                    if (widget.message.tokenCount != null && _isHovered)
                      Text(
                        '~${widget.message.tokenCount} tokens',
                        style: TextStyle(
                          color: isUser 
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF969696),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            if (isUser) ...[
              const SizedBox(width: 12),
              // User avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

// Custom markdown builder for code blocks
class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, preferredStyle) {
    if (element.tag == 'pre' || element.tag == 'code') {
      final code = element.textContent;
      final language = element.attributes['class']?.replaceAll('language-', '') ?? '';
      
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          code,
          style: GoogleFonts.robotoMono(
            color: const Color(0xFFCCCCCC),
            fontSize: 13,
          ),
        ),
      );
    }
    return null;
  }
}