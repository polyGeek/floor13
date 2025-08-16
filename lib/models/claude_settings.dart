class ClaudeSettings {
  final String? apiKey;
  final int maxTokensPerMessage;
  final bool streamResponses;
  final bool saveConversationHistory;
  final int maxHistoryMessages;

  ClaudeSettings({
    this.apiKey,
    this.maxTokensPerMessage = 4000,
    this.streamResponses = true,
    this.saveConversationHistory = true,
    this.maxHistoryMessages = 50,
  });

  Map<String, dynamic> toJson() => {
    'apiKey': apiKey,
    'maxTokensPerMessage': maxTokensPerMessage,
    'streamResponses': streamResponses,
    'saveConversationHistory': saveConversationHistory,
    'maxHistoryMessages': maxHistoryMessages,
  };

  factory ClaudeSettings.fromJson(Map<String, dynamic> json) => ClaudeSettings(
    apiKey: json['apiKey'] as String?,
    maxTokensPerMessage: json['maxTokensPerMessage'] as int? ?? 4000,
    streamResponses: json['streamResponses'] as bool? ?? true,
    saveConversationHistory: json['saveConversationHistory'] as bool? ?? true,
    maxHistoryMessages: json['maxHistoryMessages'] as int? ?? 50,
  );

  ClaudeSettings copyWith({
    String? apiKey,
    int? maxTokensPerMessage,
    bool? streamResponses,
    bool? saveConversationHistory,
    int? maxHistoryMessages,
  }) => ClaudeSettings(
    apiKey: apiKey ?? this.apiKey,
    maxTokensPerMessage: maxTokensPerMessage ?? this.maxTokensPerMessage,
    streamResponses: streamResponses ?? this.streamResponses,
    saveConversationHistory: saveConversationHistory ?? this.saveConversationHistory,
    maxHistoryMessages: maxHistoryMessages ?? this.maxHistoryMessages,
  );
}