import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/claude_settings.dart';

class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-3-opus-20240229'; // Latest model
  
  final ClaudeSettings settings;
  
  ClaudeService({required this.settings});

  Future<Message> sendMessage({
    required String userMessage,
    required List<Message> conversationHistory,
  }) async {
    if (settings.apiKey == null || settings.apiKey!.isEmpty) {
      throw Exception('API key not configured');
    }

    try {
      final messages = _buildMessageHistory(conversationHistory, userMessage);
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': settings.apiKey!,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': settings.maxTokensPerMessage,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'] as String;
        final usage = data['usage'];
        
        return Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: content,
          isUser: false,
          timestamp: DateTime.now(),
          tokenCount: usage?['output_tokens'] as int?,
          codeBlocks: extractCodeBlocks(content),
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception('API Error: ${error['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Claude API Error: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<String> streamMessage({
    required String userMessage,
    required List<Message> conversationHistory,
  }) async* {
    if (!settings.streamResponses) {
      final response = await sendMessage(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
      );
      yield response.content;
      return;
    }

    if (settings.apiKey == null || settings.apiKey!.isEmpty) {
      throw Exception('API key not configured');
    }

    try {
      final messages = _buildMessageHistory(conversationHistory, userMessage);
      
      final request = http.Request('POST', Uri.parse(_baseUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'x-api-key': settings.apiKey!,
        'anthropic-version': '2023-06-01',
        'Accept': 'text/event-stream',
      });
      
      request.body = jsonEncode({
        'model': _model,
        'messages': messages,
        'max_tokens': settings.maxTokensPerMessage,
        'temperature': 0.7,
        'stream': true,
      });

      final streamedResponse = await request.send();
      
      if (streamedResponse.statusCode == 200) {
        final stream = streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());
        
        String fullContent = '';
        await for (final line in stream) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;
            
            try {
              final json = jsonDecode(data);
              if (json['delta']?['text'] != null) {
                final text = json['delta']['text'] as String;
                fullContent += text;
                yield fullContent;
              }
            } catch (e) {
              // Skip invalid JSON lines
            }
          }
        }
      } else {
        throw Exception('Stream error: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Claude Stream Error: $e');
      throw Exception('Failed to stream message: $e');
    }
  }

  List<Map<String, dynamic>> _buildMessageHistory(
    List<Message> history,
    String currentMessage,
  ) {
    final messages = <Map<String, dynamic>>[];
    
    // Add conversation history (limited by settings)
    final historyLimit = settings.maxHistoryMessages;
    final startIndex = history.length > historyLimit 
        ? history.length - historyLimit 
        : 0;
    
    for (int i = startIndex; i < history.length; i++) {
      messages.add({
        'role': history[i].isUser ? 'user' : 'assistant',
        'content': history[i].content,
      });
    }
    
    // Add current message
    messages.add({
      'role': 'user',
      'content': currentMessage,
    });
    
    return messages;
  }

  List<CodeBlock> extractCodeBlocks(String content) {
    final codeBlocks = <CodeBlock>[];
    final regex = RegExp(r'```(\w*)\n(.*?)```', multiLine: true, dotAll: true);
    
    final matches = regex.allMatches(content);
    for (final match in matches) {
      final language = match.group(1) ?? '';
      final code = match.group(2) ?? '';
      
      // Try to extract filename from comments
      String? fileName;
      final firstLine = code.split('\n').first;
      if (firstLine.startsWith('//') || firstLine.startsWith('#')) {
        final fileMatch = RegExp(r'[\/\#]+\s*(.+\.\w+)').firstMatch(firstLine);
        if (fileMatch != null) {
          fileName = fileMatch.group(1);
        }
      }
      
      codeBlocks.add(CodeBlock(
        language: language,
        code: code,
        fileName: fileName,
      ));
    }
    
    return codeBlocks;
  }

  int estimateTokens(String text) {
    // Rough estimation: 1 token ≈ 4 characters
    return (text.length / 4).round();
  }

  String processFileReferences(String message, String? currentProjectPath) {
    if (currentProjectPath == null) return message;
    
    // Replace @file references with actual file content
    final fileRegex = RegExp(r'@file\(([^)]+)\)');
    return message.replaceAllMapped(fileRegex, (match) {
      final filePath = match.group(1)!;
      // TODO: Read file content and include it
      return '[File: $filePath]';
    });
  }
}