import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import 'claude_panel/api_key_setup.dart';
import 'claude_panel/chat_interface.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF252526),
        border: Border(
          left: BorderSide(
            color: Color(0xFF464647),
            width: 1,
          ),
        ),
      ),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          // Show API key setup if no key is configured
          if (!appState.hasClaudeApiKey) {
            return const ApiKeySetup();
          }
          
          // Show chat interface when API key is configured
          return const ChatInterface();
        },
      ),
    );
  }
}