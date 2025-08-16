# F13or Phase 3: Claude Code Integration Panel

## Session Management
- This is a focused, single-phase task
- Complete only what's specified
- Do not explore adjacent features
- End session after completion criteria met
- **Expected Duration**: 2-3 hours maximum
- **Prerequisites**: Phases 1-2 must be complete

## Objective
Implement the Claude Code chat interface in the right panel with conversation management, token tracking, and proper message formatting.

## Starting Point
You have a working file explorer and editor. Now add Claude Code integration in the right panel.

## Deliverables

### 1. Claude Chat Interface (Right Panel)

#### Create New Files:
```
lib/widgets/claude_panel/
├── chat_interface.dart
├── message_bubble.dart
├── message_input.dart
├── conversation_tabs.dart
└── token_tracker.dart

lib/services/
├── claude_service.dart
└── token_counter.dart

lib/models/
├── conversation.dart
└── message.dart
```

### 2. Data Models

```dart
class Conversation {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final int totalTokens;
  
  // Include JSON serialization
}

class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final int? tokenCount;
  final List<CodeBlock>? codeBlocks;
}

class CodeBlock {
  final String language;
  final String code;
  final String? fileName;
}
```

### 3. Chat Interface Features

#### Message Display:
- User messages: Right-aligned, blue background (#0084ff)
- Claude messages: Left-aligned, dark background (#2d2d30)
- Markdown rendering for Claude responses
- Code blocks with syntax highlighting
- Copy button for code blocks
- Timestamp on hover

#### Message Input:
- Multi-line text input at bottom of panel
- Auto-resize as user types (max 200px height)
- Ctrl+Enter to submit (important!)
- Shift+Enter for new line
- Clear button to reset input
- Character/token estimate display

#### Conversation Tabs:
- Multiple conversation tabs at top of right panel
- Tab shows conversation title (truncated if needed)
- New conversation button (+)
- Close conversation button (×) on tab
- Indicate active conversation

### 4. Claude Service Implementation

```dart
class ClaudeService {
  // Use claude_dart_flutter package
  
  Future<String> sendMessage(String message, List<Message> history);
  Stream<String> streamResponse(String message, List<Message> history);
  
  // Parse response for code blocks
  List<CodeBlock> extractCodeBlocks(String response);
  
  // Handle file references in conversation
  String processFileReferences(String message, String currentProjectPath);
}
```

### 5. Token Tracking

#### Display Requirements:
- Show current session tokens used
- Estimate remaining tokens in 5-hour window
- Session start time
- Time remaining in current window
- Visual indicator (progress bar) for token usage

#### Token Counting:
```dart
class TokenCounter {
  // Rough estimation: 1 token ≈ 4 characters
  int estimateTokens(String text);
  
  // Track cumulative usage
  int sessionTokensUsed = 0;
  DateTime sessionStartTime;
  
  // 5-hour window = 18,000 seconds
  Duration timeRemaining();
  
  // Persist token tracking between app restarts
  void saveTokenState();
  void loadTokenState();
}
```

### 6. Special Features

#### Code Block Actions:
When Claude suggests code, display buttons for:
- Copy to clipboard
- Insert at cursor (if file is open in editor)
- Create new file with code
- Replace selection (if text is selected in editor)

#### Commit Message Detection:
If response contains a git commit message pattern:
- Render as a button
- Click to copy to clipboard
- Show "Commit Message" label

#### File Path Detection:
If response mentions file paths:
- Make them clickable
- Click to open file in editor

### 7. Settings Integration

Add to settings:
```json
{
  "claudeApiKey": "sk-ant-...",
  "maxTokensPerMessage": 4000,
  "streamResponses": true,
  "saveConversationHistory": true,
  "maxHistoryMessages": 50
}
```

## Implementation Notes

### Dependencies:
```yaml
dependencies:
  claude_dart_flutter: latest # or equivalent package
  flutter_markdown: ^0.7.4
  markdown: ^7.2.2
```

### API Key Management:
- Store encrypted in settings
- Prompt user to enter on first use
- Validate key before saving

### Conversation Persistence:
- Auto-save conversations to project .f13or file
- Limit history to prevent huge files
- Option to export conversation as markdown

## Phase Complete When:
✓ Can send messages to Claude Code
✓ Responses display with markdown formatting
✓ Code blocks have syntax highlighting
✓ Ctrl+Enter submits message
✓ Multiple conversation tabs work
✓ Token tracking displays and updates
✓ Conversations persist between sessions
✓ No console errors
✓ Manual test: Send "Write a hello world in Python" and get formatted response

## STOP HERE - Do not continue to next phase

## Future Context (for awareness only):
- Phase 4 will involve: Multi-project support with project tabs
- Phase 5 will involve: Git integration
- Phase 6 will involve: Theming system
DO NOT IMPLEMENT PHASES 4-6 IN THIS SESSION

## Recommended Approach:
1. Scout: Review Claude API documentation (15 min max)
2. Forge: Design conversation state management (20 min max)
3. Spark: Build chat UI and message display (45 min max)
4. Spark: Implement Claude service and API calls (30 min max)
5. Sentinel: Test conversation flow (10 min max)
Total session: ~2 hours

## Avoid These Patterns:
- Don't implement complex conversation search
- Don't add voice input or TTS
- Don't build conversation templates yet
- Don't implement collaborative features
- Don't add export options beyond basic
- Focus on core chat functionality