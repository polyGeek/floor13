class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final int? tokenCount;
  final List<CodeBlock>? codeBlocks;
  final bool isStreaming;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.tokenCount,
    this.codeBlocks,
    this.isStreaming = false,
  });

  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    int? tokenCount,
    List<CodeBlock>? codeBlocks,
    bool? isStreaming,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      tokenCount: tokenCount ?? this.tokenCount,
      codeBlocks: codeBlocks ?? this.codeBlocks,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'tokenCount': tokenCount,
    'codeBlocks': codeBlocks?.map((cb) => cb.toJson()).toList(),
    'isStreaming': isStreaming,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    content: json['content'] as String,
    isUser: json['isUser'] as bool,
    timestamp: DateTime.parse(json['timestamp'] as String),
    tokenCount: json['tokenCount'] as int?,
    codeBlocks: json['codeBlocks'] != null
        ? (json['codeBlocks'] as List)
            .map((cb) => CodeBlock.fromJson(cb as Map<String, dynamic>))
            .toList()
        : null,
    isStreaming: json['isStreaming'] as bool? ?? false,
  );
}

class CodeBlock {
  final String language;
  final String code;
  final String? fileName;

  CodeBlock({
    required this.language,
    required this.code,
    this.fileName,
  });

  Map<String, dynamic> toJson() => {
    'language': language,
    'code': code,
    'fileName': fileName,
  };

  factory CodeBlock.fromJson(Map<String, dynamic> json) => CodeBlock(
    language: json['language'] as String,
    code: json['code'] as String,
    fileName: json['fileName'] as String?,
  );
}