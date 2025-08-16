import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/app_state.dart';

class ApiKeySetup extends StatefulWidget {
  const ApiKeySetup({super.key});

  @override
  State<ApiKeySetup> createState() => _ApiKeySetupState();
}

class _ApiKeySetupState extends State<ApiKeySetup> {
  final _apiKeyController = TextEditingController();
  bool _isKeyVisible = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Claude API Setup',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 24),
          
          // Instructions card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF464647)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How to get your API key:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFCCCCCC),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '1. Visit the Anthropic Console to create or manage your API keys',
                  style: TextStyle(color: Color(0xFF969696)),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _launchUrl('https://console.anthropic.com/settings/keys'),
                  child: const Text(
                    '→ Open Anthropic Console',
                    style: TextStyle(color: Color(0xFF007ACC)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '2. For detailed instructions on creating API keys:',
                  style: TextStyle(color: Color(0xFF969696)),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _launchUrl('https://docs.anthropic.com/en/api/admin-api/apikeys/get-api-key'),
                  child: const Text(
                    '→ View API Documentation',
                    style: TextStyle(color: Color(0xFF007ACC)),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // API Key input
          const Text(
            'API Key',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF969696),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _apiKeyController,
                  obscureText: !_isKeyVisible,
                  style: const TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    hintText: 'sk-ant-api03-...',
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isKeyVisible ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF969696),
                      ),
                      onPressed: () {
                        setState(() {
                          _isKeyVisible = !_isKeyVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_apiKeyController.text.trim().isNotEmpty) {
                    // Save the API key
                    final appState = context.read<AppState>();
                    appState.saveClaudeApiKey(_apiKeyController.text.trim());
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('API key saved successfully'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007ACC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Security note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF464647).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock,
                  size: 16,
                  color: Color(0xFF969696),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Your API key is stored locally and never shared',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF969696),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}